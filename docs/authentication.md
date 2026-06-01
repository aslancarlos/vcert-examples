# Autenticação

O VCERT suporta os dois sabores do CyberArk Certificate Manager. Escolha conforme o seu ambiente.

## Self-Hosted (TPP) — Access Token

### 1. Gerar o token

```bash
vcert getcred \
  --username SEU_USUARIO \
  --password 'SUA_SENHA' \
  -u https://tpp.suaempresa.com.br/vedsdk \
  --client-id vcert-cli
```

A saída traz `access_token` e `refresh_token`. Guarde o `access_token`.

> O `client-id` (`vcert-cli` no exemplo) precisa estar registrado/permitido como aplicação OAuth na plataforma. Fale com o time que administra o CyberArk se receber erro de cliente inválido.

### 2. Renovar o token (opcional)

```bash
vcert getcred \
  -u https://tpp.suaempresa.com.br/vedsdk \
  --refresh-token SEU_REFRESH_TOKEN \
  --client-id vcert-cli
```

### 3. Fornecer ao playbook

O playbook lê de variável de ambiente:

```yaml
credentials:
  accessToken: "{{ Env \"VCERT_TOKEN\" }}"
```

```bash
export VCERT_TOKEN="cole_o_access_token"
vcert run -f playbooks/tpp-selfhosted.yaml
```

## SaaS (VaaS) — API Key

1. No console do CyberArk Certificate Manager SaaS, gere uma **API Key** no seu perfil.
2. Forneça via variável de ambiente:

   ```yaml
   credentials:
     apiKey: "{{ Env \"VCERT_APIKEY\" }}"
   ```

   ```bash
   export VCERT_APIKEY="sua_api_key"
   vcert run -f playbooks/saas-vaas.yaml
   ```

> A URL pode variar por região (ex.: `https://api.venafi.cloud` ou `https://api.eu.venafi.cloud`).

## CA interna / trust bundle

Se o endpoint usa uma CA interna não confiável pelo sistema:

```yaml
connection:
  trustBundle: "/etc/ssl/certs/cyberark-chain.pem"
```

## Onde guardar os segredos

Em ordem de preferência:

1. **Cofre** (CyberArk Conjur, HashiCorp Vault) injetando a variável em tempo de execução.
2. **EnvironmentFile** do systemd (`/etc/vcert/vcert.env`, `chmod 600`).
3. Variável de ambiente exportada por um script protegido.

**Nunca** coloque o token/API key diretamente no YAML versionado.
