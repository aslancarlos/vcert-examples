# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- Translated all documentation and inline code comments to English.

### Added
- Dedicated playbooks: `playbooks/haproxy.yaml`, `playbooks/apache.yaml`, `playbooks/tomcat.yaml`.
- Per-service post-renewal scripts: `scripts/post-renew-haproxy.sh`, `post-renew-apache.sh`, `post-renew-tomcat.sh`.
- `docs/architecture.md` with Mermaid diagrams (flow, components, and per-service).
- Flow diagram in `README.md`.
- **Windows / IIS** support: `playbooks/windows-iis.yaml` (CAPI store), `scripts/post-renew-iis.ps1` (IIS binding), `docs/windows-iis.md` (guide + Task Scheduler), and an IIS diagram.
- Playbook and hook for **Nginx**: `playbooks/nginx.yaml`, `scripts/post-renew-nginx.sh`.
- Cloud load balancers: `playbooks/azure-appgw.yaml` + `scripts/post-renew-azure-appgw.sh` (Azure Application Gateway via Azure CLI) and `playbooks/aws-acm.yaml` + `scripts/post-renew-aws-acm.sh` (AWS ALB/NLB via ACM).
- **Revocation**: `docs/revocation.md` and `scripts/revoke.sh` (wrapper for `vcert revoke`).
- Mermaid diagrams for Nginx, Azure App Gateway, AWS ACM, and revocation in `docs/architecture.md`.

## [1.0.0] - 2026-06-01

### Added
- Initial repository structure.
- Example playbook for CyberArk Certificate Manager Self-Hosted (TPP): `playbooks/tpp-selfhosted.yaml`.
- Example playbook for SaaS (VaaS): `playbooks/saas-vaas.yaml`.
- Multi-format playbook (PEM + PKCS12 + JKS): `playbooks/multi-format.yaml`.
- Documentation: installation, authentication, playbook reference, and best practices.
- Scheduling examples via cron and systemd timer.
- Pre and post renewal hook scripts.
- `LICENSE` (MIT), `SECURITY.md`, `CONTRIBUTING.md`, `.gitignore`.
