#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - HAProxy
# Concatenates cert + chain + key into a single PEM and reloads HAProxy with no downtime.
# Called by the afterInstallAction in playbooks/haproxy.yaml.
# =============================================================================
set -euo pipefail

CERT_DIR="/etc/haproxy/certs"
CRT="${CERT_DIR}/lb.crt"
CHAIN="${CERT_DIR}/lb.chain.crt"
KEY="${CERT_DIR}/lb.key"
COMBINED="${CERT_DIR}/lb.pem"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POST][haproxy] Building combined PEM" >> "$LOG"

# Order required by HAProxy: certificate, chain, private key.
umask 077
cat "$CRT" "$CHAIN" "$KEY" > "${COMBINED}.tmp"
mv "${COMBINED}.tmp" "$COMBINED"
chmod 600 "$COMBINED"

# Validate the configuration before reloading.
if haproxy -c -f /etc/haproxy/haproxy.cfg >/dev/null 2>&1; then
  systemctl reload haproxy
  echo "$(ts) [POST][haproxy] Config valid, HAProxy reloaded" >> "$LOG"
else
  echo "$(ts) [POST][haproxy] ERROR: invalid config, reload aborted" >> "$LOG"
  exit 1
fi
