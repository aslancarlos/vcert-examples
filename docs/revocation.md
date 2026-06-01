# Certificate Revocation

Revocation is **not** part of the playbook — it is a one-off action performed via the CLI with `vcert revoke`. Available on the **CyberArk Certificate Manager Self-Hosted (TPP)**.

> Revoking invalidates the certificate at the CA. Only do this when necessary (compromised key, superseded certificate, decommissioned host).

## Syntax

```bash
vcert revoke -u <url> -t <token> [--id <CertificateDN> | --thumbprint <SHA1>] --reason <reason>
```

### Flags

| Flag | Description |
|---|---|
| `-u` | CyberArk Certificate Manager URL (vedsdk). |
| `-t` | Access token. |
| `--id` | Certificate identifier (policy DN). Accepts a `file:` prefix. |
| `--thumbprint` | SHA1 thumbprint of the certificate. Accepts `file:`. |
| `--reason` | Revocation reason (see below). |
| `--no-retire` | Does **not** disable the object, allowing re-enrollment later. Omit to disable it. |

### Valid reasons (`--reason`)

`none` (default) · `key-compromise` · `ca-compromise` · `affiliation-changed` · `superseded` · `cessation-of-operation`

## Examples

By DN (policy identifier):

```bash
export VCERT_TOKEN="your_access_token"
vcert revoke \
  -u https://tpp.yourcompany.com/vedsdk \
  -t "$VCERT_TOKEN" \
  --id '\VED\Policy\Production\AppWeb\www.yourcompany.com' \
  --reason superseded \
  --no-retire
```

By thumbprint:

```bash
vcert revoke \
  -u https://tpp.yourcompany.com/vedsdk \
  -t "$VCERT_TOKEN" \
  --thumbprint 0123456789ABCDEF0123456789ABCDEF01234567 \
  --reason key-compromise
```

Via this repo's helper script:

```bash
export VCERT_TOKEN="your_access_token"
./scripts/revoke.sh --id '\VED\Policy\Production\AppWeb\www.yourcompany.com' superseded
```

## `--no-retire`: revoke vs. retire

- **With `--no-retire`**: the certificate is revoked, but the object stays on the platform and can be **re-enrolled** later.
- **Without `--no-retire`**: in addition to revoking, the object is **disabled (retired)**. Use this when the host/service is decommissioned for good.

## Which reason to use

| Situation | Suggested reason |
|---|---|
| Private key leaked/compromised | `key-compromise` |
| Replaced by a new one (manual rotation) | `superseded` |
| Host/service decommissioned | `cessation-of-operation` (usually without `--no-retire`) |
| Organization/ownership change | `affiliation-changed` |

> On **SaaS (VaaS)**, revocation via `vcert revoke` may not be available — use the CyberArk Certificate Manager console in that case.
