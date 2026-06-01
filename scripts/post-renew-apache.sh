#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - Apache HTTP Server
# Valida a config e faz graceful reload (sem derrubar conexoes ativas).
# Chamado pelo afterInstallAction do playbooks/apache.yaml.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

# O binario muda conforme a distro: apachectl (Debian) / httpd (RHEL).
if command -v apachectl >/dev/null 2>&1; then
  CTL="apachectl"
  SVC="apache2"
else
  CTL="httpd"
  SVC="httpd"
fi

echo "$(ts) [POS][apache] Validando configuracao com ${CTL} -t" >> "$LOG"

if "$CTL" -t >/dev/null 2>&1; then
  # 'graceful' recarrega sem interromper requisicoes em andamento.
  if command -v apachectl >/dev/null 2>&1; then
    apachectl -k graceful
  else
    systemctl reload "$SVC"
  fi
  echo "$(ts) [POS][apache] Config valida, ${SVC} recarregado (graceful)" >> "$LOG"
else
  echo "$(ts) [POS][apache] ERRO: config invalida, reload abortado" >> "$LOG"
  exit 1
fi
