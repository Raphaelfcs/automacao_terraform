MODULES := $(sort $(dir $(wildcard aws/*/main.tf gcp/*/main.tf azure/*/main.tf)))

.PHONY: fmt fmt-check validate test lint

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -recursive -check -diff

validate:
	@for m in $(MODULES); do \
		echo "==> $$m"; \
		terraform -chdir=$$m init -backend=false -input=false >/dev/null && terraform -chdir=$$m validate || exit 1; \
	done

test:
	@for m in $(MODULES); do \
		echo "==> $$m"; \
		terraform -chdir=$$m init -backend=false -input=false >/dev/null && terraform -chdir=$$m test || exit 1; \
	done

lint:
	tflint --init
	tflint --recursive --config=$(CURDIR)/.tflint.hcl
