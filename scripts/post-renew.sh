#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO
# Executado pelo vcert (afterInstallAction) DEPOIS de gravar o certificado novo.
# Use para: recarregar/reiniciar o servico para que ele leia o certificado novo.
# =============================================================================
set -euo pipefail

LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POS] Certificado novo instalado, recarregando servico" >> "$LOG"

# Prefira 'reload' a 'restart' quando o servico suportar (sem downtime).
if systemctl is-active --quiet nginx; then
  nginx -t && systemctl reload nginx
  echo "$(ts) [POS] nginx recarregado com sucesso" >> "$LOG"
else
  systemctl start nginx
  echo "$(ts) [POS] nginx iniciado" >> "$LOG"
fi

echo "$(ts) [POS] Renovacao concluida" >> "$LOG"
