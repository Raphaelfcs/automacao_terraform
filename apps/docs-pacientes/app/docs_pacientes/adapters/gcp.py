"""Adaptadores GCP: Firestore e Cloud Storage pela API REST (google-auth + requests).

REST em vez das bibliotecas cliente para o mesmo código rodar no Cloud Run e na Lambda (que acessa
o GCP por Workload Identity Federation) com dependências pequenas e sem gRPC.
"""
from __future__ import annotations

import base64
import datetime as dt
import hashlib
import json
import urllib.parse

from ..core.models import Conflito
from ..core.replicacao import mais_novo

FS = "https://firestore.googleapis.com/v1"
GCS = "https://storage.googleapis.com"
COLECAO = "itens"


# --------------------------------------------------------------------------- codificação Firestore
def para_firestore(v):
    if v is None:
        return {"nullValue": None}
    if isinstance(v, bool):
        return {"booleanValue": v}
    if isinstance(v, int):
        return {"integerValue": str(v)}
    if isinstance(v, float):
        return {"doubleValue": v}
    if isinstance(v, str):
        return {"stringValue": v}
    if isinstance(v, dict):
        return {"mapValue": {"fields": {k: para_firestore(x) for k, x in v.items()}}}
    if isinstance(v, (list, tuple)):
        return {"arrayValue": {"values": [para_firestore(x) for x in v]}}
    raise TypeError(f"tipo não suportado: {type(v).__name__}")


def de_firestore(v: dict):
    (tipo, valor), = v.items()
    if tipo == "nullValue":
        return None
    if tipo == "integerValue":
        return int(valor)
    if tipo == "mapValue":
        return {k: de_firestore(x) for k, x in (valor.get("fields") or {}).items()}
    if tipo == "arrayValue":
        return [de_firestore(x) for x in (valor.get("values") or [])]
    return valor  # booleanValue, doubleValue, stringValue, timestampValue


def doc_para_item(doc: dict) -> dict:
    return {k: de_firestore(v) for k, v in (doc.get("fields") or {}).items()}


def id_documento(pk: str, sk: str) -> str:
    """Firestore não aceita '/' no id: base64 url-safe de pk|sk, reversível e estável."""
    return base64.urlsafe_b64encode(f"{pk}|{sk}".encode()).decode().rstrip("=")


class RepoFirestore:
    def __init__(self, sessao, projeto: str, banco: str = "(default)"):
        self.s = sessao  # google.auth.transport.requests.AuthorizedSession
        self.raiz = f"projects/{projeto}/databases/{banco}/documents"

    def _nome(self, pk, sk):
        return f"{self.raiz}/{COLECAO}/{id_documento(pk, sk)}"

    def _get(self, pk, sk):
        r = self.s.get(f"{FS}/{self._nome(pk, sk)}", timeout=10)
        if r.status_code == 404:
            return None
        r.raise_for_status()
        return r.json()

    def obter(self, pk, sk):
        d = self._get(pk, sk)
        return doc_para_item(d) if d else None

    def _commit(self, item, pre=None):
        w = {"update": {"name": self._nome(item["pk"], item["sk"]), "fields": {k: para_firestore(v) for k, v in item.items()}}}
        if pre:
            w["currentDocument"] = pre
        return self.s.post(f"{FS}/{self.raiz}:commit", json={"writes": [w]}, timeout=10)

    def gravar(self, item):
        self._commit(item).raise_for_status()

    def inserir(self, item):
        r = self._commit(item, {"exists": False})
        if r.status_code == 409 or (r.status_code == 400 and ("ALREADY_EXISTS" in r.text or "FAILED_PRECONDITION" in r.text)):
            raise Conflito("item já existe")
        r.raise_for_status()

    def gravar_se_mais_novo(self, item):
        for _ in range(3):  # concorrência otimista: precondição no updateTime lido
            atual = self._get(item["pk"], item["sk"])
            if atual and not mais_novo(item, doc_para_item(atual)):
                return False
            r = self._commit(item, {"updateTime": atual["updateTime"]} if atual else {"exists": False})
            if r.ok:
                return True
            if r.status_code not in (400, 409):
                r.raise_for_status()
        return False

    def _consulta(self, filtros, limite):
        q = {"structuredQuery": {"from": [{"collectionId": COLECAO}],
                                 "where": {"compositeFilter": {"op": "AND", "filters": filtros}},
                                 "orderBy": [{"field": {"fieldPath": "sk"}}], "limit": limite}}
        r = self.s.post(f"{FS}/{self.raiz}:runQuery", json=q, timeout=10)
        r.raise_for_status()
        return [doc_para_item(x["document"]) for x in r.json() if "document" in x]

    @staticmethod
    def _f(campo, op, valor):
        return {"fieldFilter": {"field": {"fieldPath": campo}, "op": op, "value": para_firestore(valor)}}

    def listar_prefixo(self, pk, prefixo_sk, limite=200):
        filtros = [self._f("pk", "EQUAL", pk)]
        if prefixo_sk:
            filtros += [self._f("sk", "GREATER_THAN_OR_EQUAL", prefixo_sk), self._f("sk", "LESS_THAN", prefixo_sk + "￿")]
        return self._consulta(filtros, limite)

    def documentos_do_paciente(self, paciente_sub, limite=200):
        return self._consulta([self._f("paciente_sub", "EQUAL", paciente_sub),
                               self._f("sk", "GREATER_THAN_OR_EQUAL", "DOC#"), self._f("sk", "LESS_THAN", "DOC#￿")], limite)


# --------------------------------------------------------------------------- URL assinada V4
def url_assinada_v4(assinar, conta: str, bucket: str, chave: str, metodo: str, ttl: int,
                    cabecalhos: dict | None = None, consulta: dict | None = None, agora: dt.datetime | None = None) -> str:
    """URL assinada V4 do Cloud Storage (GOOG4-RSA-SHA256).

    `assinar(bytes) -> bytes` assina com a chave da conta de serviço sem exportá-la (IAM signBlob).
    Cabeçalhos assinados precisam ser enviados exatamente iguais pelo cliente.
    """
    agora = agora or dt.datetime.now(dt.timezone.utc)
    instante, dia = agora.strftime("%Y%m%dT%H%M%SZ"), agora.strftime("%Y%m%d")
    escopo = f"{dia}/auto/storage/goog4_request"
    host = "storage.googleapis.com"
    cab = {"host": host, **{k.lower(): str(v).strip() for k, v in (cabecalhos or {}).items()}}
    assinados = ";".join(sorted(cab))
    q = {"X-Goog-Algorithm": "GOOG4-RSA-SHA256", "X-Goog-Credential": f"{conta}/{escopo}", "X-Goog-Date": instante,
         "X-Goog-Expires": str(ttl), "X-Goog-SignedHeaders": assinados, **(consulta or {})}
    canon_q = "&".join(f"{urllib.parse.quote(k, safe='~')}={urllib.parse.quote(v, safe='~')}" for k, v in sorted(q.items()))
    recurso = f"/{bucket}/{urllib.parse.quote(chave, safe='/~')}"
    canon_cab = "".join(f"{k}:{cab[k]}\n" for k in sorted(cab))
    req = "\n".join([metodo, recurso, canon_q, canon_cab, assinados, "UNSIGNED-PAYLOAD"])
    texto = "\n".join(["GOOG4-RSA-SHA256", instante, escopo, hashlib.sha256(req.encode()).hexdigest()])
    assinatura = assinar(texto.encode()).hex()
    return f"https://{host}{recurso}?{canon_q}&X-Goog-Signature={assinatura}"


def assinador_iam(sessao, conta: str):
    """Assina pelo IAM Credentials (a conta precisa de roles/iam.serviceAccountTokenCreator sobre si)."""
    def assinar(dados: bytes) -> bytes:
        r = sessao.post(f"https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/{conta}:signBlob",
                        json={"payload": base64.b64encode(dados).decode()}, timeout=10)
        r.raise_for_status()
        return base64.b64decode(r.json()["signedBlob"])
    return assinar


class ArmazenamentoGCS:
    nuvem = "gcp"

    def __init__(self, sessao, bucket: str, conta_assinatura: str, origem: str = "gcp", assinar=None):
        self.s, self.bucket, self.conta, self.origem = sessao, bucket, conta_assinatura, origem
        self.assinar = assinar or assinador_iam(sessao, conta_assinatura)

    def _obj(self, chave):
        return f"{GCS}/storage/v1/b/{self.bucket}/o/{urllib.parse.quote(chave, safe='')}"

    def url_envio(self, chave, tamanho, ttl):
        cab = {"Content-Type": "application/pdf", "x-goog-content-length-range": f"{tamanho},{tamanho}",
               "x-goog-meta-origem": self.origem}
        url = url_assinada_v4(self.assinar, self.conta, self.bucket, chave, "PUT", ttl, cab)
        return {"metodo": "PUT", "url": url, "cabecalhos": cab}

    def url_download(self, chave, nome_arquivo, ttl):
        return url_assinada_v4(self.assinar, self.conta, self.bucket, chave, "GET", ttl, consulta={
            "response-content-disposition": f'attachment; filename="{nome_arquivo}"',
            "response-content-type": "application/pdf"})

    def _meta(self, chave):
        r = self.s.get(self._obj(chave), timeout=10)
        if r.status_code == 404:
            return None
        r.raise_for_status()
        return r.json()

    def existe(self, chave):
        return self._meta(chave) is not None

    def metadados(self, chave):
        m = self._meta(chave)
        return dict((m or {}).get("metadata") or {})

    def ler(self, chave, limite):
        r = self.s.get(self._obj(chave) + "?alt=media", headers={"Range": f"bytes=0-{limite - 1}"}, timeout=30)
        r.raise_for_status()
        return r.content

    def escrever(self, chave, dados, metadados):
        fronteira = "fronteira-docs-pacientes"
        meta = json.dumps({"name": chave, "contentType": "application/pdf", "metadata": metadados})
        corpo = (f"--{fronteira}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n{meta}\r\n"
                 f"--{fronteira}\r\nContent-Type: application/pdf\r\n\r\n").encode() + dados + f"\r\n--{fronteira}--".encode()
        r = self.s.post(f"{GCS}/upload/storage/v1/b/{self.bucket}/o?uploadType=multipart", data=corpo,
                        headers={"Content-Type": f"multipart/related; boundary={fronteira}"}, timeout=60)
        r.raise_for_status()

    def apagar(self, chave):
        r = self.s.delete(self._obj(chave), timeout=10)
        if r.status_code not in (204, 404):
            r.raise_for_status()
