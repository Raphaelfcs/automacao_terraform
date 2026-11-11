"""Portas (interfaces) que cada nuvem implementa. O núcleo só conhece estas assinaturas."""
from __future__ import annotations

from typing import Iterable, Protocol


class Repositorio(Protocol):
    def obter(self, pk: str, sk: str) -> dict | None: ...

    def gravar(self, item: dict) -> None:
        """Grava incondicionalmente (escrita local já carimbada)."""

    def inserir(self, item: dict) -> None:
        """Grava só se (pk, sk) não existe. Lança Conflito se existir."""

    def gravar_se_mais_novo(self, item: dict) -> bool:
        """Réplica: grava se o item recebido for mais novo que o local (último escritor vence)."""

    def listar_prefixo(self, pk: str, prefixo_sk: str, limite: int = 200) -> list[dict]: ...

    def documentos_do_paciente(self, paciente_sub: str, limite: int = 200) -> list[dict]: ...


class Armazenamento(Protocol):
    nuvem: str

    def url_envio(self, chave: str, tamanho: int, ttl: int) -> dict:
        """Formulário/URL assinada para o navegador enviar o PDF direto ao bucket."""

    def url_download(self, chave: str, nome_arquivo: str, ttl: int) -> str: ...

    def existe(self, chave: str) -> bool: ...

    def metadados(self, chave: str) -> dict: ...

    def ler(self, chave: str, limite: int) -> bytes: ...

    def escrever(self, chave: str, dados: bytes, metadados: dict) -> None: ...

    def apagar(self, chave: str) -> None: ...


class Identidades(Protocol):
    def criar_usuario(self, pool: str, email: str, nome: str) -> str:
        """Cria (ou reaproveita) o usuário e devolve o sub. pool: 'equipe' ou 'paciente'."""


class Auditoria(Protocol):
    def registrar(self, evento: dict) -> None: ...


Itens = Iterable[dict]
