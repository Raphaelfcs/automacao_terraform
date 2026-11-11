"""Trilha de auditoria: um item por acesso, só inserção (a role da aplicação não pode alterar nem apagar).

Gravada no mesmo banco (chave AUDITORIA#<sub do paciente>) para o paciente consultar quem viu
seus documentos, e replicada como qualquer item. Também sai em log estruturado (tipo=auditoria),
que o CloudWatch/Cloud Logging retêm e exportam para o bucket com retenção travada.
"""
from __future__ import annotations

import json
import logging

from .models import agora_ms, carimbar, novo_id

log = logging.getLogger("auditoria")


class AuditoriaNoRepositorio:
    def __init__(self, repo, nuvem: str):
        self.repo, self.nuvem = repo, nuvem

    def registrar(self, evento: dict) -> None:
        ts = agora_ms()
        item = carimbar({"pk": f"AUDITORIA#{evento['paciente_sub']}", "sk": f"{ts:015d}#{novo_id()}",
                         "em": ts, **evento}, self.nuvem)
        self.repo.inserir(item)
        log.info(json.dumps({"tipo": "auditoria", **{k: v for k, v in item.items() if k not in ("pk", "sk")}}))
