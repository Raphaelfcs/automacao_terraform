"""Entradas Cloud Run (WSGI, sem framework). A mesma imagem roda em dois serviços:

MODO=api      público só pelo Load Balancer (ingress interno + LB), atende /api/*
MODO=eventos  privado (ingress interno, invocado só pela conta do Eventarc):
              POST /eventos/gcs        google.cloud.storage.object.v1.finalized
              POST /eventos/firestore  google.cloud.firestore.document.v1.written (JSON)
"""
from __future__ import annotations

import json
import logging
import os

from ..adapters.gcp import doc_para_item
from ..config import Contexto
from .http import tratar

logging.basicConfig(level=os.environ.get("NIVEL_LOG", "INFO"), format="%(message)s")
MODO = os.environ.get("MODO", "api")
_ctx = None
_STATUS = {200: "200 OK", 201: "201 Created", 204: "204 No Content", 400: "400 Bad Request", 401: "401 Unauthorized",
           403: "403 Forbidden", 404: "404 Not Found", 409: "409 Conflict", 413: "413 Payload Too Large",
           422: "422 Unprocessable Entity", 500: "500 Internal Server Error"}


def _contexto():
    global _ctx
    if _ctx is None:
        _ctx = Contexto()
    return _ctx


def _ler_corpo(environ, limite=1024 * 1024):
    tam = int(environ.get("CONTENT_LENGTH") or 0)
    return environ["wsgi.input"].read(min(tam, limite)) if tam else b""


def _cabecalhos(environ):
    h = {k[5:].replace("_", "-").lower(): v for k, v in environ.items() if k.startswith("HTTP_")}
    if environ.get("CONTENT_TYPE"):
        h["content-type"] = environ["CONTENT_TYPE"]
    return h


def eventos(caminho: str, cab: dict, corpo: bytes):
    tipo = cab.get("ce-type", "")
    dados = json.loads(corpo or b"{}")
    if caminho == "/eventos/gcs" and tipo == "google.cloud.storage.object.v1.finalized":
        return 200, {"resultado": _contexto().servico().validar_objeto(dados["name"])}
    if caminho == "/eventos/firestore" and tipo == "google.cloud.firestore.document.v1.written":
        novo = doc_para_item(dados["value"]) if dados.get("value") else None
        antigo = doc_para_item(dados["oldValue"]) if dados.get("oldValue") else None
        return 200, {"resultado": _contexto().replicador.ao_mudar_item(novo, antigo)}
    return 404, {"erro": "evento não reconhecido"}


def app(environ, start_response):
    caminho, metodo = environ.get("PATH_INFO", ""), environ.get("REQUEST_METHOD", "")
    cab, corpo = _cabecalhos(environ), _ler_corpo(environ)
    if MODO == "eventos":
        if metodo != "POST" or not caminho.startswith("/eventos/"):
            status, saida, h = 404, json.dumps({"erro": "rota não encontrada"}), {"content-type": "application/json"}
        else:
            # Erro aqui devolve 500: o Eventarc/Pub/Sub reentrega até cair na DLQ do gatilho.
            status, corpo_r = eventos(caminho, cab, corpo)
            saida, h = json.dumps(corpo_r), {"content-type": "application/json"}
            logging.info(json.dumps({"evento": caminho, **corpo_r}))
    else:
        status, h, saida = tratar(metodo, caminho, cab, corpo, _contexto())
    start_response(_STATUS.get(status, f"{status} Status"), list(h.items()))
    return [saida.encode("utf-8")]
