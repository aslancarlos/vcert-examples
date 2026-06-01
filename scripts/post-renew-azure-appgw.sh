#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - Azure Application Gateway
# Atualiza o certificado SSL do Application Gateway via Azure CLI (az).
# Chamado pelo afterInstallAction do playbooks/azure-appgw.yaml.
#
# Pre-requisitos:
#   - az CLI instalado e autenticado (az login OU managed identity)
#   - permissao para alterar o Application Gateway
#   - variaveis: AZ_RESOURCE_GROUP, AZ_APPGW_NAME, AZ_CERT_NAME, VCERT_P12_PASS
# =============================================================================
set -euo pipefail

PFX="/etc/vcert/azure/www.pfx"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

: "${AZ_RESOURCE_GROUP:?defina AZ_RESOURCE_GROUP}"
: "${AZ_APPGW_NAME:?defina AZ_APPGW_NAME}"
: "${AZ_CERT_NAME:?defina AZ_CERT_NAME}"
: "${VCERT_P12_PASS:?defina VCERT_P12_PASS}"

echo "$(ts) [POS][azure-appgw] Atualizando cert '${AZ_CERT_NAME}' no gateway '${AZ_APPGW_NAME}'" >> "$LOG"

# 'update' se ja existir; cai para 'create' se for a primeira vez.
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
  echo "$(ts) [POS][azure-appgw] Certificado atualizado com sucesso" >> "$LOG"
else
  az network application-gateway ssl-cert create \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --gateway-name "$AZ_APPGW_NAME" \
      --name "$AZ_CERT_NAME" \
      --cert-file "$PFX" \
      --cert-password "$VCERT_P12_PASS" >/dev/null
  echo "$(ts) [POS][azure-appgw] Certificado criado (associe ao listener HTTPS)" >> "$LOG"
fi
