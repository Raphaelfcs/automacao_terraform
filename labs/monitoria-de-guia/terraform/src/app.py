"""Monitoria do guia de programação (EPG).

Compara a lista oficial de canais com os canais presentes no guia do dia e envia um
relatório por e-mail (Amazon SES) quando algum canal some do guia. Também grava a
métrica CanaisAusentes em formato EMF, para alarme no CloudWatch.

Versão reescrita (2026) de uma Lambda de 2018: sem credenciais SMTP no código
(usa a role da função com ses:SendEmail), sem dependências externas (urllib)
e com URLs, remetente e destinatários vindos de variáveis de ambiente.
"""
import datetime as dt
import json
import logging
import os
import urllib.request

import boto3

logger = logging.getLogger()
logger.setLevel(os.environ.get("NIVEL_LOG", "INFO"))

ses = boto3.client("sesv2")

URL_CANAIS = os.environ["URL_CANAIS"]   # lista oficial de canais (JSON)
URL_GUIA = os.environ["URL_GUIA"]       # guia do dia; {inicio} e {fim} são substituídos
REMETENTE = os.environ["REMETENTE"]
DESTINATARIOS = [d.strip() for d in os.environ["DESTINATARIOS"].split(",") if d.strip()]
FUSO = dt.timezone(dt.timedelta(hours=int(os.environ.get("FUSO_HORAS", "-3"))))


def busca_json(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=20) as resp:  # noqa: S310 (URL vem da configuração)
        return json.load(resp)


def canais(payload: list[dict]) -> dict[str, str]:
    """{numero_do_canal: nome_curto}"""
    return {str(c["majorChannelNumber"]): c["shortName"] for c in payload}


def janela_do_dia(agora: dt.datetime) -> tuple[str, str]:
    inicio = agora.replace(hour=0, minute=0, second=0, microsecond=0)
    fim = inicio + dt.timedelta(days=1) - dt.timedelta(seconds=1)
    return inicio.isoformat(timespec="milliseconds"), fim.isoformat(timespec="milliseconds")


def compara(oficiais: dict[str, str], no_guia: dict[str, str]) -> list[tuple[str, str]]:
    return sorted(set(oficiais.items()) - set(no_guia.items()), key=lambda c: int(c[0]) if c[0].isdigit() else 0)


def html(oficiais: int, ausentes: list[tuple[str, str]], dia: str) -> str:
    linhas = "".join(f"<tr><td>{n}</td><td>{nome}</td></tr>" for n, nome in ausentes)
    tabela = f"<table border='1' cellpadding='4'><tr><th>Canal</th><th>Nome</th></tr>{linhas}</table>" if ausentes else ""
    return (f"<h2>Monitoria do guia · {dia}</h2>"
            f"<p>Canais na lista oficial: <b>{oficiais}</b><br>Canais ausentes no guia: <b>{len(ausentes)}</b></p>{tabela}")


def metrica(ausentes: int) -> None:
    """Embedded Metric Format: vira métrica no CloudWatch sem chamada extra de API."""
    print(json.dumps({
        "_aws": {"Timestamp": int(dt.datetime.now().timestamp() * 1000),
                 "CloudWatchMetrics": [{"Namespace": "MonitoriaGuia", "Dimensions": [[]],
                                        "Metrics": [{"Name": "CanaisAusentes", "Unit": "Count"}]}]},
        "CanaisAusentes": ausentes,
    }))


def lambda_handler(event, context):
    agora = dt.datetime.now(FUSO)
    inicio, fim = janela_do_dia(agora)
    oficiais = canais(busca_json(URL_CANAIS)["simpleChannels"]["item"])
    no_guia = canais(busca_json(URL_GUIA.format(inicio=inicio, fim=fim))["simpleChl"])
    ausentes = compara(oficiais, no_guia)

    metrica(len(ausentes))
    logger.info(json.dumps({"oficiais": len(oficiais), "no_guia": len(no_guia), "ausentes": len(ausentes)}))

    if ausentes or event.get("sempre_enviar"):
        ses.send_email(
            FromEmailAddress=REMETENTE,
            Destination={"ToAddresses": DESTINATARIOS},
            Content={"Simple": {
                "Subject": {"Data": f"Monitoria do guia: {len(ausentes)} canal(is) ausente(s)"},
                "Body": {"Html": {"Data": html(len(oficiais), ausentes, agora.date().isoformat())}},
            }},
        )
    return {"oficiais": len(oficiais), "ausentes": [n for n, _ in ausentes]}
