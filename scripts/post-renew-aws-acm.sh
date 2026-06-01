#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - AWS ACM (for ALB / NLB)
# Imports/re-imports the certificate into ACM. Reusing the same ARN updates the
# certificate across all listeners that already reference it.
# Called by the afterInstallAction in playbooks/aws-acm.yaml.
#
# Prerequisites:
#   - aws CLI installed and authenticated (profile or instance role)
#   - acm:ImportCertificate permission
#   - variables: AWS_REGION; ACM_CERT_ARN (optional on the first import)
# =============================================================================
set -euo pipefail

CERT="/etc/vcert/aws/www.crt"
CHAIN="/etc/vcert/aws/www.chain.crt"
KEY="/etc/vcert/aws/www.key"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

: "${AWS_REGION:?set AWS_REGION}"

echo "$(ts) [POST][aws-acm] Importing certificate into ACM (region ${AWS_REGION})" >> "$LOG"

if [[ -n "${ACM_CERT_ARN:-}" ]]; then
  # Re-import to the existing ARN: updates without touching the listener.
  aws acm import-certificate \
      --region "$AWS_REGION" \
      --certificate-arn "$ACM_CERT_ARN" \
      --certificate "fileb://${CERT}" \
      --certificate-chain "fileb://${CHAIN}" \
      --private-key "fileb://${KEY}" >/dev/null
  echo "$(ts) [POST][aws-acm] Re-imported into ARN ${ACM_CERT_ARN}" >> "$LOG"
else
  # First import: creates a new ARN (attach it to the listener manually).
  NEW_ARN=$(aws acm import-certificate \
      --region "$AWS_REGION" \
      --certificate "fileb://${CERT}" \
      --certificate-chain "fileb://${CHAIN}" \
      --private-key "fileb://${KEY}" \
      --query CertificateArn --output text)
  echo "$(ts) [POST][aws-acm] New ARN created: ${NEW_ARN}" >> "$LOG"
  echo "$(ts) [POST][aws-acm] NOTE: attach this ARN to the listener and set ACM_CERT_ARN for future renewals" >> "$LOG"
fi
