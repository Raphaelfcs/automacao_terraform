"""Regras de acesso. Toda decisão passa por aqui e é testada em tests/test_autorizacao.py.

- Equipe da clínica: só enxerga pacientes e documentos da PRÓPRIA clínica.
- Paciente: só enxerga documentos ligados ao SEU sub, de qualquer clínica, e só depois de validados.
- Administrador da plataforma: cria clínicas e administradores, mas NÃO lê documentos de pacientes
  (separação de funções: operar a plataforma não dá acesso a dado de saúde).
"""
from __future__ import annotations

from .models import PAPEIS_EQUIPE, STATUS_DISPONIVEL, NaoEncontrado, Principal, Proibido


def exigir_equipe_da_clinica(p: Principal, clinica_id: str) -> None:
    if p.tipo != "equipe" or p.papel not in PAPEIS_EQUIPE or p.clinica_id != clinica_id:
        raise Proibido("acesso restrito à equipe da clínica")


def exigir_admin_da_clinica(p: Principal, clinica_id: str) -> None:
    exigir_equipe_da_clinica(p, clinica_id)
    if p.papel != "clinica_admin":
        raise Proibido("acesso restrito ao administrador da clínica")


def exigir_plataforma(p: Principal) -> None:
    if not p.eh_plataforma:
        raise Proibido("acesso restrito à administração da plataforma")


def pode_baixar(p: Principal, doc: dict) -> None:
    """Documento inexistente e documento alheio respondem igual (404): não vaza existência."""
    if p.eh_paciente:
        if doc.get("paciente_sub") != p.sub or doc.get("status") != STATUS_DISPONIVEL:
            raise NaoEncontrado("documento não encontrado")
        return
    if p.tipo == "equipe" and p.papel in PAPEIS_EQUIPE and p.clinica_id == doc.get("clinica_id"):
        if doc.get("status") != STATUS_DISPONIVEL:
            raise NaoEncontrado("documento ainda não validado")
        return
    raise NaoEncontrado("documento não encontrado")
