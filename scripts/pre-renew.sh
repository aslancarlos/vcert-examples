#!/usr/bin/env bash
# =============================================================================
# PRE-RENEWAL hook
# Run by VCERT (beforeInstallAction) BEFORE writing the new certificate.
# Use for: putting the app in maintenance, stopping a service, snapshots, etc.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [PRE] Starting certificate renewal" >> "$LOG"

# Example: stop the service before swapping files (optional).
# Use '|| true' so the renewal isn't aborted if the service is already stopped.
# systemctl stop nginx || true

echo "$(ts) [PRE] Ready to install the new certificate" >> "$LOG"
