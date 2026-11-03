#!/usr/bin/env bash
# Lista as pastas alteradas de um tipo (engines, boilerplates, workloads) entre a base e o HEAD.
# Uso: alterados.sh <engines|boilerplates|workloads> <ref-base>
# engines/<nuvem>/<nome>  ·  boilerplates/<nome>  ·  workloads/<projeto>
set -euo pipefail
tipo="$1"; base="${2:-origin/main}"
case "$tipo" in
  engines) niveis=3 ;;
  boilerplates|workloads) niveis=2 ;;
  *) echo "tipo inválido: $tipo" >&2; exit 2 ;;
esac
git diff --name-only "$base"...HEAD -- "$tipo/" \
  | cut -d/ -f1-"$niveis" | sort -u \
  | while read -r d; do [ -d "$d" ] && echo "$d"; done
