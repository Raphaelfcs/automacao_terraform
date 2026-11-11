# Imagem única do Cloud Run: MODO=api ou MODO=eventos (definido no serviço).
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /srv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn==23.0.0 \
 && useradd --uid 10001 --no-create-home app
COPY docs_pacientes ./docs_pacientes
USER 10001
# Cloud Run injeta PORT. 1 processo, 8 threads: E/S de rede domina.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 60 docs_pacientes.entry.gcp_run:app
