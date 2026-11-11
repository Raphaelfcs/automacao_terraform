# Empacotamento e testes do app. Os roots do Terraform apontam para build/lambda.
PY ?= python3

.PHONY: teste lambda imagem limpar

teste:
	$(PY) -m pytest -q

# Zip da Lambda (arm64): dependências nativas (cryptography) baixadas já para a plataforma da Lambda.
lambda:
	rm -rf build/lambda && mkdir -p build/lambda
	$(PY) -m pip install -q -r requirements.txt --target build/lambda \
	  --platform manylinux2014_aarch64 --implementation cp --python-version 3.12 --only-binary=:all:
	rm -rf build/lambda/boto3 build/lambda/botocore   # já vêm no runtime da Lambda
	cp -r docs_pacientes build/lambda/

# Imagem do Cloud Run (Artifact Registry): make imagem REGISTRO=southamerica-east1-docker.pkg.dev/<projeto>/docs TAG=<git sha>
imagem:
	docker build -t $(REGISTRO)/docs-pacientes:$(TAG) . && docker push $(REGISTRO)/docs-pacientes:$(TAG)

limpar:
	rm -rf build .pytest_cache
