"""Casos de uso. Iguais nas duas nuvens; só os adaptadores mudam.

Fluxo de um documento:
  1. equipe pede envio      -> item DOC pendente + URL assinada (5 min, tamanho exato, só PDF)
  2. navegador envia o PDF  -> direto ao bucket da nuvem que atendeu (a API não trafega o arquivo)
  3. evento "objeto criado" -> validar_objeto(): confere tamanho, hash e conteúdo; libera ou rejeita
  4. paciente/equipe baixa  -> URL assinada de 60 s + registro de auditoria
  5. replicação             -> item e arquivo copiados para a outra nuvem (replicacao.py)
"""
from __future__ import annotations

import re

from . import autorizacao as az
from .models import (PAPEIS_EQUIPE, STATUS_DISPONIVEL, STATUS_PENDENTE, STATUS_REJEITADO, TAMANHO_MAXIMO,
                     TIPOS_DOCUMENTO, Conflito, ErroDominio, NaoEncontrado, Principal, agora_ms, carimbar,
                     chave_objeto, ler_chave_objeto, novo_id, validar_id)
from .pdf import PdfInvalido, validar_pdf

TTL_ENVIO, TTL_DOWNLOAD = 300, 60
_EMAIL = re.compile(r"^[^@\s]{1,64}@[^@\s]{1,255}\.[^@\s]{2,}$")
_SHA = re.compile(r"^[0-9a-f]{64}$")


def _texto(valor, nome, maximo=120) -> str:
    if not isinstance(valor, str) or not valor.strip() or len(valor) > maximo:
        raise ErroDominio(f"{nome} inválido")
    return valor.strip()


def _publico(item: dict) -> dict:
    """Remove campos internos antes de responder."""
    return {k: v for k, v in item.items() if k not in ("pk", "sk", "origem", "chave_objeto", "sha256")}


class Servico:
    def __init__(self, nuvem: str, repo, armazenamento, auditoria, identidades=None, armazenamento_remoto=None):
        self.nuvem = nuvem
        self.repo = repo
        self.arm = armazenamento
        self.arm_remoto = armazenamento_remoto  # leitura de fallback enquanto a réplica não chegou
        self.aud = auditoria
        self.ids = identidades

    # ------------------------------------------------------------------ plataforma
    def criar_clinica(self, p: Principal, nome: str) -> dict:
        az.exigir_plataforma(p)
        cid = novo_id()
        item = carimbar({"pk": f"CLINICA#{cid}", "sk": "META", "clinica_id": cid, "nome": _texto(nome, "nome"),
                         "criado_em": agora_ms()}, self.nuvem)
        self.repo.inserir(item)
        return _publico(item)

    def vincular_equipe(self, p: Principal, clinica_id: str, email: str, nome: str, papel: str) -> dict:
        validar_id(clinica_id, "clinica_id")
        if p.eh_plataforma:
            if papel != "clinica_admin":
                raise ErroDominio("a plataforma só cria administradores de clínica")
        else:
            az.exigir_admin_da_clinica(p, clinica_id)
        if papel not in PAPEIS_EQUIPE:
            raise ErroDominio("papel inválido")
        if not self.repo.obter(f"CLINICA#{clinica_id}", "META"):
            raise NaoEncontrado("clínica não encontrada")
        if not _EMAIL.match(email or ""):
            raise ErroDominio("e-mail inválido")
        sub = self.ids.criar_usuario("equipe", email.lower(), _texto(nome, "nome"))
        atual = self.repo.obter(f"USUARIO#{sub}", "VINCULO")
        if atual and atual.get("clinica_id") != clinica_id and atual.get("ativo"):
            raise Conflito("usuário já vinculado a outra clínica")
        item = carimbar({"pk": f"USUARIO#{sub}", "sk": "VINCULO", "sub": sub, "clinica_id": clinica_id,
                         "papel": papel, "ativo": True, "criado_por": p.sub}, self.nuvem)
        self.repo.gravar(item)
        return {"sub": sub, "clinica_id": clinica_id, "papel": papel}

    # ------------------------------------------------------------------ pacientes
    def cadastrar_paciente(self, p: Principal, nome: str, email: str) -> dict:
        az.exigir_equipe_da_clinica(p, p.clinica_id)
        if not _EMAIL.match(email or ""):
            raise ErroDominio("e-mail inválido")
        sub = self.ids.criar_usuario("paciente", email.lower(), _texto(nome, "nome"))
        pid = novo_id()
        item = carimbar({"pk": f"CLINICA#{p.clinica_id}", "sk": f"PACIENTE#{pid}", "paciente_id": pid,
                         "clinica_id": p.clinica_id, "paciente_sub": sub, "nome": _texto(nome, "nome"),
                         "criado_por": p.sub}, self.nuvem)
        self.repo.inserir(item)
        return _publico(item)

    def listar_pacientes(self, p: Principal) -> list[dict]:
        az.exigir_equipe_da_clinica(p, p.clinica_id)
        return [_publico(i) for i in self.repo.listar_prefixo(f"CLINICA#{p.clinica_id}", "PACIENTE#")]

    # ------------------------------------------------------------------ documentos
    def solicitar_envio(self, p: Principal, paciente_id: str, tipo: str, titulo: str, tamanho, sha256: str) -> dict:
        az.exigir_equipe_da_clinica(p, p.clinica_id)
        validar_id(paciente_id, "paciente_id")
        if tipo not in TIPOS_DOCUMENTO:
            raise ErroDominio("tipo deve ser exame, diagnostico ou receita")
        if not isinstance(tamanho, int) or isinstance(tamanho, bool) or not 0 < tamanho <= TAMANHO_MAXIMO:
            raise ErroDominio("tamanho inválido (máximo 20 MiB)")
        if not _SHA.match((sha256 or "").lower()):
            raise ErroDominio("sha256 inválido")
        paciente = self.repo.obter(f"CLINICA#{p.clinica_id}", f"PACIENTE#{paciente_id}")
        if not paciente:
            raise NaoEncontrado("paciente não encontrado nesta clínica")
        did = novo_id()
        chave = chave_objeto(p.clinica_id, did)
        item = carimbar({"pk": f"CLINICA#{p.clinica_id}", "sk": f"DOC#{did}", "documento_id": did,
                         "clinica_id": p.clinica_id, "paciente_id": paciente_id, "paciente_sub": paciente["paciente_sub"],
                         "tipo": tipo, "titulo": _texto(titulo, "titulo"), "tamanho": tamanho, "sha256": sha256.lower(),
                         "status": STATUS_PENDENTE, "chave_objeto": chave, "enviado_por": p.sub,
                         "criado_em": agora_ms(), "nuvem_envio": self.nuvem}, self.nuvem)
        self.repo.inserir(item)
        self.aud.registrar({"acao": "envio_solicitado", "ator_sub": p.sub, "ator_tipo": p.tipo, "ator_clinica": p.clinica_id,
                            "paciente_sub": paciente["paciente_sub"], "clinica_id": p.clinica_id, "documento_id": did,
                            "nuvem": self.nuvem})
        return {"documento": _publico(item), "envio": self.arm.url_envio(chave, tamanho, TTL_ENVIO)}

    def documentos_do_paciente_na_clinica(self, p: Principal, paciente_id: str) -> list[dict]:
        az.exigir_equipe_da_clinica(p, p.clinica_id)
        validar_id(paciente_id, "paciente_id")
        itens = self.repo.listar_prefixo(f"CLINICA#{p.clinica_id}", "DOC#")
        return [_publico(i) for i in itens if i.get("paciente_id") == paciente_id]

    def meus_documentos(self, p: Principal) -> list[dict]:
        if not p.eh_paciente:
            raise az.Proibido("só pacientes")
        itens = self.repo.documentos_do_paciente(p.sub)
        return [_publico(i) for i in itens if i.get("status") == STATUS_DISPONIVEL and i.get("paciente_sub") == p.sub]

    def link_download(self, p: Principal, clinica_id: str, documento_id: str, ip: str = "") -> dict:
        validar_id(clinica_id, "clinica_id")
        validar_id(documento_id, "documento_id")
        doc = self.repo.obter(f"CLINICA#{clinica_id}", f"DOC#{documento_id}")
        if not doc:
            raise NaoEncontrado("documento não encontrado")
        az.pode_baixar(p, doc)
        nome = f"{doc['tipo']}-{documento_id[:8]}.pdf"
        arm = self.arm
        if not arm.existe(doc["chave_objeto"]) and self.arm_remoto is not None:
            arm = self.arm_remoto  # a cópia ainda não chegou aqui: assina na nuvem de origem
        url = arm.url_download(doc["chave_objeto"], nome, TTL_DOWNLOAD)
        self.aud.registrar({"acao": "download", "ator_sub": p.sub, "ator_tipo": p.tipo, "ator_clinica": p.clinica_id,
                            "paciente_sub": doc["paciente_sub"], "clinica_id": clinica_id, "documento_id": documento_id,
                            "ip": ip, "nuvem": self.nuvem})
        return {"url": url, "expira_em_s": TTL_DOWNLOAD}

    def meus_acessos(self, p: Principal) -> list[dict]:
        """LGPD art. 18: o paciente vê quem acessou seus documentos."""
        if not p.eh_paciente:
            raise az.Proibido("só pacientes")
        itens = self.repo.listar_prefixo(f"AUDITORIA#{p.sub}", "", limite=100)
        return [{k: v for k, v in i.items() if k not in ("pk", "sk", "ip", "origem", "atualizado_em")}
                for i in sorted(itens, key=lambda i: i["sk"], reverse=True)]

    # ------------------------------------------------------------------ eventos
    def validar_objeto(self, chave: str) -> str:
        """Chamado pelo evento de objeto criado. Idempotente: reprocessar não muda o resultado."""
        clinica_id, documento_id = ler_chave_objeto(chave)
        meta = self.arm.metadados(chave)
        if meta.get("origem") and meta["origem"] != self.nuvem:
            return "replica"  # cópia vinda da outra nuvem: já foi validada lá
        doc = self.repo.obter(f"CLINICA#{clinica_id}", f"DOC#{documento_id}")
        if not doc:
            self.arm.apagar(chave)  # objeto sem pedido de envio: não fica guardado
            return "orfao"
        if doc["status"] != STATUS_PENDENTE:
            return "ja_processado"
        try:
            dados = self.arm.ler(chave, TAMANHO_MAXIMO + 1)
            validar_pdf(dados, doc["tamanho"], doc["sha256"])
        except PdfInvalido as e:
            self.arm.apagar(chave)
            self.repo.gravar(carimbar({**doc, "status": STATUS_REJEITADO, "motivo": str(e)}, self.nuvem))
            return "rejeitado"
        self.repo.gravar(carimbar({**doc, "status": STATUS_DISPONIVEL, "validado_em": agora_ms()}, self.nuvem))
        return "disponivel"
