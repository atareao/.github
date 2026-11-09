#!/usr/bin/env bash
# Dispara keepalive.yml vía la API de GitHub (fallback del keep-alive programado).
#
# Uso:
#   GH_KEEPALIVE_PAT=<pat> ./scripts/keepalive.sh
#
# El PAT debe ser fine-grained con permiso "Actions: Read and write",
# limitado al repo atareao/.github.
set -euo pipefail

: "${GH_KEEPALIVE_PAT:?define GH_KEEPALIVE_PAT}"
REPO="${REPO:-atareao/.github}"
WORKFLOW="${WORKFLOW:-keepalive.yml}"
REF="${REF:-main}"

curl -fsS -X POST \
  -H "Authorization: Bearer ${GH_KEEPALIVE_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW}/dispatches" \
  -d "{\"ref\":\"${REF}\"}"

echo "keepalive disparado: ${REPO} ${WORKFLOW}@${REF}"
