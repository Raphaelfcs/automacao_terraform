"""Testes locais: python -m pytest tests (não chamam AWS nem as APIs)."""
import datetime as dt
import os
import sys

os.environ.update(URL_CANAIS="https://exemplo/canais", URL_GUIA="https://exemplo/guia/{inicio}/{fim}",
                  REMETENTE="monitoria@example.com", DESTINATARIOS="noc@example.com", AWS_DEFAULT_REGION="us-east-1")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "terraform", "src"))
import app  # noqa: E402


def test_compara_encontra_canal_ausente():
    oficiais = {"10": "NEWS", "20": "SPORT", "5": "KIDS"}
    guia = {"10": "NEWS", "5": "KIDS"}
    assert app.compara(oficiais, guia) == [("20", "SPORT")]


def test_janela_do_dia_cobre_24h():
    ini, fim = app.janela_do_dia(dt.datetime(2026, 11, 3, 15, 30, tzinfo=dt.timezone(dt.timedelta(hours=-3))))
    assert ini.startswith("2026-11-03T00:00:00.000") and fim.startswith("2026-11-03T23:59:59.000")


def test_html_sem_ausentes_nao_tem_tabela():
    assert "<table" not in app.html(3, [], "2026-11-03")
