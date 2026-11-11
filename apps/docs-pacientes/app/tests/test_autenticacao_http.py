import json
import time

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa

from conftest import Mundo
from docs_pacientes.core.autenticacao import Emissor, Verificador, principal
from docs_pacientes.core.models import NaoAutenticado, Proibido
from docs_pacientes.entry.http import tratar

ISS_EQ = "https://cognito-idp.sa-east-1.amazonaws.com/sa-east-1_Equipe"
ISS_PAC = "https://cognito-idp.sa-east-1.amazonaws.com/sa-east-1_Paciente"
CHAVE = rsa.generate_private_key(public_exponent=65537, key_size=2048)
OUTRA = rsa.generate_private_key(public_exponent=65537, key_size=2048)


def jwks():
    k = json.loads(jwt.algorithms.RSAAlgorithm.to_jwk(CHAVE.public_key()))
    return {"keys": [{**k, "kid": "k1", "alg": "RS256", "use": "sig"}]}


def token(iss=ISS_PAC, sub="pac-1", client="web-pac", uso="access", exp=600, chave=CHAVE, kid="k1", alg="RS256"):
    agora = int(time.time())
    claims = {"iss": iss, "sub": sub, "client_id": client, "token_use": uso, "iat": agora, "exp": agora + exp}
    return jwt.encode(claims, chave, algorithm=alg, headers={"kid": kid})


def verificador():
    return Verificador([Emissor(ISS_EQ, "equipe", ("web-eq",)), Emissor(ISS_PAC, "paciente", ("web-pac",))],
                       buscar_jwks=lambda url: jwks())


def test_token_valido_de_paciente():
    e, c = verificador().verificar(token())
    assert e.tipo == "paciente" and c["sub"] == "pac-1"


@pytest.mark.parametrize("tok", [
    token(exp=-120),                         # expirado
    token(uso="id"),                         # id token não serve
    token(client="outro-app"),               # app cliente não autorizado
    token(iss="https://evil.example/pool"),  # emissor desconhecido
    token(chave=OUTRA),                      # assinatura de outra chave
    token(kid="k-inexistente"),
    "nao.e.jwt",
    "",
])
def test_tokens_recusados(tok):
    with pytest.raises(NaoAutenticado):
        verificador().verificar(tok)


def test_alg_none_e_hs256_recusados():
    claims = {"iss": ISS_PAC, "sub": "x", "client_id": "web-pac", "token_use": "access", "iat": 1, "exp": 9999999999}
    for t in (jwt.encode(claims, None, algorithm="none"), jwt.encode(claims, "segredo-qualquer-com-32-bytes-ok!", algorithm="HS256")):
        with pytest.raises(NaoAutenticado):
            verificador().verificar(t)


def test_equipe_sem_vinculo_ativo_e_barrada():
    m = Mundo()
    with pytest.raises(Proibido):
        principal(Emissor(ISS_EQ, "equipe", ("web-eq",)), {"sub": "x"}, m.repo)
    m.repo.gravar({"pk": "USUARIO#x", "sk": "VINCULO", "clinica_id": "c" * 32, "papel": "clinica_equipe", "ativo": False})
    with pytest.raises(Proibido):
        principal(Emissor(ISS_EQ, "equipe", ("web-eq",)), {"sub": "x"}, m.repo)


def test_paciente_nao_vira_equipe_mesmo_com_vinculo():
    """O tipo vem do emissor do token: um paciente nunca ganha papel de equipe."""
    m = Mundo()
    m.repo.gravar({"pk": "USUARIO#pac-1", "sk": "VINCULO", "clinica_id": "c" * 32, "papel": "clinica_admin", "ativo": True})
    p = principal(Emissor(ISS_PAC, "paciente", ("web-pac",)), {"sub": "pac-1"}, m.repo)
    assert p.tipo == "paciente" and p.papel is None


class Ctx:
    nuvem = "aws"

    def __init__(self):
        self.m = Mundo()
        self.v = verificador()

    def principal(self, tok):
        e, c = self.v.verificar(tok)
        return principal(e, c, self.m.repo)

    def servico(self):
        return self.m.s


def test_http_saude_sem_token_e_rotas_protegidas():
    ctx = Ctx()
    st, cab, corpo = tratar("GET", "/api/health", {}, None, ctx)
    assert st == 200 and json.loads(corpo)["nuvem"] == "aws" and cab["cache-control"] == "no-store"
    assert tratar("GET", "/api/v1/eu/documentos", {}, None, ctx)[0] == 401
    assert tratar("GET", "/api/v1/eu/documentos", {"Authorization": "Bearer " + token(chave=OUTRA)}, None, ctx)[0] == 401
    assert tratar("GET", "/api/v1/nada", {}, None, ctx)[0] == 404


def test_http_paciente_lista_e_nao_acessa_rota_de_equipe():
    ctx = Ctx()
    h = {"authorization": "Bearer " + token()}
    st, _, corpo = tratar("GET", "/api/v1/eu/documentos", h, None, ctx)
    assert st == 200 and json.loads(corpo) == {"documentos": []}
    assert tratar("GET", "/api/v1/pacientes", h, None, ctx)[0] == 403
    assert tratar("POST", "/api/v1/clinicas", h, '{"nome":"x"}', ctx)[0] == 403


def test_http_corpo_invalido_e_erro_interno_sem_detalhe():
    ctx = Ctx()
    ctx.m.repo.gravar({"pk": "USUARIO#plat", "sk": "VINCULO", "papel": "plataforma_admin", "ativo": True})
    h = {"authorization": "Bearer " + token(iss=ISS_EQ, sub="plat", client="web-eq")}
    assert tratar("POST", "/api/v1/clinicas", h, "{", ctx)[0] == 400
    assert tratar("POST", "/api/v1/clinicas", h, "[1]", ctx)[0] == 400
    assert tratar("POST", "/api/v1/clinicas", h, "x" * 20000, ctx)[0] == 413
    st, _, corpo = tratar("POST", "/api/v1/clinicas", h, '{"nome":"Clínica"}', ctx)
    assert st == 201 and "clinica_id" in json.loads(corpo)

    class Quebra(Ctx):
        def servico(self):
            raise RuntimeError("segredo interno")
    st, _, corpo = tratar("POST", "/api/v1/clinicas", h, '{"nome":"x"}', Quebra())
    assert st in (401, 403, 500) and "segredo" not in corpo
