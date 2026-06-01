#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - Apache HTTP Server
# Validates the config and performs a graceful reload (no dropped connections).
# Called by the afterInstallAction in playbooks/apache.yaml.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

# The binary varies by distro: apachectl (Debian) / httpd (RHEL).
if command -v apachectl >/dev/null 2>&1; then
  CTL="apachectl"
  SVC="apache2"
else
  CTL="httpd"
  SVC="httpd"
fi

echo "$(ts) [POST][apache] Validating configuration with ${CTL} -t" >> "$LOG"

if "$CTL" -t >/dev/null 2>&1; then
  # 'graceful' reloads without interrupting in-flight requests.
  if command -v apachectl >/dev/null 2>&1; then
    apachectl -k graceful
  else
    systemctl reload "$SVC"
  fi
  echo "$(ts) [POST][apache] Config valid, ${SVC} reloaded (graceful)" >> "$LOG"
else
  echo "$(ts) [POST][apache] ERROR: invalid config, reload aborted" >> "$LOG"
  exit 1
fi
