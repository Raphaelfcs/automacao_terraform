"""Handler de exemplo: registra o evento recebido em JSON estruturado."""
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(os.environ.get("NIVEL_LOG", "INFO"))


def handler(event, context):
    logger.info(json.dumps({"mensagem": "evento recebido", "evento": event}, default=str))
    return {"status": "ok"}
