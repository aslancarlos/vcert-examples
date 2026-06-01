#!/usr/bin/env bash
# =============================================================================
# Certificate revocation - VCERT (CyberArk Certificate Manager Self-Hosted/TPP)
# =============================================================================
# Wrapper for `vcert revoke`. Revocation is NOT part of the playbook; it is a
# one-off CLI action. Available on Self-Hosted (TPP).
#
# Usage:
#   export VCERT_TOKEN="your_access_token"
#   ./revoke.sh --id '\VED\Policy\Production\AppWeb\www.yourcompany.com' superseded
#   ./revoke.sh --thumbprint 0123ABCD... key-compromise
#
# Valid reasons: none | key-compromise | ca-compromise |
#                affiliation-changed | superseded | cessation-of-operation
# =============================================================================
set -euo pipefail

URL="https://tpp.yourcompany.com/vedsdk"
SELECTOR="${1:-}"      # --id or --thumbprint
VALUE="${2:-}"
REASON="${3:-superseded}"

: "${VCERT_TOKEN:?set VCERT_TOKEN}"

if [[ "$SELECTOR" != "--id" && "$SELECTOR" != "--thumbprint" ]] || [[ -z "$VALUE" ]]; then
  echo "Usage: $0 --id <CertificateDN> | --thumbprint <SHA1> [reason]" >&2
  exit 2
fi

echo "Revoking certificate ($SELECTOR) with reason '$REASON'..."

# Remove --no-retire if you want the object to be disabled (no re-enrollment).
vcert revoke \
  -u "$URL" \
  -t "$VCERT_TOKEN" \
  "$SELECTOR" "$VALUE" \
  --reason "$REASON" \
  --no-retire

echo "Revocation requested."
