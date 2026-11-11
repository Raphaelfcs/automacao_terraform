"""Adaptadores AWS: DynamoDB, S3 e Cognito (boto3).

Usados nas Lambdas (credencial da role de execução) e no Cloud Run (credencial temporária obtida
por federação Google -> AWS, sem chave fixa: veja federacao.py).
"""
from __future__ import annotations

from decimal import Decimal

from boto3.dynamodb.conditions import Attr, Key
from botocore.exceptions import ClientError

from ..core.models import Conflito

INDICE_PACIENTE = "por_paciente"


def _limpar(v):
    """DynamoDB devolve Decimal; o domínio só usa inteiros."""
    if isinstance(v, Decimal):
        return int(v) if v == v.to_integral_value() else float(v)
    if isinstance(v, dict):
        return {k: _limpar(x) for k, x in v.items()}
    if isinstance(v, list):
        return [_limpar(x) for x in v]
    return v


def condicao_mais_novo(item: dict):
    """Grava se não existe ou se (atualizado_em, versao, origem) recebido for maior que o guardado."""
    t, v, o = int(item.get("atualizado_em", 0)), int(item.get("versao", 0)), item.get("origem", "")
    return (Attr("pk").not_exists()
            | Attr("atualizado_em").lt(t)
            | (Attr("atualizado_em").eq(t) & Attr("versao").lt(v))
            | (Attr("atualizado_em").eq(t) & Attr("versao").eq(v) & Attr("origem").lt(o)))


class RepoDynamo:
    def __init__(self, tabela):
        self.t = tabela  # boto3.resource("dynamodb").Table(nome)

    def obter(self, pk, sk):
        r = self.t.get_item(Key={"pk": pk, "sk": sk}, ConsistentRead=True)
        return _limpar(r["Item"]) if "Item" in r else None

    def gravar(self, item):
        self.t.put_item(Item=item)

    def inserir(self, item):
        try:
            self.t.put_item(Item=item, ConditionExpression=Attr("pk").not_exists())
        except ClientError as e:
            if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
                raise Conflito("item já existe") from e
            raise

    def gravar_se_mais_novo(self, item):
        try:
            self.t.put_item(Item=item, ConditionExpression=condicao_mais_novo(item))
            return True
        except ClientError as e:
            if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
                return False
            raise

    def listar_prefixo(self, pk, prefixo_sk, limite=200):
        cond = Key("pk").eq(pk) & Key("sk").begins_with(prefixo_sk) if prefixo_sk else Key("pk").eq(pk)
        r = self.t.query(KeyConditionExpression=cond, Limit=limite)
        return [_limpar(i) for i in r.get("Items", [])]

    def documentos_do_paciente(self, paciente_sub, limite=200):
        r = self.t.query(IndexName=INDICE_PACIENTE, Limit=limite,
                         KeyConditionExpression=Key("paciente_sub").eq(paciente_sub) & Key("sk").begins_with("DOC#"))
        return [_limpar(i) for i in r.get("Items", [])]


class ArmazenamentoS3:
    nuvem = "aws"

    def __init__(self, s3, bucket: str, origem: str = "aws"):
        self.s3, self.bucket, self.origem = s3, bucket, origem

    def url_envio(self, chave, tamanho, ttl):
        campos = {"Content-Type": "application/pdf", "x-amz-meta-origem": self.origem}
        cond = [{"Content-Type": "application/pdf"}, {"x-amz-meta-origem": self.origem},
                ["content-length-range", tamanho, tamanho]]
        r = self.s3.generate_presigned_post(Bucket=self.bucket, Key=chave, Fields=campos, Conditions=cond, ExpiresIn=ttl)
        return {"metodo": "POST", "url": r["url"], "campos": r["fields"]}

    def url_download(self, chave, nome_arquivo, ttl):
        return self.s3.generate_presigned_url("get_object", ExpiresIn=ttl, Params={
            "Bucket": self.bucket, "Key": chave, "ResponseContentType": "application/pdf",
            "ResponseContentDisposition": f'attachment; filename="{nome_arquivo}"'})

    def _head(self, chave):
        try:
            return self.s3.head_object(Bucket=self.bucket, Key=chave)
        except ClientError as e:
            if e.response["Error"]["Code"] in ("404", "NoSuchKey", "NotFound"):
                return None
            raise

    def existe(self, chave):
        return self._head(chave) is not None

    def metadados(self, chave):
        h = self._head(chave)
        return dict(h.get("Metadata", {})) if h else {}

    def ler(self, chave, limite):
        r = self.s3.get_object(Bucket=self.bucket, Key=chave, Range=f"bytes=0-{limite - 1}")
        return r["Body"].read()

    def escrever(self, chave, dados, metadados):
        self.s3.put_object(Bucket=self.bucket, Key=chave, Body=dados, ContentType="application/pdf", Metadata=metadados)

    def apagar(self, chave):
        self.s3.delete_object(Bucket=self.bucket, Key=chave)


class IdentidadesCognito:
    def __init__(self, cognito, pools: dict):
        self.c, self.pools = cognito, pools  # {"equipe": pool_id, "paciente": pool_id}

    def criar_usuario(self, pool, email, nome):
        pool_id = self.pools[pool]
        try:
            r = self.c.admin_create_user(UserPoolId=pool_id, Username=email, DesiredDeliveryMediums=["EMAIL"],
                                         UserAttributes=[{"Name": "email", "Value": email},
                                                         {"Name": "email_verified", "Value": "true"},
                                                         {"Name": "name", "Value": nome}])
            attrs = r["User"]["Attributes"]
        except ClientError as e:
            if e.response["Error"]["Code"] != "UsernameExistsException":
                raise
            attrs = self.c.admin_get_user(UserPoolId=pool_id, Username=email)["UserAttributes"]
        return next(a["Value"] for a in attrs if a["Name"] == "sub")
