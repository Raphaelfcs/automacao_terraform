"""Auditoria semanal de MFA de usuários IAM com acesso ao console.

Lista usuários IAM com senha de console e sem dispositivo MFA e publica o relatório no SNS.
Complementa a regra gerenciada do AWS Config "IAM_USER_MFA_ENABLED" (avaliação contínua).
Para pessoas, o controle recomendado é o IAM Identity Center com MFA obrigatório em todo
login (configuração da instância), e não usuários IAM.
"""
import json
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

TOPIC_ARN = os.environ["TOPIC_ARN"]
iam = boto3.client("iam")
sns = boto3.client("sns")


def iam_users_without_mfa():
    out = []
    for page in iam.get_paginator("list_users").paginate():
        for user in page["Users"]:
            name = user["UserName"]
            try:
                iam.get_login_profile(UserName=name)
            except iam.exceptions.NoSuchEntityException:
                continue  # sem console: MFA de console não se aplica
            if not iam.list_mfa_devices(UserName=name)["MFADevices"]:
                out.append({"usuario": name, "criado_em": user["CreateDate"].isoformat()})
    return out


def lambda_handler(_event, _context):
    findings = iam_users_without_mfa()
    log.info("usuarios_sem_mfa=%s", len(findings))
    if findings:
        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject=f"[MFA] {len(findings)} usuario(s) IAM sem MFA",
            Message=json.dumps(findings, indent=2, ensure_ascii=False),
        )
    return {"usuarios_sem_mfa": findings}
