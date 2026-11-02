"""Relatório diário de custos (FinOps) via Cost Explorer.

Agrupa o custo de ontem e o acumulado do mês por serviço (e opcionalmente por uma tag de
alocação), grava o CSV no S3 e publica um resumo no SNS com link pré-assinado.
Substitui a Lambda que buscava o último CSV do CUR e enviava por SES com destinatários fixos.
"""
import csv
import datetime as dt
import io
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

BUCKET = os.environ["REPORT_BUCKET"]
PREFIX = os.environ.get("REPORT_PREFIX", "finops/diario")
TOPIC_ARN = os.environ["TOPIC_ARN"]
COST_TAG = os.environ.get("COST_TAG", "")
TOP_N = int(os.environ.get("TOP_N", "10"))

ce = boto3.client("ce", region_name="us-east-1")
s3 = boto3.client("s3")
sns = boto3.client("sns")


def _costs(start, end, group_by):
    rows, token = [], None
    while True:
        kwargs = dict(
            TimePeriod={"Start": start.isoformat(), "End": end.isoformat()},
            Granularity="MONTHLY" if (end - start).days > 1 else "DAILY",
            Metrics=["UnblendedCost"],
            GroupBy=group_by,
        )
        if token:
            kwargs["NextPageToken"] = token
        resp = ce.get_cost_and_usage(**kwargs)
        for period in resp["ResultsByTime"]:
            for g in period["Groups"]:
                rows.append((" | ".join(g["Keys"]), float(g["Metrics"]["UnblendedCost"]["Amount"])))
        token = resp.get("NextPageToken")
        if not token:
            return rows


def lambda_handler(_event, _context):
    today = dt.date.today()
    yesterday = today - dt.timedelta(days=1)
    month_start = yesterday.replace(day=1)

    group_by = [{"Type": "DIMENSION", "Key": "SERVICE"}]
    if COST_TAG:
        group_by.append({"Type": "TAG", "Key": COST_TAG})

    daily = sorted(_costs(yesterday, today, group_by), key=lambda r: r[1], reverse=True)
    mtd = sorted(_costs(month_start, today, [{"Type": "DIMENSION", "Key": "SERVICE"}]), key=lambda r: r[1], reverse=True)

    buf = io.StringIO()
    writer = csv.writer(buf)
    writer.writerow(["data", "grupo", "custo_usd"])
    for key, value in daily:
        writer.writerow([yesterday.isoformat(), key, f"{value:.4f}"])

    key = f"{PREFIX}/{yesterday:%Y/%m}/custos-{yesterday.isoformat()}.csv"
    s3.put_object(Bucket=BUCKET, Key=key, Body=buf.getvalue().encode("utf-8"), ContentType="text/csv")
    url = s3.generate_presigned_url("get_object", Params={"Bucket": BUCKET, "Key": key}, ExpiresIn=7 * 86400)

    total_day = sum(v for _, v in daily)
    total_mtd = sum(v for _, v in mtd)
    lines = [f"Custo de {yesterday:%d/%m/%Y}: US$ {total_day:,.2f}", f"Acumulado do mes: US$ {total_mtd:,.2f}", "", f"Top {TOP_N} de ontem:"]
    lines += [f"- {k}: US$ {v:,.2f}" for k, v in daily[:TOP_N]]
    lines += ["", f"CSV completo (7 dias): {url}"]

    sns.publish(TopicArn=TOPIC_ARN, Subject=f"[FinOps] Custos {yesterday:%d/%m}", Message="\n".join(lines))
    return {"arquivo": f"s3://{BUCKET}/{key}", "total_dia": total_day, "total_mes": total_mtd}
