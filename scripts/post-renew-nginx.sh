#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - Nginx
# Builds the fullchain (cert + chain) and reloads Nginx with no downtime.
# Called by the afterInstallAction in playbooks/nginx.yaml.
#
# In nginx.conf, point to:
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

echo "$(ts) [POST][nginx] Building fullchain (cert + chain)" >> "$LOG"

# Order for Nginx: server certificate first, then intermediates.
umask 077
cat "$CRT" "$CHAIN" > "${FULLCHAIN}.tmp"
mv "${FULLCHAIN}.tmp" "$FULLCHAIN"
chmod 644 "$FULLCHAIN"   # public cert; the key (.key) stays 600

# Validate the configuration before reloading.
if nginx -t >/dev/null 2>&1; then
  systemctl reload nginx
  echo "$(ts) [POST][nginx] Config valid, Nginx reloaded" >> "$LOG"
else
  echo "$(ts) [POST][nginx] ERROR: invalid config, reload aborted" >> "$LOG"
  exit 1
fi
