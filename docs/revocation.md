# Revogação de Certificados

A revogação **não** faz parte do playbook — é uma ação pontual feita pela CLI com `vcert revoke`. Disponível no **CyberArk Certificate Manager Self-Hosted (TPP)**.

> Revogar invalida o certificado na CA. Faça apenas quando necessário (chave comprometida, certificado substituído, host desativado).

## Sintaxe

```bash
vcert revoke -u <url> -t <token> [--id <CertificateDN> | --thumbprint <SHA1>] --reason <razao>
```

### Flags

| Flag | Descrição |
|---|---|
| `-u` | URL do CyberArk Certificate Manager (vedsdk). |
| `-t` | Access token. |
| `--id` | Identificador do certificado (DN da policy). Aceita `file:` como prefixo. |
| `--thumbprint` | Thumbprint SHA1 do certificado. Aceita `file:`. |
| `--reason` | Motivo da revogação (ver abaixo). |
| `--no-retire` | **Não** desabilita o objeto, permitindo reemissão depois. Omita para desabilitar. |

### Motivos válidos (`--reason`)

`none` (padrão) · `key-compromise` · `ca-compromise` · `affiliation-changed` · `superseded` · `cessation-of-operation`

## Exemplos

Por DN (identificador da policy):

```bash
export VCERT_TOKEN="seu_access_token"
vcert revoke \
  -u https://tpp.suaempresa.com.br/vedsdk \
  -t "$VCERT_TOKEN" \
  --id '\VED\Policy\Producao\AppWeb\www.suaempresa.com.br' \
  --reason superseded \
  --no-retire
```

Por thumbprint:

```bash
vcert revoke \
  -u https://tpp.suaempresa.com.br/vedsdk \
  -t "$VCERT_TOKEN" \
  --thumbprint 0123456789ABCDEF0123456789ABCDEF01234567 \
  --reason key-compromise
```

Via script auxiliar deste repo:

```bash
export VCERT_TOKEN="seu_access_token"
./scripts/revoke.sh --id '\VED\Policy\Producao\AppWeb\www.suaempresa.com.br' superseded
```

## `--no-retire`: revogar vs. desabilitar

- **Com `--no-retire`**: o certificado é revogado, mas o objeto continua na plataforma e pode ser **reemitido** depois.
- **Sem `--no-retire`**: além de revogar, o objeto é **desabilitado** (retire). Use quando o host/serviço foi desativado de vez.

## Quando usar cada motivo

| Situação | Motivo sugerido |
|---|---|
| Chave privada vazou/comprometida | `key-compromise` |
| Trocado por um novo (rotação manual) | `superseded` |
| Host/serviço desativado | `cessation-of-operation` (geralmente sem `--no-retire`) |
| Mudança de organização/titularidade | `affiliation-changed` |

> No **SaaS (VaaS)** a revogação pelo `vcert revoke` pode não estar disponível — use o console do CyberArk Certificate Manager nesse caso.
