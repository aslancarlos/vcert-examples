#!/usr/bin/env bash
# =============================================================================
# Revogacao de certificado - VCERT (CyberArk Certificate Manager Self-Hosted/TPP)
# =============================================================================
# Wrapper para `vcert revoke`. A revogacao NAO faz parte do playbook; e uma
# acao pontual via CLI. Disponivel no Self-Hosted (TPP).
#
# Uso:
#   export VCERT_TOKEN="seu_access_token"
#   ./revoke.sh --id '\VED\Policy\Producao\AppWeb\www.suaempresa.com.br' superseded
#   ./revoke.sh --thumbprint 0123ABCD... key-compromise
#
# Razoes validas: none | key-compromise | ca-compromise |
#                 affiliation-changed | superseded | cessation-of-operation
# =============================================================================
set -euo pipefail

URL="https://tpp.suaempresa.com.br/vedsdk"
SELECTOR="${1:-}"      # --id ou --thumbprint
VALUE="${2:-}"
REASON="${3:-superseded}"

: "${VCERT_TOKEN:?defina VCERT_TOKEN}"

if [[ "$SELECTOR" != "--id" && "$SELECTOR" != "--thumbprint" ]] || [[ -z "$VALUE" ]]; then
  echo "Uso: $0 --id <CertificateDN> | --thumbprint <SHA1> [reason]" >&2
  exit 2
fi

echo "Revogando certificado ($SELECTOR) com razao '$REASON'..."

# Remova --no-retire se quiser que o objeto seja desabilitado (sem reemissao).
vcert revoke \
  -u "$URL" \
  -t "$VCERT_TOKEN" \
  "$SELECTOR" "$VALUE" \
  --reason "$REASON" \
  --no-retire

echo "Revogacao solicitada."
