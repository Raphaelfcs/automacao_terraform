"""Credenciais entre nuvens sem chave fixa.

- GCP -> AWS: o Cloud Run pede ao metadata server um ID token assinado pelo Google para a sua
  conta de serviço (audience sts.amazonaws.com) e troca por credencial temporária da role IAM com
  AssumeRoleWithWebIdentity. A trust policy da role confere azp/sub = ID único da conta de serviço.
- AWS -> GCP: a Lambda usa Workload Identity Federation: a google-auth assina uma chamada
  GetCallerIdentity com a credencial da role da Lambda e troca por token do GCP (config
  "external_account" gerada pelo Terraform, sem segredo dentro).
"""
from __future__ import annotations

import datetime as dt
import json
import urllib.request

METADATA = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity"


def token_google(audiencia: str = "sts.amazonaws.com") -> str:
    url = f"{METADATA}?audience={audiencia}&format=full"
    req = urllib.request.Request(url, headers={"Metadata-Flavor": "Google"})
    with urllib.request.urlopen(req, timeout=5) as r:  # noqa: S310 (endereço fixo do metadata server)
        return r.read().decode()


def sessao_aws_federada(role_arn: str, regiao: str, nome_sessao: str = "docs-pacientes-gcp"):
    import boto3
    from botocore.credentials import RefreshableCredentials
    from botocore.session import get_session

    def renovar():
        sts = boto3.client("sts", region_name=regiao)
        c = sts.assume_role_with_web_identity(RoleArn=role_arn, RoleSessionName=nome_sessao,
                                              WebIdentityToken=token_google(), DurationSeconds=3600)["Credentials"]
        return {"access_key": c["AccessKeyId"], "secret_key": c["SecretAccessKey"], "token": c["SessionToken"],
                "expiry_time": c["Expiration"].astimezone(dt.timezone.utc).isoformat()}

    cred = RefreshableCredentials.create_from_metadata(metadata=renovar(), refresh_using=renovar, method="assume-role-with-web-identity")
    bs = get_session()
    bs._credentials = cred  # noqa: SLF001 (forma suportada de injetar credenciais renováveis)
    bs.set_config_variable("region", regiao)
    return boto3.Session(botocore_session=bs)


def sessao_google(config_externa_json: str | None = None):
    """No GCP: credencial padrão do Cloud Run. Na AWS: config external_account (WIF)."""
    import google.auth
    from google.auth.transport.requests import AuthorizedSession

    escopos = ["https://www.googleapis.com/auth/cloud-platform"]
    if config_externa_json:
        cred, _ = google.auth.load_credentials_from_dict(json.loads(config_externa_json), scopes=escopos)
    else:
        cred, _ = google.auth.default(scopes=escopos)
    return AuthorizedSession(cred)
