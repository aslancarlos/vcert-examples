#!/usr/bin/env bash
# =============================================================================
# VCERT wrapper - emulates a "pre" action
# =============================================================================
# The VCERT playbook has NO native before/pre-install hook (only
# afterInstallAction). To run steps BEFORE vcert installs a certificate, wrap
# the `vcert run` call: pre-steps -> vcert run -> (post handled by
# afterInstallAction inside the playbook).
#
# IMPORTANT: pre-steps here run on EVERY invocation, even when vcert decides
# there is nothing to renew (still within the renewBefore window). Keep them
# safe to run repeatedly (idempotent). For actions that must happen ONLY when a
# renewal actually occurs, use afterInstallAction inside the playbook instead.
#
# Schedule THIS script from cron/systemd/Task Scheduler instead of vcert directly.
# =============================================================================
set -euo pipefail

PLAYBOOK="${1:-/etc/vcert/playbook.yaml}"
VCERT="${VCERT_BIN:-/usr/local/bin/vcert}"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

# ---- PRE steps (optional, idempotent) ----------------------------------------
echo "$(ts) [PRE] vcert-run starting (playbook: ${PLAYBOOK})" >> "$LOG"
if [[ -x /usr/local/bin/pre-renew.sh ]]; then
  /usr/local/bin/pre-renew.sh
fi

# ---- Run vcert (installation + afterInstallAction happen here) ---------------
"$VCERT" run -f "$PLAYBOOK"

echo "$(ts) [PRE] vcert-run finished" >> "$LOG"
