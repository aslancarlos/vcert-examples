#!/usr/bin/env bash
# =============================================================================
# PRE-RENEWAL steps
# =============================================================================
# IMPORTANT: the VCERT playbook has NO native before/pre-install hook. Do not
# reference this from the playbook. Instead, call it from the wrapper
# (scripts/vcert-run.sh) BEFORE `vcert run`.
#
# Use for: putting the app in maintenance, stopping a service, snapshots, etc.
# Note: it runs on every invocation, even when nothing is renewed, so keep it
# idempotent.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [PRE] Starting certificate renewal" >> "$LOG"

# Example: stop the service before swapping files (optional).
# Use '|| true' so the renewal isn't aborted if the service is already stopped.
# systemctl stop nginx || true

echo "$(ts) [PRE] Ready to install the new certificate" >> "$LOG"
