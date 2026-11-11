"""Replicação ativo-ativo entre AWS e GCP, orientada a eventos.

Itens: o stream do banco (DynamoDB Streams / gatilho do Firestore) entrega cada escrita local.
  - item com origem != nuvem local é uma réplica recém-chegada: não volta (sem laço);
  - item local é aplicado no banco da outra nuvem com "último escritor vence" por
    (atualizado_em, versao, origem): a mesma regra nos dois lados converge para o mesmo valor.

Arquivos: são imutáveis (uma chave por documento, nunca sobrescrita), então não há conflito.
Quando um documento local vira "disponivel", o PDF é copiado para o bucket da outra nuvem com
metadado origem=<nuvem local>; o evento de objeto criado do outro lado reconhece a réplica e não
revalida. Enquanto a cópia não chega, o download assina a URL no bucket de origem.
"""
from __future__ import annotations

from .models import STATUS_DISPONIVEL


def mais_novo(a: dict, b: dict | None) -> bool:
    """True se `a` deve substituir `b`. Desempate determinístico pela origem."""
    if b is None:
        return True
    def chave(i):
        return (int(i.get("atualizado_em", 0)), int(i.get("versao", 0)), i.get("origem", ""))
    return chave(a) > chave(b)


class Replicador:
    def __init__(self, nuvem: str, repo_remoto, arm_local, arm_remoto):
        self.nuvem = nuvem
        self.repo_remoto = repo_remoto
        self.arm_local = arm_local
        self.arm_remoto = arm_remoto

    def ao_mudar_item(self, item: dict | None, anterior: dict | None = None) -> str:
        if not item:
            return "ignorado"          # exclusão: não replicamos apagamento (retenção legal); trate por processo
        if item.get("origem") != self.nuvem:
            return "replica"           # veio da outra nuvem: não devolve
        aplicado = self.repo_remoto.gravar_se_mais_novo(item)
        copiou = False
        virou_disponivel = (item.get("sk", "").startswith("DOC#") and item.get("status") == STATUS_DISPONIVEL
                            and (anterior or {}).get("status") != STATUS_DISPONIVEL)
        if virou_disponivel and not self.arm_remoto.existe(item["chave_objeto"]):
            dados = self.arm_local.ler(item["chave_objeto"], item["tamanho"] + 1)
            self.arm_remoto.escrever(item["chave_objeto"], dados, {"origem": self.nuvem, "sha256": item["sha256"]})
            copiou = True
        return ("aplicado" if aplicado else "remoto_mais_novo") + ("+arquivo" if copiou else "")
