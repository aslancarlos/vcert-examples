#!/usr/bin/env bash
# =============================================================================
# POST-RENEWAL hook - Apache Tomcat
# Fixes keystore permissions and restarts Tomcat to reload the certificate.
# Called by the afterInstallAction in playbooks/tomcat.yaml.
#
# Note: Tomcat does not hot-reload the keystore; a restart is the usual path.
# For zero downtime, place Tomcat behind an LB and do a rolling restart.
# =============================================================================
set -euo pipefail

KEYSTORE="/etc/tomcat/certs/app.p12"
TOMCAT_USER="tomcat"
SVC="tomcat"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POST][tomcat] Fixing keystore permissions" >> "$LOG"
chown "${TOMCAT_USER}:${TOMCAT_USER}" "$KEYSTORE" || true
chmod 600 "$KEYSTORE"

echo "$(ts) [POST][tomcat] Restarting ${SVC}" >> "$LOG"
systemctl restart "$SVC"

# Wait for it to come up and confirm it is active.
sleep 5
if systemctl is-active --quiet "$SVC"; then
  echo "$(ts) [POST][tomcat] ${SVC} restarted and active" >> "$LOG"
else
  echo "$(ts) [POST][tomcat] ERROR: ${SVC} did not come up after restart" >> "$LOG"
  exit 1
fi
