"""Montagem do serviço a partir de variáveis de ambiente (preenchidas pelo Terraform).

Comuns:      NUVEM (aws|gcp), EMISSORES (JSON), COGNITO_REGIAO, COGNITO_POOL_EQUIPE, COGNITO_POOL_PACIENTE
AWS:         TABELA, BUCKET, GCP_PROJETO, GCP_BANCO, GCP_BUCKET, GCP_CONTA_ASSINATURA, GCP_CRED_CONFIG
GCP:         GCP_PROJETO, GCP_BANCO, GCP_BUCKET, GCP_CONTA_ASSINATURA, AWS_ROLE_FEDERADA, AWS_REGIAO, TABELA, BUCKET
"""
from __future__ import annotations

import functools
import json
import os

from .core.auditoria import AuditoriaNoRepositorio
from .core.autenticacao import Emissor, Verificador, principal
from .core.replicacao import Replicador
from .core.servico import Servico


def _env(nome, padrao=None):
    v = os.environ.get(nome, padrao)
    if v is None:
        raise RuntimeError(f"variável de ambiente ausente: {nome}")
    return v


class Contexto:
    """Cria os clientes uma vez por instância (Lambda/Cloud Run reaproveitam entre requisições)."""

    def __init__(self):
        self.nuvem = _env("NUVEM")

    # ------------------------------------------------------------- clientes por nuvem
    @functools.cached_property
    def _boto(self):
        import boto3
        if self.nuvem == "aws":
            return boto3.Session()
        from .adapters.federacao import sessao_aws_federada
        return sessao_aws_federada(_env("AWS_ROLE_FEDERADA"), _env("AWS_REGIAO"))

    @functools.cached_property
    def _google(self):
        from .adapters.federacao import sessao_google
        return sessao_google(os.environ.get("GCP_CRED_CONFIG") if self.nuvem == "aws" else None)

    @functools.cached_property
    def repo_aws(self):
        from .adapters.aws import RepoDynamo
        return RepoDynamo(self._boto.resource("dynamodb").Table(_env("TABELA")))

    @functools.cached_property
    def repo_gcp(self):
        from .adapters.gcp import RepoFirestore
        return RepoFirestore(self._google, _env("GCP_PROJETO"), _env("GCP_BANCO", "(default)"))

    @functools.cached_property
    def arm_aws(self):
        from botocore.config import Config

        from .adapters.aws import ArmazenamentoS3
        s3 = self._boto.client("s3", config=Config(signature_version="s3v4", s3={"addressing_style": "virtual"}))
        return ArmazenamentoS3(s3, _env("BUCKET"))

    @functools.cached_property
    def arm_gcp(self):
        from .adapters.gcp import ArmazenamentoGCS
        return ArmazenamentoGCS(self._google, _env("GCP_BUCKET"), _env("GCP_CONTA_ASSINATURA"))

    # ------------------------------------------------------------- local x remoto
    @property
    def repo(self):
        return self.repo_aws if self.nuvem == "aws" else self.repo_gcp

    @property
    def repo_remoto(self):
        return self.repo_gcp if self.nuvem == "aws" else self.repo_aws

    @property
    def arm(self):
        return self.arm_aws if self.nuvem == "aws" else self.arm_gcp

    @property
    def arm_remoto(self):
        return self.arm_gcp if self.nuvem == "aws" else self.arm_aws

    @functools.cached_property
    def identidades(self):
        from .adapters.aws import IdentidadesCognito
        return IdentidadesCognito(self._boto.client("cognito-idp", region_name=_env("COGNITO_REGIAO")),
                                  {"equipe": _env("COGNITO_POOL_EQUIPE"), "paciente": _env("COGNITO_POOL_PACIENTE")})

    @functools.cached_property
    def verificador(self):
        emissores = [Emissor(e["iss"], e["tipo"], tuple(e["client_ids"])) for e in json.loads(_env("EMISSORES"))]
        return Verificador(emissores)

    # ------------------------------------------------------------- usados pelo roteador e eventos
    def principal(self, token: str):
        emissor, claims = self.verificador.verificar(token)
        return principal(emissor, claims, self.repo)

    @functools.lru_cache(maxsize=1)
    def servico(self) -> Servico:
        return Servico(self.nuvem, self.repo, self.arm, AuditoriaNoRepositorio(self.repo, self.nuvem),
                       self.identidades, self.arm_remoto)

    @functools.cached_property
    def replicador(self) -> Replicador:
        return Replicador(self.nuvem, self.repo_remoto, self.arm, self.arm_remoto)
