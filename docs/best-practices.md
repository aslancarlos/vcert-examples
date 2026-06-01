# Best Practices

Recommendations for using VCERT with the CyberArk Certificate Manager safely and reliably in production.

## 1. Secrets

- **Never** version tokens, API keys, passwords, or private keys.
- Inject secrets via `{{ Env "VCERT_TOKEN" }}` reading from an environment variable, and provide that variable from a **vault** (CyberArk Conjur, Vault) or a protected file (`chmod 600`, owned by root).
- Rotate tokens periodically and immediately revoke any exposed secret.
- Review `git status`/`git diff` before each commit. The `.gitignore` already blocks common patterns.

## 2. Private key

- Prefer **`csr: local`** so the private key is generated and stays only on the machine.
- Restrict permissions: `chmod 600` on the `keyFile`, owned by the service user.
- Generate a **new key on every renewal** (default behavior of `csr: local`) instead of reusing the same key for years.

## 3. Algorithm and key size

- Recommended RSA minimum: **2048 bits** (use 3072/4096 for stricter requirements).
- ECDSA (`P256`/`P384`) offers smaller keys and better performance — use it if your stack and CA support it.
- Centralize the standard in the server-side **policy/zone** to keep the fleet consistent.

## 4. Validity and renewal

- Set `renewBefore` with **margin** (e.g., `30d`). Short certificates (90 days) require reliable windows and automation.
- Run the automation **frequently** (every 6–12h via cron or systemd timer). VCERT only renews within the window, so running frequently is safe.
- On large fleets, use `RandomizedDelaySec` (systemd) to avoid a simultaneous spike of requests to the CA.

## 5. Pre and post renewal hooks

- **Pre (`beforeInstallAction`)**: prepare the environment (maintenance mode, snapshot). Use `|| true` on commands that may fail without compromising the renewal.
- **Post (`afterInstallAction`)**: make sure the service **reads the new certificate**. Prefer `reload` over `restart` when possible (no downtime) and **test the config first** (e.g., `nginx -t && systemctl reload nginx`).
- Keep hooks **idempotent** and with **logging** (record start/end in `/var/log/vcert.log`).
- Test the renewal end to end with `--force-renew` in a staging environment.

## 6. Operational security

- Enable `backupFiles: true` to roll back quickly if something goes wrong.
- Monitor `vcert.log` and alert on renewal failures.
- Have independent **expiration** alerting (e.g., blackbox/external monitoring) — don't rely on automation alone.
- Document which zone/policy each host uses.

## 7. Validate before applying

```bash
vcert run -f playbooks/your-playbook.yaml --validate
```

Always use it before promoting changes to production.

## 8. Versioning

- Version the **playbooks** (without secrets) in a repository like this one.
- Use `CHANGELOG.md` to record notable changes.
- Review via PR before changing production playbooks.
