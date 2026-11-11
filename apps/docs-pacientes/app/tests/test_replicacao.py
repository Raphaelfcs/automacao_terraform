"""Ativo-ativo: duas nuvens em memória ligadas pelos replicadores, como os streams reais."""
from conftest import Mundo
from docs_pacientes.core.models import Principal
from docs_pacientes.core.replicacao import Replicador, mais_novo
from docs_pacientes.core.servico import Servico


def par():
    aws, gcp = Mundo("aws"), Mundo("gcp")
    # cada serviço sabe assinar na outra nuvem enquanto a cópia não chega
    aws.s.arm_remoto, gcp.s.arm_remoto = gcp.arm, aws.arm
    rep_aws = Replicador("aws", gcp.repo, aws.arm, gcp.arm)
    rep_gcp = Replicador("gcp", aws.repo, gcp.arm, aws.arm)
    log = []
    aws.repo.ouvintes.append(lambda n, a: log.append(("aws", rep_aws.ao_mudar_item(n, a))))
    gcp.repo.ouvintes.append(lambda n, a: log.append(("gcp", rep_gcp.ao_mudar_item(n, a))))
    return aws, gcp, log


def test_escritas_nas_duas_nuvens_convergem_sem_laco():
    aws, gcp, log = par()
    ca, adm = aws.clinica("Clínica A")
    pac = aws.s.cadastrar_paciente(adm, "Maria", "maria@ex.com")
    # a mesma clínica atendida pelo GCP (DNS mandou a próxima requisição para lá)
    gcp.ids = aws.ids
    gcp.s.ids = aws.ids
    did, chave = gcp.documento(adm, pac["paciente_id"])
    assert gcp.s.validar_objeto(chave) == "disponivel"
    assert aws.repo.itens.keys() == gcp.repo.itens.keys()
    assert aws.repo.obter(f"CLINICA#{ca}", f"DOC#{did}")["status"] == "disponivel"
    # o arquivo foi copiado para a AWS marcado como réplica, e a AWS não o revalida
    assert aws.arm.metadados(chave)["origem"] == "gcp"
    assert aws.s.validar_objeto(chave) == "replica"
    # sem laço: toda réplica recebida foi reconhecida e parada
    assert ("aws", "replica") in log and ("gcp", "replica") in log
    assert len(log) < 40


def test_download_na_outra_nuvem_antes_da_copia_assina_na_origem():
    aws, gcp, _ = par()
    ca, adm = aws.clinica()
    pac = aws.s.cadastrar_paciente(adm, "Maria", "maria@ex.com")
    did, chave = aws.documento(adm, pac["paciente_id"])
    aws.s.validar_objeto(chave)
    gcp.arm.apagar(chave)                                   # simula cópia atrasada
    maria = Principal(sub=pac["paciente_sub"], tipo="paciente")
    assert gcp.s.link_download(maria, ca, did)["url"].startswith("https://aws.example/")


def test_ultimo_escritor_vence_e_e_deterministico():
    a = {"pk": "x", "sk": "y", "atualizado_em": 10, "origem": "aws", "v": 1}
    b = {"pk": "x", "sk": "y", "atualizado_em": 10, "origem": "gcp", "v": 2}
    assert mais_novo(b, a) and not mais_novo(a, b)
    c = {**a, "atualizado_em": 11}
    assert mais_novo(c, b)
    assert mais_novo(a, None)


def test_replica_atrasada_nao_sobrescreve_valor_mais_novo():
    aws, gcp, _ = par()
    velho = {"pk": "CLINICA#c1", "sk": "META", "nome": "velho", "atualizado_em": 1, "origem": "gcp"}
    novo = {"pk": "CLINICA#c1", "sk": "META", "nome": "novo", "atualizado_em": 2, "origem": "aws"}
    aws.repo.gravar(novo)
    assert aws.repo.gravar_se_mais_novo(velho) is False
    assert aws.repo.obter("CLINICA#c1", "META")["nome"] == "novo"
    assert gcp.repo.obter("CLINICA#c1", "META")["nome"] == "novo"


def test_exclusao_nao_e_replicada():
    rep = Replicador("aws", None, None, None)
    assert rep.ao_mudar_item(None, {"pk": "a"}) == "ignorado"
    assert isinstance(Servico, type)
