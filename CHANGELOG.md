# Changelog

Todas as mudanças relevantes deste projeto são documentadas aqui.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Adicionado
- Playbooks dedicados: `playbooks/haproxy.yaml`, `playbooks/apache.yaml`, `playbooks/tomcat.yaml`.
- Scripts de pós-renovação por serviço: `scripts/post-renew-haproxy.sh`, `post-renew-apache.sh`, `post-renew-tomcat.sh`.
- `docs/architecture.md` com diagramas Mermaid (fluxo, componentes e por serviço).
- Diagrama de fluxo no `README.md`.
- Suporte a **Windows / IIS**: `playbooks/windows-iis.yaml` (store CAPI), `scripts/post-renew-iis.ps1` (bind no IIS), `docs/windows-iis.md` (guia + Task Scheduler) e diagrama IIS.

## [1.0.0] - 2026-06-01

### Adicionado
- Estrutura inicial do repositório.
- Playbook de exemplo para CyberArk Certificate Manager Self-Hosted (TPP): `playbooks/tpp-selfhosted.yaml`.
- Playbook de exemplo para SaaS (VaaS): `playbooks/saas-vaas.yaml`.
- Playbook multi-formato (PEM + PKCS12 + JKS): `playbooks/multi-format.yaml`.
- Documentação: instalação, autenticação, referência do playbook e boas práticas.
- Exemplos de agendamento via cron e systemd timer.
- Scripts de hook de pré e pós renovação.
- `LICENSE` (MIT), `SECURITY.md`, `CONTRIBUTING.md`, `.gitignore`.
