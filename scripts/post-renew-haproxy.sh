#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - HAProxy
# Concatena cert + chain + key num unico PEM e recarrega o HAProxy sem downtime.
# Chamado pelo afterInstallAction do playbooks/haproxy.yaml.
# =============================================================================
set -euo pipefail

CERT_DIR="/etc/haproxy/certs"
CRT="${CERT_DIR}/lb.crt"
CHAIN="${CERT_DIR}/lb.chain.crt"
KEY="${CERT_DIR}/lb.key"
COMBINED="${CERT_DIR}/lb.pem"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POS][haproxy] Montando PEM combinado" >> "$LOG"

# Ordem exigida pelo HAProxy: certificado, cadeia, chave privada.
umask 077
cat "$CRT" "$CHAIN" "$KEY" > "${COMBINED}.tmp"
mv "${COMBINED}.tmp" "$COMBINED"
chmod 600 "$COMBINED"

# Valida a configuracao antes de recarregar.
if haproxy -c -f /etc/haproxy/haproxy.cfg >/dev/null 2>&1; then
  systemctl reload haproxy
  echo "$(ts) [POS][haproxy] Config valida, HAProxy recarregado" >> "$LOG"
else
  echo "$(ts) [POS][haproxy] ERRO: config invalida, reload abortado" >> "$LOG"
  exit 1
fi
