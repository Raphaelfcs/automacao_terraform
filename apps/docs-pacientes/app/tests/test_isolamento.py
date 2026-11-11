"""O que mais importa: ninguém vê documento de outra clínica nem de outro paciente."""
import pytest

from conftest import PDF_OK, Mundo
from docs_pacientes.core.models import ErroDominio, NaoEncontrado, Principal, Proibido


def preparar():
    m = Mundo()
    ca, adm_a = m.clinica("Clínica A")
    cb, adm_b = m.clinica("Clínica B")
    pac = m.s.cadastrar_paciente(adm_a, "Maria", "maria@ex.com")
    did, chave = m.documento(adm_a, pac["paciente_id"])
    assert m.s.validar_objeto(chave) == "disponivel"
    maria = Principal(sub=pac["paciente_sub"], tipo="paciente")
    return m, ca, adm_a, cb, adm_b, pac, did, maria


def test_paciente_ve_e_baixa_o_proprio_documento():
    m, ca, *_ , did, maria = preparar()
    docs = m.s.meus_documentos(maria)
    assert [d["documento_id"] for d in docs] == [did]
    assert "url" in m.s.link_download(maria, ca, did)


def test_outro_paciente_recebe_404_e_nao_403():
    m, ca, adm_a, *_ , did, _ = preparar()
    joao = m.s.cadastrar_paciente(adm_a, "João", "joao@ex.com")
    p_joao = Principal(sub=joao["paciente_sub"], tipo="paciente")
    assert m.s.meus_documentos(p_joao) == []
    with pytest.raises(NaoEncontrado):
        m.s.link_download(p_joao, ca, did)


def test_equipe_de_outra_clinica_nao_lista_nem_baixa():
    m, ca, adm_a, cb, adm_b, pac, did, _ = preparar()
    with pytest.raises(NaoEncontrado):
        m.s.link_download(adm_b, ca, did)
    # o paciente da clínica A não existe para a clínica B
    with pytest.raises(NaoEncontrado):
        m.s.solicitar_envio(adm_b, pac["paciente_id"], "exame", "x", len(PDF_OK), "a" * 64)
    assert m.s.documentos_do_paciente_na_clinica(adm_b, pac["paciente_id"]) == []
    assert all(p["clinica_id"] == cb for p in m.s.listar_pacientes(adm_b))


def test_plataforma_nao_le_documento_de_paciente():
    m, ca, *_ , did, _ = preparar()
    with pytest.raises(NaoEncontrado):
        m.s.link_download(m.plataforma, ca, did)
    with pytest.raises(Proibido):
        m.s.listar_pacientes(m.plataforma)


def test_equipe_comum_nao_cria_usuarios_e_plataforma_so_cria_admin():
    m, ca, adm_a, *_ = preparar()
    equipe = m.s.vincular_equipe(adm_a, ca, "rec@a.com", "Recepção", "clinica_equipe")
    p_eq = Principal(sub=equipe["sub"], tipo="equipe", clinica_id=ca, papel="clinica_equipe")
    with pytest.raises(Proibido):
        m.s.vincular_equipe(p_eq, ca, "x@a.com", "X", "clinica_admin")
    with pytest.raises(ErroDominio):
        m.s.vincular_equipe(m.plataforma, ca, "y@a.com", "Y", "clinica_equipe")


def test_admin_nao_vincula_usuario_em_outra_clinica():
    m, ca, adm_a, cb, *_ = preparar()
    with pytest.raises(Proibido):
        m.s.vincular_equipe(adm_a, cb, "z@b.com", "Z", "clinica_equipe")


def test_documento_pendente_ou_rejeitado_nao_aparece_para_ninguem():
    m, ca, adm_a, cb, adm_b, pac, _, maria = preparar()
    did2, _ = m.documento(adm_a, pac["paciente_id"])          # enviado, ainda não validado
    assert did2 not in [d["documento_id"] for d in m.s.meus_documentos(maria)]
    with pytest.raises(NaoEncontrado):
        m.s.link_download(maria, ca, did2)
    with pytest.raises(NaoEncontrado):
        m.s.link_download(adm_a, ca, did2)


def test_ids_com_caracteres_de_caminho_sao_recusados():
    m, ca, adm_a, *_ , maria = preparar()
    for ruim in ["../x", "ABC", "a/b", "", "x" * 50]:
        with pytest.raises(ErroDominio):
            m.s.link_download(maria, ruim, "a" * 32)


def test_paciente_ve_quem_acessou_seus_documentos():
    m, ca, adm_a, *_ , did, maria = preparar()
    m.s.link_download(adm_a, ca, did, ip="203.0.113.10")
    acessos = m.s.meus_acessos(maria)
    downloads = [a for a in acessos if a["acao"] == "download"]
    assert downloads and downloads[0]["ator_sub"] == adm_a.sub
    assert "ip" not in downloads[0]                     # IP fica só para a equipe de segurança
    assert any(a["acao"] == "envio_solicitado" for a in acessos)


def test_auditoria_e_so_insercao():
    m, ca, adm_a, *_ , did, maria = preparar()
    m.s.link_download(maria, ca, did)
    item = next(v for (pk, _), v in m.repo.itens.items() if pk.startswith("AUDITORIA#"))
    with pytest.raises(Exception):
        m.repo.inserir(item)


def test_acessos_mostram_os_mais_recentes_primeiro():
    m, ca, adm_a, *_ , did, maria = preparar()
    for _ in range(3):
        m.s.link_download(maria, ca, did)
    acessos = m.s.meus_acessos(maria)
    assert [a["em"] for a in acessos] == sorted((a["em"] for a in acessos), reverse=True)
    assert "versao" not in acessos[0]
