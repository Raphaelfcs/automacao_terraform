"""Exporta semanalmente o inventário IAM (usuários, grupos, roles e políticas, com os
documentos de política) para o S3 em JSON — trilha de auditoria e base para restauração.
Redesenho do antigo script de backup de usuários/grupos/roles.
"""
import datetime as dt
import json
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

BUCKET = os.environ["BUCKET"]
PREFIX = os.environ.get("PREFIX", "iam-inventario")
iam = boto3.client("iam")
s3 = boto3.client("s3")


def lambda_handler(_event, _context):
    data = iam.get_account_authorization_details(
        Filter=["User", "Group", "Role", "LocalManagedPolicy"]
    )
    result = {k: list(v) for k, v in data.items() if isinstance(v, list)}
    while data.get("IsTruncated"):
        data = iam.get_account_authorization_details(
            Filter=["User", "Group", "Role", "LocalManagedPolicy"], Marker=data["Marker"]
        )
        for k, v in data.items():
            if isinstance(v, list):
                result.setdefault(k, []).extend(v)

    stamp = dt.datetime.utcnow().strftime("%Y/%m/%d/%H%M%S")
    key = f"{PREFIX}/{stamp}.json"
    s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(result, default=str).encode("utf-8"), ContentType="application/json")
    counts = {k: len(v) for k, v in result.items()}
    log.info("inventario=%s chave=%s", counts, key)
    return {"arquivo": f"s3://{BUCKET}/{key}", "contagem": counts}
