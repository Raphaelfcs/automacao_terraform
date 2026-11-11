"""Entradas AWS Lambda.

api            <- API Gateway HTTP API (payload 2.0), atrás da CloudFront em /api/*
objeto_criado  <- EventBridge "Object Created" do bucket de documentos
stream         <- DynamoDB Streams (NEW_AND_OLD_IMAGES), com falha parcial de lote
"""
from __future__ import annotations

import base64
import json
import logging
import os

from ..config import Contexto
from .http import tratar

logging.getLogger().setLevel(os.environ.get("NIVEL_LOG", "INFO"))
_ctx = None


def _contexto():
    global _ctx
    if _ctx is None:
        _ctx = Contexto()
    return _ctx


def api(event, context):
    http = event.get("requestContext", {}).get("http", {})
    corpo = event.get("body")
    if corpo and event.get("isBase64Encoded"):
        corpo = base64.b64decode(corpo)
    status, cab, saida = tratar(http.get("method", ""), event.get("rawPath", ""), event.get("headers") or {}, corpo, _contexto())
    return {"statusCode": status, "headers": cab, "body": saida}


def objeto_criado(event, context):
    chave = event["detail"]["object"]["key"]
    resultado = _contexto().servico().validar_objeto(chave)
    logging.info(json.dumps({"evento": "objeto_criado", "chave": chave, "resultado": resultado}))
    return {"resultado": resultado}


def _imagem(registro, campo):
    from boto3.dynamodb.types import TypeDeserializer

    from ..adapters.aws import _limpar
    img = registro.get("dynamodb", {}).get(campo)
    if not img:
        return None
    d = TypeDeserializer()
    return _limpar({k: d.deserialize(v) for k, v in img.items()})


def stream(event, context):
    falhas = []
    rep = _contexto().replicador
    for r in event.get("Records", []):
        try:
            resultado = rep.ao_mudar_item(_imagem(r, "NewImage"), _imagem(r, "OldImage"))
            logging.info(json.dumps({"evento": "replicacao", "resultado": resultado, "seq": r["dynamodb"]["SequenceNumber"]}))
        except Exception:  # noqa: BLE001 - reprocessa só o que falhou
            logging.exception("falha ao replicar")
            falhas.append({"itemIdentifier": r["dynamodb"]["SequenceNumber"]})
    return {"batchItemFailures": falhas}
