# Security Policy

## Reporting a vulnerability

If you find a security vulnerability in this repository (or an accidentally exposed secret), **do not open a public issue** with the details.

1. Use the private **GitHub Security Advisories** channel ("Security" → "Report a vulnerability") in this repository, or
2. Contact the maintainer directly.

Describe:
- The issue and its potential impact.
- Steps to reproduce.
- The file(s) and line(s) involved, if applicable.

## Secrets best practices

This repository contains **examples only**. Before using in production:

- **Never** commit tokens, API keys, passwords, private keys (`.key`, `.pem`, `.p12`, `.jks`), or real CSRs. The [`.gitignore`](.gitignore) already blocks these patterns, but always double-check with `git status` before committing.
- Provide secrets via **environment variables** (`{{ Env "VCERT_TOKEN" }}`) or a **vault** (CyberArk Conjur, HashiCorp Vault, etc.).
- Restrict key file permissions: `chmod 600` and owner equal to the service user.
- Rotate tokens and API keys periodically and revoke any that leak.

## If a secret was exposed

1. **Immediately revoke** the token/API key in the CyberArk Certificate Manager.
2. **Re-issue** the affected certificate if the private key leaked.
3. Remove the secret from the Git history (e.g., `git filter-repo`) and force-push.
4. Audit any access that may have used the secret.
