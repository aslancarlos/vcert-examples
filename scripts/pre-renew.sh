#!/usr/bin/env bash
# =============================================================================
# Hook PRE-RENOVACAO
# Executado pelo vcert (beforeInstallAction) ANTES de gravar o certificado novo.
# Use para: colocar app em manutencao, parar servico, snapshot, etc.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [PRE] Iniciando renovacao do certificado" >> "$LOG"

# Exemplo: parar o servico antes de trocar os arquivos (opcional).
# Use '|| true' para nao abortar a renovacao caso o servico ja esteja parado.
# systemctl stop nginx || true

echo "$(ts) [PRE] Pronto para instalar o certificado novo" >> "$LOG"
