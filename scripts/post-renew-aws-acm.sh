#!/usr/bin/env bash
# =============================================================================
# Hook POS-RENOVACAO - AWS ACM (para ALB / NLB)
# Importa/reimporta o certificado no ACM. Reusar o mesmo ARN atualiza o
# certificado em todos os listeners que ja o referenciam.
# Chamado pelo afterInstallAction do playbooks/aws-acm.yaml.
#
# Pre-requisitos:
#   - aws CLI instalado e autenticado (perfil ou instance role)
#   - permissao acm:ImportCertificate
#   - variaveis: AWS_REGION; ACM_CERT_ARN (opcional na primeira importacao)
# =============================================================================
set -euo pipefail

CERT="/etc/vcert/aws/www.crt"
CHAIN="/etc/vcert/aws/www.chain.crt"
KEY="/etc/vcert/aws/www.key"
LOG="/var/log/vcert.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

: "${AWS_REGION:?defina AWS_REGION}"

echo "$(ts) [POS][aws-acm] Importando certificado no ACM (regiao ${AWS_REGION})" >> "$LOG"

if [[ -n "${ACM_CERT_ARN:-}" ]]; then
  # Reimporta para o ARN existente: atualiza sem mexer no listener.
  aws acm import-certificate \
      --region "$AWS_REGION" \
      --certificate-arn "$ACM_CERT_ARN" \
      --certificate "fileb://${CERT}" \
      --certificate-chain "fileb://${CHAIN}" \
      --private-key "fileb://${KEY}" >/dev/null
  echo "$(ts) [POS][aws-acm] Reimportado no ARN ${ACM_CERT_ARN}" >> "$LOG"
else
  # Primeira importacao: cria um novo ARN (associe ao listener manualmente).
  NEW_ARN=$(aws acm import-certificate \
      --region "$AWS_REGION" \
      --certificate "fileb://${CERT}" \
      --certificate-chain "fileb://${CHAIN}" \
      --private-key "fileb://${KEY}" \
      --query CertificateArn --output text)
  echo "$(ts) [POS][aws-acm] Novo ARN criado: ${NEW_ARN}" >> "$LOG"
  echo "$(ts) [POS][aws-acm] AVISO: associe esse ARN ao listener e defina ACM_CERT_ARN para as proximas renovacoes" >> "$LOG"
fi
