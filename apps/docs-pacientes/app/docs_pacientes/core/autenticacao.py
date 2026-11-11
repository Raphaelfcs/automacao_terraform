"""Verificação do token (Cognito) e montagem do Principal.

Dois pools: um para a equipe das clínicas (MFA obrigatório) e outro para pacientes. O tipo do
usuário vem do emissor (iss) do token, que é assinado; papel e clínica vêm do vínculo gravado no
banco (replicado nas duas nuvens), não de atributos editáveis no IdP.

As duas nuvens verificam a assinatura com o mesmo código (PyJWT + JWKS do Cognito, em cache).
"""
from __future__ import annotations

import dataclasses
import json
import threading
import time
import urllib.request

import jwt

from .models import PAPEIS_EQUIPE, PAPEL_PLATAFORMA, NaoAutenticado, Principal, Proibido


@dataclasses.dataclass(frozen=True)
class Emissor:
    iss: str            # https://cognito-idp.<regiao>.amazonaws.com/<pool_id>
    tipo: str           # "equipe" | "paciente"
    client_ids: tuple   # app clients aceitos


class Verificador:
    """Valida assinatura RS256, emissor, expiração, token_use=access e client_id."""

    def __init__(self, emissores: list[Emissor], buscar_jwks=None, ttl_cache=3600):
        self._emissores = {e.iss: e for e in emissores}
        self._buscar = buscar_jwks or _buscar_jwks
        self._ttl = ttl_cache
        self._cache: dict[str, tuple[float, dict]] = {}
        self._trava = threading.Lock()

    def _chave(self, iss: str, kid: str, forcar=False):
        with self._trava:
            ts, jwks = self._cache.get(iss, (0, None))
            # kid desconhecido força nova leitura, no máximo uma por minuto (evita abuso com kids aleatórios)
            if jwks is None or time.time() - ts > self._ttl or (forcar and time.time() - ts > 60):
                jwks = self._buscar(f"{iss}/.well-known/jwks.json")
                self._cache[iss] = (time.time(), jwks)
        for k in jwks.get("keys", []):
            if k.get("kid") == kid:
                return jwt.PyJWK(k).key
        return None

    def verificar(self, token: str) -> tuple[Emissor, dict]:
        if not token:
            raise NaoAutenticado("token ausente")
        try:
            cab = jwt.get_unverified_header(token)
            iss = jwt.decode(token, options={"verify_signature": False}).get("iss")
        except jwt.PyJWTError as e:
            raise NaoAutenticado("token malformado") from e
        emissor = self._emissores.get(iss)
        if emissor is None or cab.get("alg") != "RS256":
            raise NaoAutenticado("emissor não aceito")
        chave = self._chave(iss, cab.get("kid")) or self._chave(iss, cab.get("kid"), forcar=True)  # rotação de chave
        if chave is None:
            raise NaoAutenticado("chave de assinatura desconhecida")
        try:
            claims = jwt.decode(token, chave, algorithms=["RS256"], issuer=iss,
                                options={"require": ["exp", "iat", "sub", "iss"], "verify_aud": False}, leeway=30)
        except jwt.PyJWTError as e:
            raise NaoAutenticado("token inválido ou expirado") from e
        if claims.get("token_use") != "access":
            raise NaoAutenticado("use o access token")
        if claims.get("client_id") not in emissor.client_ids:
            raise NaoAutenticado("aplicação cliente não aceita")
        return emissor, claims


def _buscar_jwks(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=5) as r:  # noqa: S310 (URL vem da configuração, não do usuário)
        return json.loads(r.read())


def principal(emissor: Emissor, claims: dict, repo) -> Principal:
    sub = claims["sub"]
    if emissor.tipo == "paciente":
        return Principal(sub=sub, tipo="paciente")
    vinculo = repo.obter(f"USUARIO#{sub}", "VINCULO")
    if not vinculo or not vinculo.get("ativo", False):
        raise Proibido("usuário sem vínculo ativo com uma clínica")
    papel = vinculo.get("papel")
    if papel not in PAPEIS_EQUIPE + (PAPEL_PLATAFORMA,):
        raise Proibido("papel desconhecido")
    return Principal(sub=sub, tipo="equipe", clinica_id=vinculo.get("clinica_id"), papel=papel)
