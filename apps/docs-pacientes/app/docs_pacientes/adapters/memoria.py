"""Adaptadores em memória: testes e desenvolvimento local, com o mesmo contrato das nuvens."""
from __future__ import annotations

import copy

from ..core.models import Conflito
from ..core.replicacao import mais_novo


class RepoMemoria:
    def __init__(self):
        self.itens: dict[tuple[str, str], dict] = {}
        self.ouvintes = []  # simula o stream do banco: f(novo, anterior)

    def _emitir(self, novo, anterior):
        for f in self.ouvintes:
            f(copy.deepcopy(novo), copy.deepcopy(anterior))

    def obter(self, pk, sk):
        i = self.itens.get((pk, sk))
        return copy.deepcopy(i) if i else None

    def gravar(self, item):
        anterior = self.itens.get((item["pk"], item["sk"]))
        self.itens[(item["pk"], item["sk"])] = copy.deepcopy(item)
        self._emitir(item, anterior)

    def inserir(self, item):
        if (item["pk"], item["sk"]) in self.itens:
            raise Conflito("item já existe")
        self.gravar(item)

    def gravar_se_mais_novo(self, item):
        atual = self.itens.get((item["pk"], item["sk"]))
        if not mais_novo(item, atual):
            return False
        self.gravar(item)
        return True

    def listar_prefixo(self, pk, prefixo_sk, limite=200):
        r = [copy.deepcopy(v) for (p, s), v in sorted(self.itens.items()) if p == pk and s.startswith(prefixo_sk)]
        return r[:limite]

    def documentos_do_paciente(self, paciente_sub, limite=200):
        r = [copy.deepcopy(v) for v in self.itens.values() if v.get("paciente_sub") == paciente_sub and v["sk"].startswith("DOC#")]
        return r[:limite]


class ArmazenamentoMemoria:
    def __init__(self, nuvem):
        self.nuvem = nuvem
        self.objetos: dict[str, tuple[bytes, dict]] = {}

    def url_envio(self, chave, tamanho, ttl):
        return {"metodo": "PUT", "url": f"https://{self.nuvem}.example/{chave}?ttl={ttl}", "cabecalhos": {}}

    def url_download(self, chave, nome_arquivo, ttl):
        return f"https://{self.nuvem}.example/{chave}?download={nome_arquivo}&ttl={ttl}"

    def existe(self, chave):
        return chave in self.objetos

    def metadados(self, chave):
        return dict(self.objetos[chave][1]) if chave in self.objetos else {}

    def ler(self, chave, limite):
        return self.objetos[chave][0][:limite]

    def escrever(self, chave, dados, metadados):
        self.objetos[chave] = (bytes(dados), dict(metadados))

    def apagar(self, chave):
        self.objetos.pop(chave, None)


class IdentidadesMemoria:
    def __init__(self):
        self.usuarios: dict[tuple[str, str], str] = {}

    def criar_usuario(self, pool, email, nome):
        chave = (pool, email)
        if chave not in self.usuarios:
            self.usuarios[chave] = f"{pool[:3]}{len(self.usuarios):04d}" + "0" * 24
        return self.usuarios[chave]
