#!/usr/bin/env bash
# Cria a tag <pasta>/v<VERSION> para cada pasta alterada, se ainda não existir.
# A tag é imutável: para publicar de novo, suba a versão no arquivo VERSION.
# Uso: tag.sh <engines|boilerplates> <ref-base>
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
for p in $("$dir/alterados.sh" "$1" "${2:-HEAD~1}"); do
  v="$(tr -d '[:space:]' < "$p/VERSION")"
  t="$p/v$v"
  if git rev-parse -q --verify "refs/tags/$t" >/dev/null; then
    echo "::warning:: $t já existe; suba o VERSION de $p para publicar"; continue
  fi
  git tag -a "$t" -m "$p $v"
  git push origin "$t"
  echo "publicado $t"
done
