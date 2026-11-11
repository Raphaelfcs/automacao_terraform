import hashlib
import os
import sys

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from docs_pacientes.adapters.memoria import ArmazenamentoMemoria, IdentidadesMemoria, RepoMemoria  # noqa: E402
from docs_pacientes.core.auditoria import AuditoriaNoRepositorio  # noqa: E402
from docs_pacientes.core.models import Principal  # noqa: E402
from docs_pacientes.core.servico import Servico  # noqa: E402

PDF_OK = b"%PDF-1.7\n1 0 obj << /Type /Catalog >> endobj\ntrailer << /Root 1 0 R >>\n%%EOF\n"


def sha(b):
    return hashlib.sha256(b).hexdigest()


class Mundo:
    """Uma nuvem em memória com uma clínica, um admin, uma pessoa da equipe e um paciente."""

    def __init__(self, nuvem="aws"):
        self.repo, self.arm, self.ids = RepoMemoria(), ArmazenamentoMemoria(nuvem), IdentidadesMemoria()
        self.s = Servico(nuvem, self.repo, self.arm, AuditoriaNoRepositorio(self.repo, nuvem), self.ids)
        self.plataforma = Principal(sub="plat0001" + "0" * 24, tipo="equipe", papel="plataforma_admin")

    def clinica(self, nome="Clínica A"):
        c = self.s.criar_clinica(self.plataforma, nome)
        adm = self.s.vincular_equipe(self.plataforma, c["clinica_id"], f"adm@{nome[-1].lower()}.com", "Admin", "clinica_admin")
        p_adm = Principal(sub=adm["sub"], tipo="equipe", clinica_id=c["clinica_id"], papel="clinica_admin")
        return c["clinica_id"], p_adm

    def documento(self, equipe, paciente_id, dados=PDF_OK, tipo="exame"):
        r = self.s.solicitar_envio(equipe, paciente_id, tipo, "Hemograma", len(dados), sha(dados))
        did = r["documento"]["documento_id"]
        chave = f"clinicas/{equipe.clinica_id}/documentos/{did}.pdf"
        self.arm.escrever(chave, dados, {})
        return did, chave


@pytest.fixture
def mundo():
    return Mundo()
