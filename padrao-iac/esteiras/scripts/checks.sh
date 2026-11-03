#!/usr/bin/env bash
# Checagens estáticas de uma pasta Terraform: fmt, init sem backend, validate, tflint, test e Checkov.
set -euo pipefail
p="$1"
terraform -chdir="$p" fmt -check -recursive
terraform -chdir="$p" init -backend=false -input=false
terraform -chdir="$p" validate
tflint --chdir="$p" --minimum-failure-severity=warning
if ls "$p"/tests/*.tftest.hcl >/dev/null 2>&1; then terraform -chdir="$p" test; fi
checkov -d "$p" --framework terraform --quiet --compact
