"""Validação de PDF antes de liberar o documento para o paciente.

Não substitui antivírus: barra o que não é PDF e os recursos que transformam um PDF em vetor de
ataque (JavaScript, ações de execução, arquivos embutidos, formulários XFA, mídia rica). Laudos,
receitas e exames legítimos não usam nada disso. Para varredura de malware, ligue o GuardDuty
Malware Protection for S3 (variável do root aws/base).
"""
from __future__ import annotations

import hashlib
import re

from .models import ErroDominio

PROIBIDOS = (b"/JavaScript", b"/JS", b"/Launch", b"/EmbeddedFile", b"/RichMedia", b"/XFA", b"/SubmitForm", b"/ImportData")
# Nomes em PDF podem ter caracteres em hexa (#4A = J): normaliza antes de procurar.
_HEX = re.compile(rb"#([0-9A-Fa-f]{2})")


class PdfInvalido(ErroDominio):
    status = 422


def _normalizar(dados: bytes) -> bytes:
    return _HEX.sub(lambda m: bytes([int(m.group(1), 16)]), dados)


def validar_pdf(dados: bytes, tamanho_declarado: int, sha256_declarado: str) -> None:
    if len(dados) != tamanho_declarado:
        raise PdfInvalido("tamanho diferente do declarado")
    if not dados.startswith(b"%PDF-"):
        raise PdfInvalido("arquivo não é PDF")
    if b"%%EOF" not in dados[-2048:]:
        raise PdfInvalido("PDF truncado")
    if hashlib.sha256(dados).hexdigest() != (sha256_declarado or "").lower():
        raise PdfInvalido("hash SHA-256 não confere")
    normal = _normalizar(dados)
    for marca in PROIBIDOS:
        # delimitador depois do nome evita falso positivo (/JSON não é /JS)
        if re.search(re.escape(marca) + rb"(?![A-Za-z0-9])", normal):
            raise PdfInvalido(f"PDF com recurso proibido: {marca.decode()}")
