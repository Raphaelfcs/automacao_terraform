"""Modelo de domínio: quem acessa (Principal) e o que é guardado (itens da tabela única).

Uma tabela lógica, igual nas duas nuvens (DynamoDB e Firestore), com chave (pk, sk):

    CLINICA#<tid>      META                  dados da clínica (tenant)
    USUARIO#<sub>      VINCULO               vínculo de um usuário da equipe: clínica e papel
    CLINICA#<tid>      PACIENTE#<pid>        paciente da clínica, ligado ao sub do pool de pacientes
    CLINICA#<tid>      DOC#<did>             metadados do PDF (o arquivo fica no S3/GCS)
    AUDITORIA#<psub>   <ts>#<id>             quem acessou documentos daquele paciente (só inserção)

Todo item carrega `atualizado_em` (ms) e `origem` (aws|gcp): é o que a replicação entre nuvens usa
para resolver conflito (último escritor vence) e para não devolver o item à nuvem de onde veio.
"""
from __future__ import annotations

import dataclasses
import re
import time
import uuid

TIPOS_DOCUMENTO = ("exame", "diagnostico", "receita")
PAPEIS_EQUIPE = ("clinica_admin", "clinica_equipe")
PAPEL_PLATAFORMA = "plataforma_admin"
STATUS_PENDENTE, STATUS_DISPONIVEL, STATUS_REJEITADO = "pendente", "disponivel", "rejeitado"
TAMANHO_MAXIMO = 20 * 1024 * 1024  # 20 MiB por PDF

_ID = re.compile(r"^[a-z0-9]{8,40}$")


class ErroDominio(Exception):
    status = 400


class NaoAutenticado(ErroDominio):
    status = 401


class Proibido(ErroDominio):
    status = 403


class NaoEncontrado(ErroDominio):
    status = 404


class Conflito(ErroDominio):
    status = 409


def novo_id() -> str:
    return uuid.uuid4().hex


def agora_ms() -> int:
    return int(time.time() * 1000)


def validar_id(valor: str, nome: str) -> str:
    """IDs entram em chaves de banco e de objeto: só [a-z0-9], para impedir path traversal e injeção."""
    if not isinstance(valor, str) or not _ID.match(valor):
        raise ErroDominio(f"{nome} inválido")
    return valor


@dataclasses.dataclass(frozen=True)
class Principal:
    """Identidade já verificada. `tipo` vem do pool que emitiu o token, nunca do corpo da requisição."""

    sub: str
    tipo: str                      # "equipe" ou "paciente"
    clinica_id: str | None = None  # só equipe
    papel: str | None = None       # clinica_admin | clinica_equipe | plataforma_admin

    @property
    def eh_paciente(self) -> bool:
        return self.tipo == "paciente"

    @property
    def eh_plataforma(self) -> bool:
        return self.tipo == "equipe" and self.papel == PAPEL_PLATAFORMA


def chave_objeto(clinica_id: str, documento_id: str) -> str:
    return f"clinicas/{validar_id(clinica_id, 'clinica_id')}/documentos/{validar_id(documento_id, 'documento_id')}.pdf"


_CHAVE_OBJETO = re.compile(r"^clinicas/([a-z0-9]{8,40})/documentos/([a-z0-9]{8,40})\.pdf$")


def ler_chave_objeto(chave: str) -> tuple[str, str]:
    m = _CHAVE_OBJETO.match(chave or "")
    if not m:
        raise ErroDominio("chave de objeto fora do padrão")
    return m.group(1), m.group(2)


def carimbar(item: dict, nuvem: str) -> dict:
    """Marca uma escrita local: origem, instante e versão, usados pela replicação.

    O instante nunca anda para trás em relação ao valor anterior do item (relógios das duas nuvens
    podem divergir alguns ms) e a versão desempata duas escritas no mesmo milissegundo.
    """
    item = dict(item)
    item["atualizado_em"] = max(agora_ms(), int(item.get("atualizado_em", 0)) + 1)
    item["versao"] = int(item.get("versao", 0)) + 1
    item["origem"] = nuvem
    return item
