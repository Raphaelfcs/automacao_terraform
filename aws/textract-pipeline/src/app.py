"""Extração de documentos com Amazon Textract (formulários e tabelas).

Disparada por evento "Object Created" do S3 via EventBridge. Para PDFs multipágina usa a
API assíncrona; para imagens, a síncrona. Grava o JSON do Textract no bucket de saída
mantendo o mesmo caminho da entrada.
"""
import json
import logging
import os
import time
import urllib.parse

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

OUTPUT_BUCKET = os.environ["OUTPUT_BUCKET"]
OUTPUT_PREFIX = os.environ.get("OUTPUT_PREFIX", "extraido")
FEATURES = os.environ.get("FEATURES", "FORMS,TABLES").split(",")

textract = boto3.client("textract")
s3 = boto3.client("s3")


def _analyze_async(bucket, key):
    job = textract.start_document_analysis(
        DocumentLocation={"S3Object": {"Bucket": bucket, "Name": key}}, FeatureTypes=FEATURES
    )
    job_id, blocks, token = job["JobId"], [], None
    while True:
        kwargs = {"JobId": job_id}
        if token:
            kwargs["NextToken"] = token
        resp = textract.get_document_analysis(**kwargs)
        if resp["JobStatus"] == "IN_PROGRESS":
            time.sleep(3)
            continue
        if resp["JobStatus"] == "FAILED":
            raise RuntimeError(resp.get("StatusMessage", "Textract falhou"))
        blocks += resp["Blocks"]
        token = resp.get("NextToken")
        if not token:
            return {"Blocks": blocks, "DocumentMetadata": resp["DocumentMetadata"]}


def lambda_handler(event, _context):
    bucket = event["detail"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(event["detail"]["object"]["key"])
    log.info("documento=s3://%s/%s", bucket, key)

    if key.lower().endswith(".pdf"):
        result = _analyze_async(bucket, key)
    else:
        result = textract.analyze_document(
            Document={"S3Object": {"Bucket": bucket, "Name": key}}, FeatureTypes=FEATURES
        )

    out_key = f"{OUTPUT_PREFIX}/{key}.json"
    s3.put_object(Bucket=OUTPUT_BUCKET, Key=out_key, Body=json.dumps(result).encode("utf-8"), ContentType="application/json")
    return {"saida": f"s3://{OUTPUT_BUCKET}/{out_key}", "blocos": len(result.get("Blocks", []))}
