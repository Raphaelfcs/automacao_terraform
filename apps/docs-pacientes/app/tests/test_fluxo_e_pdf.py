import pytest

from conftest import PDF_OK, Mundo, sha
from docs_pacientes.core.models import ErroDominio, TAMANHO_MAXIMO
from docs_pacientes.core.pdf import PdfInvalido, validar_pdf


def test_pdf_valido_passa():
    validar_pdf(PDF_OK, len(PDF_OK), sha(PDF_OK))


@pytest.mark.parametrize("dados", [
    b"MZ\x90\x00 executavel",
    PDF_OK.replace(b"%%EOF", b""),
    PDF_OK.replace(b"/Catalog", b"/Catalog /OpenAction << /S /JavaScript /JS (app.alert(1)) >>"),
    PDF_OK.replace(b"/Catalog", b"/Catalog /OpenAction << /S /Launch /F (cmd.exe) >>"),
    PDF_OK.replace(b"/Catalog", b"/Catalog /Names << /EmbeddedFiles 2 0 R >> /EmbeddedFile"),
    PDF_OK.replace(b"/Catalog", b"/Catalog /J#61vaScript (ofuscado)"),
])
def test_pdf_perigoso_ou_invalido_e_barrado(dados):
    with pytest.raises(PdfInvalido):
        validar_pdf(dados, len(dados), sha(dados))


def test_nome_parecido_nao_e_falso_positivo():
    dados = PDF_OK.replace(b"/Catalog", b"/Catalog /JSONData 1")
    validar_pdf(dados, len(dados), sha(dados))


def test_hash_ou_tamanho_divergente_e_barrado():
    with pytest.raises(PdfInvalido):
        validar_pdf(PDF_OK, len(PDF_OK), "0" * 64)
    with pytest.raises(PdfInvalido):
        validar_pdf(PDF_OK, len(PDF_OK) + 1, sha(PDF_OK))


def test_envio_rejeitado_apaga_o_arquivo_e_marca_motivo():
    m = Mundo()
    ca, adm = m.clinica()
    pac = m.s.cadastrar_paciente(adm, "Ana", "ana@ex.com")
    r = m.s.solicitar_envio(adm, pac["paciente_id"], "receita", "Receita", len(PDF_OK), sha(PDF_OK))
    did = r["documento"]["documento_id"]
    chave = f"clinicas/{ca}/documentos/{did}.pdf"
    m.arm.escrever(chave, b"%PDF-1.7 trocado no caminho %%EOF" + b" " * 20, {})
    assert m.s.validar_objeto(chave) == "rejeitado"
    assert not m.arm.existe(chave)
    assert m.repo.obter(f"CLINICA#{ca}", f"DOC#{did}")["status"] == "rejeitado"
    assert m.s.validar_objeto(chave.replace(did, "f" * 32)) == "orfao"


def test_reprocessar_evento_e_idempotente():
    m = Mundo()
    ca, adm = m.clinica()
    pac = m.s.cadastrar_paciente(adm, "Ana", "ana@ex.com")
    _, chave = m.documento(adm, pac["paciente_id"])
    assert m.s.validar_objeto(chave) == "disponivel"
    assert m.s.validar_objeto(chave) == "ja_processado"


@pytest.mark.parametrize("campo,valor", [("tipo", "laudo"), ("tamanho", 0), ("tamanho", TAMANHO_MAXIMO + 1),
                                         ("tamanho", True), ("sha256", "xyz"), ("titulo", "")])
def test_pedido_de_envio_validado(campo, valor):
    m = Mundo()
    ca, adm = m.clinica()
    pac = m.s.cadastrar_paciente(adm, "Ana", "ana@ex.com")
    args = dict(tipo="exame", titulo="t", tamanho=10, sha256="a" * 64)
    args[campo] = valor
    with pytest.raises(ErroDominio):
        m.s.solicitar_envio(adm, pac["paciente_id"], **args)


def test_resposta_nao_expoe_campos_internos():
    m = Mundo()
    ca, adm = m.clinica()
    pac = m.s.cadastrar_paciente(adm, "Ana", "ana@ex.com")
    r = m.s.solicitar_envio(adm, pac["paciente_id"], "exame", "t", len(PDF_OK), sha(PDF_OK))
    for interno in ("pk", "sk", "chave_objeto", "origem", "sha256"):
        assert interno not in r["documento"]
