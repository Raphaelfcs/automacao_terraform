"""Liga/desliga EC2 e RDS fora do horário comercial com base em tag (FinOps).

Recursos com a tag <SCHEDULE_TAG>=<valor> são parados no evento "stop" e iniciados no
"start". O evento vem do EventBridge Scheduler: {"action": "start"|"stop"}.
Instâncias de Auto Scaling e membros de cluster Aurora são ignorados (gerencie pelo grupo).
"""
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

TAG = os.environ.get("SCHEDULE_TAG", "Agenda")
VALUE = os.environ.get("SCHEDULE_VALUE", "horario-comercial")
DRY_RUN = os.environ.get("DRY_RUN", "false") == "true"

ec2 = boto3.client("ec2")
rds = boto3.client("rds")


def _ec2_targets(state):
    pages = ec2.get_paginator("describe_instances").paginate(
        Filters=[{"Name": f"tag:{TAG}", "Values": [VALUE]}, {"Name": "instance-state-name", "Values": [state]}]
    )
    ids = []
    for page in pages:
        for res in page["Reservations"]:
            for inst in res["Instances"]:
                tags = {t["Key"] for t in inst.get("Tags", [])}
                if "aws:autoscaling:groupName" not in tags:
                    ids.append(inst["InstanceId"])
    return ids


def _rds_targets(status):
    out = []
    for page in rds.get_paginator("describe_db_instances").paginate():
        for db in page["DBInstances"]:
            if db.get("DBClusterIdentifier") or db["DBInstanceStatus"] != status:
                continue
            tags = {t["Key"]: t["Value"] for t in db.get("TagList", [])}
            if tags.get(TAG) == VALUE:
                out.append(db["DBInstanceIdentifier"])
    return out


def lambda_handler(event, _context):
    action = event.get("action")
    if action not in ("start", "stop"):
        raise ValueError("action deve ser start ou stop")

    ec2_ids = _ec2_targets("stopped" if action == "start" else "running")
    rds_ids = _rds_targets("stopped" if action == "start" else "available")
    log.info("acao=%s ec2=%s rds=%s dry_run=%s", action, ec2_ids, rds_ids, DRY_RUN)

    if not DRY_RUN:
        if ec2_ids:
            (ec2.start_instances if action == "start" else ec2.stop_instances)(InstanceIds=ec2_ids)
        for db in rds_ids:
            (rds.start_db_instance if action == "start" else rds.stop_db_instance)(DBInstanceIdentifier=db)

    return {"acao": action, "ec2": ec2_ids, "rds": rds_ids, "dry_run": DRY_RUN}
