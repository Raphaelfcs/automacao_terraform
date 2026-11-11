"""Partes dos adaptadores que dá para provar sem nuvem: codificação, assinatura e formulários."""
import datetime as dt
import urllib.parse

import boto3
import pytest
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa

from docs_pacientes.adapters.aws import ArmazenamentoS3, _limpar
from docs_pacientes.adapters.gcp import de_firestore, doc_para_item, id_documento, para_firestore, url_assinada_v4
from docs_pacientes.entry.gcp_run import eventos


def test_firestore_ida_e_volta():
    item = {"pk": "CLINICA#a", "n": 7, "ativo": True, "nada": None, "x": 1.5, "lista": [1, "a"], "mapa": {"k": 2}}
    doc = {"fields": {k: para_firestore(v) for k, v in item.items()}}
    assert doc_para_item(doc) == item
    assert para_firestore(10) == {"integerValue": "10"}
    assert de_firestore({"integerValue": "10"}) == 10


def test_id_documento_sem_barra_e_estavel():
    i = id_documento("CLINICA#abc", "DOC#1/2")
    assert "/" not in i and i == id_documento("CLINICA#abc", "DOC#1/2")


def test_url_v4_tem_formato_e_assinatura_verificavel():
    chave = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    assinados = []

    def assinar(b):
        assinados.append(b)
        return chave.sign(b, padding.PKCS1v15(), hashes.SHA256())

    agora = dt.datetime(2026, 11, 11, 12, 0, 0, tzinfo=dt.timezone.utc)
    url = url_assinada_v4(assinar, "api@proj.iam.gserviceaccount.com", "docs-bkt", "clinicas/a/documentos/b.pdf", "PUT", 300,
                          {"Content-Type": "application/pdf", "x-goog-content-length-range": "10,10"}, agora=agora)
    u = urllib.parse.urlparse(url)
    q = dict(urllib.parse.parse_qsl(u.query))
    assert u.netloc == "storage.googleapis.com" and u.path == "/docs-bkt/clinicas/a/documentos/b.pdf"
    assert q["X-Goog-Algorithm"] == "GOOG4-RSA-SHA256" and q["X-Goog-Expires"] == "300"
    assert q["X-Goog-Credential"] == "api@proj.iam.gserviceaccount.com/20261111/auto/storage/goog4_request"
    assert q["X-Goog-SignedHeaders"] == "content-type;host;x-goog-content-length-range"
    texto = assinados[0].decode()
    assert texto.startswith("GOOG4-RSA-SHA256\n20261111T120000Z\n20261111/auto/storage/goog4_request\n")
    chave.public_key().verify(bytes.fromhex(q["X-Goog-Signature"]), assinados[0], padding.PKCS1v15(), hashes.SHA256())


def test_formulario_s3_limita_tamanho_tipo_e_origem():
    s3 = boto3.client("s3", region_name="sa-east-1", aws_access_key_id="AKIAEXEMPLO", aws_secret_access_key="x" * 40)
    r = ArmazenamentoS3(s3, "docs-bkt").url_envio("clinicas/a/documentos/b.pdf", 1234, 300)
    assert r["metodo"] == "POST" and r["campos"]["key"] == "clinicas/a/documentos/b.pdf"
    import base64
    import json
    politica = json.loads(base64.b64decode(r["campos"]["policy"]))
    cond = politica["conditions"]
    assert ["content-length-range", 1234, 1234] in cond
    assert {"Content-Type": "application/pdf"} in cond and {"x-amz-meta-origem": "aws"} in cond


def test_decimal_do_dynamo_vira_int():
    from decimal import Decimal
    assert _limpar({"a": Decimal("3"), "b": [Decimal("1.5")]}) == {"a": 3, "b": [1.5]}


def test_evento_desconhecido_no_cloud_run_nao_e_processado():
    assert eventos("/eventos/gcs", {"ce-type": "outro"}, b"{}")[0] == 404


@pytest.mark.parametrize("caminho", ["/api/v1/eu", "/eventos/firestore"])
def test_rotas_wsgi_respeitam_o_modo(monkeypatch, caminho):
    import io

    import docs_pacientes.entry.gcp_run as run
    monkeypatch.setattr(run, "MODO", "eventos")
    capt = {}
    corpo = b"".join(run.app({"PATH_INFO": caminho, "REQUEST_METHOD": "GET", "wsgi.input": io.BytesIO()},
                             lambda s, h: capt.setdefault("s", s)))
    assert capt["s"].startswith("404") and b"rota" in corpo
