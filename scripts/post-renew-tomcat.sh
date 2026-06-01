#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - Apache Tomcat
# Ajusta permissoes do keystore e reinicia o Tomcat para recarregar o certificado.
# Chamado pelo afterInstallAction do playbooks/tomcat.yaml.
#
# Obs.: o Tomcat nao recarrega o keystore "a quente"; restart e o caminho usual.
# Para zero downtime, coloque o Tomcat atras de um LB e faca rolling restart.
# =============================================================================
set -euo pipefail

KEYSTORE="/etc/tomcat/certs/app.p12"
TOMCAT_USER="tomcat"
SVC="tomcat"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "$(ts) [POS][tomcat] Ajustando permissoes do keystore" >> "$LOG"
chown "${TOMCAT_USER}:${TOMCAT_USER}" "$KEYSTORE" || true
chmod 600 "$KEYSTORE"

echo "$(ts) [POS][tomcat] Reiniciando ${SVC}" >> "$LOG"
systemctl restart "$SVC"

# Aguarda subir e confirma que esta ativo.
sleep 5
if systemctl is-active --quiet "$SVC"; then
  echo "$(ts) [POS][tomcat] ${SVC} reiniciado e ativo" >> "$LOG"
else
  echo "$(ts) [POS][tomcat] ERRO: ${SVC} nao subiu apos restart" >> "$LOG"
  exit 1
fi
