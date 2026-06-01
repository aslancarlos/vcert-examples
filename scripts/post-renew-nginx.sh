#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - Nginx
# Monta o fullchain (cert + chain) e recarrega o Nginx sem downtime.
# Chamado pelo afterInstallAction do playbooks/nginx.yaml.
#
# No nginx.conf aponte:
#   ssl_certificate     /etc/nginx/certs/www.fullchain.crt;
#   ssl_certificate_key /etc/nginx/certs/www.key;
# =============================================================================
set -euo pipefail

CERT_DIR="/etc/nginx/certs"
CRT="${CERT_DIR}/www.crt"
CHAIN="${CERT_DIR}/www.chain.crt"
FULLCHAIN="${CERT_DIR}/www.fullchain.crt"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POS][nginx] Montando fullchain (cert + chain)" >> "$LOG"

# Ordem para o Nginx: certificado do servidor primeiro, depois intermediarias.
umask 077
cat "$CRT" "$CHAIN" > "${FULLCHAIN}.tmp"
mv "${FULLCHAIN}.tmp" "$FULLCHAIN"
chmod 644 "$FULLCHAIN"   # cert publico; a chave (.key) permanece 600

# Valida a configuracao antes de recarregar.
if nginx -t >/dev/null 2>&1; then
  systemctl reload nginx
  echo "$(ts) [POS][nginx] Config valida, Nginx recarregado" >> "$LOG"
else
  echo "$(ts) [POS][nginx] ERRO: config invalida, reload abortado" >> "$LOG"
  exit 1
fi
