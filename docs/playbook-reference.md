# Playbook Reference

A summary of the most commonly used fields in the VCERT playbook. For the complete, official reference, see the [vcert documentation](https://github.com/Venafi/vcert/blob/master/README-PLAYBOOK.md).

## General structure

```yaml
config:           # connection and credentials
certificateTasks: # one or more certificate tasks
```

## `config.connection`

| Field | Description |
|---|---|
| `platform` | `tpp` (Self-Hosted) or `vaas` (SaaS). |
| `url` | Endpoint URL (vedsdk for TPP; API for SaaS). |
| `credentials.accessToken` | OAuth token (TPP). |
| `credentials.apiKey` | API key (SaaS). |
| `credentials.p12Task` | mTLS credential via PKCS#12 (TPP). |
| `trustBundle` | Path to an internal CA, if needed. |

> Use `{{ Env "VAR_NAME" }}` to inject secrets from environment variables.

## `certificateTasks[]`

| Field | Description |
|---|---|
| `name` | Unique task name. |
| `renewBefore` | **When to renew.** Accepts days (`30d`), hours (`720h`), or a percentage (`10%`). |
| `request` | Certificate/CSR details (see below). |
| `installations` | Where to write files and pre/post actions (see below). |

## `request`

| Field | Description |
|---|---|
| `csr` | `local` (generates the key on the machine, recommended) or `service` (the platform generates it). |
| `subject.commonName` | The certificate CN. |
| `subject.organization` | **O** — organization. |
| `subject.organizationalUnits` | **OU** — list (may have several). |
| `subject.locality` | **L** — city. |
| `subject.province` | **ST** — state/province. |
| `subject.country` | **C** — country (e.g., `BR`). |
| `keyType` | `rsa` or `ecdsa`. |
| `keySize` | RSA size: `2048` / `3072` / `4096`. |
| `keyCurve` | ECDSA curve: `P256` / `P384` / `P521`. |
| `sanDNS` | List of DNS SANs. |
| `sanIP` / `sanEmail` | IP / email SANs. |
| `validDays` | **Validity period** in days (subject to the zone policy). |
| `issuerHint` | `DIGICERT` / `MICROSOFT` / `ENTRUST` when the CA requires it for custom validity. |
| `zone` | Policy folder (TPP) or `Application\IssuingTemplate` (SaaS). |

## `installations[]`

| Field | Description |
|---|---|
| `format` | `PEM`, `PKCS12`, `JKS`, or `CAPI` (Windows). |
| `file` | Path to the certificate / keystore file. |
| `chainFile` | Path to the chain (PEM only). |
| `keyFile` | Path to the private key (PEM only). |
| `password` | PKCS#12 password. |
| `jksAlias` / `jksPassword` | JKS keystore alias and password. |
| `capiLocation` | Windows store: `LocalMachine\\My` or `CurrentUser\\My` (CAPI). |
| `capiFriendlyName` | Friendly name in the Windows store (CAPI). |
| `capiIsNonExportable` | `true` marks the private key as non-exportable (CAPI). |
| `backupFiles` | `true` makes a `.bak` backup before overwriting. |
| `afterInstallAction` | **POST action** — command/script run after install (on enroll and renewal). On *nix via `/bin/sh -c`; on Windows via `powershell.exe`. |

> **There is no `beforeInstallAction` / pre-install hook.** `afterInstallAction` is the only action field. To run steps *before* installation, wrap `vcert run` in a script (see [`scripts/vcert-run.sh`](../scripts/vcert-run.sh)) and put the pre-steps there. Caveat: wrapper pre-steps run on every invocation, not only when a renewal actually happens.

## Mapping to the original request

| What you asked for | Playbook field |
|---|---|
| O (organization) | `request.subject.organization` |
| OU (unit) | `request.subject.organizationalUnits` |
| Algorithm | `request.keyType` |
| Key size | `request.keySize` (RSA) / `request.keyCurve` (ECDSA) |
| Validity period | `request.validDays` |
| Lead time to start renewal | `certificateTasks[].renewBefore` |
| POST action on renewal | `installations[].afterInstallAction` |
| PRE action on renewal | no native hook — use the [`scripts/vcert-run.sh`](../scripts/vcert-run.sh) wrapper |

> ⚠️ The server-side **zone/policy** may override validity, algorithm, key size, and even the Subject. If the result differs from the playbook, the server-side policy is winning. Validate with `vcert run -f file.yaml --validate`.
