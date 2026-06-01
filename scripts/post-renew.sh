#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook
# Run by VCERT (afterInstallAction) AFTER writing the new certificate.
# Use for: reloading/restarting the service so it reads the new certificate.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POST] New certificate installed, reloading service" >> "$LOG"

# Prefer 'reload' over 'restart' when the service supports it (no downtime).
if systemctl is-active --quiet nginx; then
  nginx -t && systemctl reload nginx
  echo "$(ts) [POST] nginx reloaded successfully" >> "$LOG"
else
  systemctl start nginx
  echo "$(ts) [POST] nginx started" >> "$LOG"
fi

echo "$(ts) [POST] Renewal complete" >> "$LOG"
