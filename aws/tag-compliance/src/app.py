"""Conformidade de tags na criação de recursos (EC2 e RDS).

Disparada pelo EventBridge a partir de eventos do CloudTrail (RunInstances, CreateDBInstance,
CreateDBCluster). Para cada recurso criado:
  1. aplica a tag de dono (quem criou) — antigo "ec2_autotag";
  2. valida as tags obrigatórias e, se faltar alguma, notifica no SNS;
  3. opcionalmente PARA o recurso não conforme (modo ENFORCE) — antigo "stop RDS sem tag".

Evolução: a prevenção definitiva é a SCP "exigir-tags-na-criacao" (módulo organizations-scp);
esta função cobre contas fora da Organization e dá visibilidade/auto-correção.
"""
import json
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

REQUIRED_TAGS = [t.strip() for t in os.environ["REQUIRED_TAGS"].split(",") if t.strip()]
OWNER_TAG = os.environ.get("OWNER_TAG", "CriadoPor")
MODE = os.environ.get("MODE", "NOTIFY")  # NOTIFY | ENFORCE
TOPIC_ARN = os.environ["TOPIC_ARN"]

ec2 = boto3.client("ec2")
rds = boto3.client("rds")
sns = boto3.client("sns")


def _creator(detail):
    ident = detail.get("userIdentity", {})
    if ident.get("type") in ("IAMUser", "Root"):
        return ident.get("userName", "root")
    return ident.get("principalId", "desconhecido").split(":")[-1]


def _ec2_instances(detail):
    items = detail.get("responseElements", {}).get("instancesSet", {}).get("items", [])
    return [i["instanceId"] for i in items if "instanceId" in i]


def _check_ec2(instance_ids, creator):
    findings = []
    ec2.create_tags(Resources=instance_ids, Tags=[{"Key": OWNER_TAG, "Value": creator}])
    desc = ec2.describe_instances(InstanceIds=instance_ids)
    for res in desc["Reservations"]:
        for inst in res["Instances"]:
            tags = {t["Key"]: t["Value"] for t in inst.get("Tags", [])}
            missing = [t for t in REQUIRED_TAGS if not tags.get(t)]
            if missing:
                findings.append({"recurso": inst["InstanceId"], "tipo": "ec2", "faltando": missing})
    if findings and MODE == "ENFORCE":
        ec2.stop_instances(InstanceIds=[f["recurso"] for f in findings])
    return findings


def _check_rds(detail, creator):
    arn = detail.get("responseElements", {}).get("dBInstanceArn") or detail.get("responseElements", {}).get("dBClusterArn")
    if not arn:
        return []
    rds.add_tags_to_resource(ResourceName=arn, Tags=[{"Key": OWNER_TAG, "Value": creator}])
    tags = {t["Key"]: t["Value"] for t in rds.list_tags_for_resource(ResourceName=arn)["TagList"]}
    missing = [t for t in REQUIRED_TAGS if not tags.get(t)]
    if not missing:
        return []
    # Instância recém-criada fica em "creating": o stop é feito pela varredura periódica.
    return [{"recurso": arn, "tipo": "rds", "faltando": missing}]


def lambda_handler(event, _context):
    detail = event.get("detail", {})
    name = detail.get("eventName")
    creator = _creator(detail)
    log.info("evento=%s criador=%s", name, creator)

    if name == "RunInstances":
        findings = _check_ec2(_ec2_instances(detail), creator)
    elif name in ("CreateDBInstance", "CreateDBCluster"):
        findings = _check_rds(detail, creator)
    else:
        return {"ignorado": name}

    if findings:
        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject=f"[tags] {len(findings)} recurso(s) sem tags obrigatorias",
            Message=json.dumps({"criador": creator, "modo": MODE, "achados": findings}, indent=2, ensure_ascii=False),
        )
    return {"achados": findings}
