#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - Azure Application Gateway
# Updates the Application Gateway SSL certificate via the Azure CLI (az).
# Called by the afterInstallAction in playbooks/azure-appgw.yaml.
#
# Prerequisites:
#   - az CLI installed and authenticated (az login OR managed identity)
#   - permission to modify the Application Gateway
#   - variables: AZ_RESOURCE_GROUP, AZ_APPGW_NAME, AZ_CERT_NAME, VCERT_P12_PASS
# =============================================================================
set -euo pipefail

PFX="/etc/vcert/azure/www.pfx"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

: "${AZ_RESOURCE_GROUP:?set AZ_RESOURCE_GROUP}"
: "${AZ_APPGW_NAME:?set AZ_APPGW_NAME}"
: "${AZ_CERT_NAME:?set AZ_CERT_NAME}"
: "${VCERT_P12_PASS:?set VCERT_P12_PASS}"

echo "$(ts) [POST][azure-appgw] Updating cert '${AZ_CERT_NAME}' on gateway '${AZ_APPGW_NAME}'" >> "$LOG"

# 'update' if it already exists; fall back to 'create' for the first time.
if az network application-gateway ssl-cert show \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --gateway-name "$AZ_APPGW_NAME" \
      --name "$AZ_CERT_NAME" >/dev/null 2>&1; then
  az network application-gateway ssl-cert update \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --gateway-name "$AZ_APPGW_NAME" \
      --name "$AZ_CERT_NAME" \
      --cert-file "$PFX" \
      --cert-password "$VCERT_P12_PASS" >/dev/null
  echo "$(ts) [POST][azure-appgw] Certificate updated successfully" >> "$LOG"
else
  az network application-gateway ssl-cert create \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --gateway-name "$AZ_APPGW_NAME" \
      --name "$AZ_CERT_NAME" \
      --cert-file "$PFX" \
      --cert-password "$VCERT_P12_PASS" >/dev/null
  echo "$(ts) [POST][azure-appgw] Certificate created (attach it to the HTTPS listener)" >> "$LOG"
fi
