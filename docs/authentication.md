# Authentication

VCERT supports both flavors of the CyberArk Certificate Manager. Choose the one matching your environment.

## Self-Hosted (TPP) — Access Token

### 1. Generate the token

```bash
vcert getcred \
  --username YOUR_USER \
  --password 'YOUR_PASSWORD' \
  -u https://tpp.yourcompany.com/vedsdk \
  --client-id vcert-cli
```

The output includes an `access_token` and a `refresh_token`. Keep the `access_token`.

> The `client-id` (`vcert-cli` in the example) must be registered/allowed as an OAuth application on the platform. Talk to your CyberArk administrators if you get an invalid-client error.

### 2. Refresh the token (optional)

```bash
vcert getcred \
  -u https://tpp.yourcompany.com/vedsdk \
  --refresh-token YOUR_REFRESH_TOKEN \
  --client-id vcert-cli
```

### 3. Provide it to the playbook

The playbook reads from an environment variable:

```yaml
credentials:
  accessToken: "{{ Env \"VCERT_TOKEN\" }}"
```

```bash
export VCERT_TOKEN="paste_the_access_token"
vcert run -f playbooks/tpp-selfhosted.yaml
```

## SaaS (VaaS) — API Key

1. In the CyberArk Certificate Manager SaaS console, generate an **API Key** in your profile.
2. Provide it via an environment variable:

   ```yaml
   credentials:
     apiKey: "{{ Env \"VCERT_APIKEY\" }}"
   ```

   ```bash
   export VCERT_APIKEY="your_api_key"
   vcert run -f playbooks/saas-vaas.yaml
   ```

> The URL may vary by region (e.g., `https://api.venafi.cloud` or `https://api.eu.venafi.cloud`).

## Internal CA / trust bundle

If the endpoint uses an internal CA that the system does not trust:

```yaml
connection:
  trustBundle: "/etc/ssl/certs/cyberark-chain.pem"
```

## Where to store secrets

In order of preference:

1. A **vault** (CyberArk Conjur, HashiCorp Vault) injecting the variable at runtime.
2. A systemd **EnvironmentFile** (`/etc/vcert/vcert.env`, `chmod 600`).
3. An environment variable exported by a protected script.

**Never** put the token/API key directly in the versioned YAML.
