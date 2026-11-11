"""Roteador HTTP único para as duas nuvens (API Gateway na AWS, Cloud Run no GCP).

Rotas (prefixo /api):
  GET  /api/health                                         sem autenticação (health check do DNS)
  GET  /api/v1/eu                                          quem sou eu
  POST /api/v1/clinicas                       plataforma   cria clínica
  POST /api/v1/clinicas/{cid}/equipe          plataforma ou admin da clínica: cria/vincula usuário
  GET  /api/v1/pacientes                      equipe       lista pacientes da clínica
  POST /api/v1/pacientes                      equipe       cadastra paciente (cria login dele)
  GET  /api/v1/pacientes/{pid}/documentos     equipe       documentos do paciente na clínica
  POST /api/v1/documentos                     equipe       pede URL de envio do PDF
  GET  /api/v1/eu/documentos                  paciente     meus documentos (todas as clínicas)
  GET  /api/v1/eu/acessos                     paciente     quem acessou meus documentos
  GET  /api/v1/documentos/{cid}/{did}/download             URL assinada de 60 s
"""
from __future__ import annotations

import json
import logging
import re
import uuid

from ..core.models import ErroDominio, NaoAutenticado

log = logging.getLogger("http")
CABECALHOS = {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",                       # dado de saúde não fica em cache intermediário
    "x-content-type-options": "nosniff",
    "strict-transport-security": "max-age=63072000; includeSubDomains; preload",
    "referrer-policy": "no-referrer",
}
MAX_CORPO = 16 * 1024

_ROTAS = [
    ("GET", r"/api/health", "saude"),
    ("GET", r"/api/v1/eu", "eu"),
    ("POST", r"/api/v1/clinicas", "criar_clinica"),
    ("POST", r"/api/v1/clinicas/(?P<cid>[a-z0-9]+)/equipe", "vincular_equipe"),
    ("GET", r"/api/v1/pacientes", "listar_pacientes"),
    ("POST", r"/api/v1/pacientes", "cadastrar_paciente"),
    ("GET", r"/api/v1/pacientes/(?P<pid>[a-z0-9]+)/documentos", "docs_paciente"),
    ("POST", r"/api/v1/documentos", "solicitar_envio"),
    ("GET", r"/api/v1/eu/documentos", "meus_documentos"),
    ("GET", r"/api/v1/eu/acessos", "meus_acessos"),
    ("GET", r"/api/v1/documentos/(?P<cid>[a-z0-9]+)/(?P<did>[a-z0-9]+)/download", "download"),
]
_COMPILADAS = [(m, re.compile(f"^{p}/?$"), n) for m, p, n in _ROTAS]


def _resposta(status: int, corpo) -> tuple[int, dict, str]:
    return status, dict(CABECALHOS), json.dumps(corpo, ensure_ascii=False)


def tratar(metodo: str, caminho: str, cabecalhos: dict, corpo: str | bytes | None, contexto) -> tuple[int, dict, str]:
    """contexto: objeto com .nuvem, .servico() e .principal(token)."""
    req_id = uuid.uuid4().hex[:12]
    h = {k.lower(): v for k, v in (cabecalhos or {}).items()}
    try:
        for m, rx, nome in _COMPILADAS:
            achou = rx.match(caminho or "")
            if achou and m == metodo:
                break
        else:
            return _resposta(404, {"erro": "rota não encontrada"})
        if nome == "saude":
            return _resposta(200, {"status": "ok", "nuvem": contexto.nuvem})
        auth = h.get("authorization", "")
        if not auth.lower().startswith("bearer "):
            raise NaoAutenticado("token ausente")
        p = contexto.principal(auth[7:].strip())
        dados = {}
        if metodo == "POST":
            if isinstance(corpo, bytes):
                corpo = corpo.decode("utf-8")
            if len(corpo or "") > MAX_CORPO:
                return _resposta(413, {"erro": "corpo grande demais"})
            try:
                dados = json.loads(corpo or "{}")
            except json.JSONDecodeError:
                return _resposta(400, {"erro": "JSON inválido"})
            if not isinstance(dados, dict):
                return _resposta(400, {"erro": "JSON deve ser um objeto"})
        s = contexto.servico()
        a = achou.groupdict()
        ip = h.get("x-forwarded-for", "").split(",")[0].strip()
        if nome == "eu":
            return _resposta(200, {"sub": p.sub, "tipo": p.tipo, "clinica_id": p.clinica_id, "papel": p.papel})
        if nome == "criar_clinica":
            return _resposta(201, s.criar_clinica(p, dados.get("nome")))
        if nome == "vincular_equipe":
            return _resposta(201, s.vincular_equipe(p, a["cid"], dados.get("email"), dados.get("nome"), dados.get("papel")))
        if nome == "listar_pacientes":
            return _resposta(200, {"pacientes": s.listar_pacientes(p)})
        if nome == "cadastrar_paciente":
            return _resposta(201, s.cadastrar_paciente(p, dados.get("nome"), dados.get("email")))
        if nome == "docs_paciente":
            return _resposta(200, {"documentos": s.documentos_do_paciente_na_clinica(p, a["pid"])})
        if nome == "solicitar_envio":
            return _resposta(201, s.solicitar_envio(p, dados.get("paciente_id"), dados.get("tipo"), dados.get("titulo"),
                                                    dados.get("tamanho"), dados.get("sha256")))
        if nome == "meus_documentos":
            return _resposta(200, {"documentos": s.meus_documentos(p)})
        if nome == "meus_acessos":
            return _resposta(200, {"acessos": s.meus_acessos(p)})
        if nome == "download":
            return _resposta(200, s.link_download(p, a["cid"], a["did"], ip))
        return _resposta(404, {"erro": "rota não encontrada"})
    except ErroDominio as e:
        log.info(json.dumps({"req": req_id, "status": e.status, "erro": type(e).__name__, "caminho": caminho}))
        return _resposta(e.status, {"erro": str(e), "req": req_id})
    except Exception:  # noqa: BLE001 - nunca devolve detalhe interno ao cliente
        log.exception(json.dumps({"req": req_id, "caminho": caminho}))
        return _resposta(500, {"erro": "erro interno", "req": req_id})
