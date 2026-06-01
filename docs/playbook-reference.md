# Referência do Playbook

Resumo dos campos mais usados no playbook do VCERT. Para a referência completa e oficial, consulte a [documentação do vcert](https://github.com/Venafi/vcert/blob/master/README-PLAYBOOK.md).

## Estrutura geral

```yaml
config:           # conexão e credenciais
certificateTasks: # uma ou mais tarefas de certificado
```

## `config.connection`

| Campo | Descrição |
|---|---|
| `platform` | `tpp` (Self-Hosted) ou `vaas` (SaaS). |
| `url` | URL do endpoint (vedsdk para TPP; API para SaaS). |
| `credentials.accessToken` | Token OAuth (TPP). |
| `credentials.apiKey` | API key (SaaS). |
| `credentials.p12Task` | Credencial mTLS via PKCS#12 (TPP). |
| `trustBundle` | Caminho para CA interna, se necessário. |

> Use `{{ Env "NOME_DA_VAR" }}` para injetar segredos de variáveis de ambiente.

## `certificateTasks[]`

| Campo | Descrição |
|---|---|
| `name` | Nome único da tarefa. |
| `renewBefore` | **Quando renovar.** Aceita dias (`30d`), horas (`720h`) ou percentual (`10%`). |
| `request` | Dados do certificado/CSR (ver abaixo). |
| `installations` | Onde gravar e ações de pré/pós (ver abaixo). |

## `request`

| Campo | Descrição |
|---|---|
| `csr` | `local` (gera chave na máquina, recomendado) ou `service` (plataforma gera). |
| `subject.commonName` | CN do certificado. |
| `subject.organization` | **O** — organização. |
| `subject.organizationalUnits` | **OU** — lista (pode ter várias). |
| `subject.locality` | **L** — cidade. |
| `subject.province` | **ST** — estado. |
| `subject.country` | **C** — país (ex.: `BR`). |
| `keyType` | `rsa` ou `ecdsa`. |
| `keySize` | Tamanho RSA: `2048` / `3072` / `4096`. |
| `keyCurve` | Curva ECDSA: `P256` / `P384` / `P521`. |
| `sanDNS` | Lista de SANs DNS. |
| `sanIP` / `sanEmail` | SANs de IP / e-mail. |
| `validDays` | **Período de validade** em dias (sujeito à política da zone). |
| `issuerHint` | `DIGICERT` / `MICROSOFT` / `ENTRUST` quando a CA exige para validade custom. |
| `zone` | Policy folder (TPP) ou `Application\IssuingTemplate` (SaaS). |

## `installations[]`

| Campo | Descrição |
|---|---|
| `format` | `PEM`, `PKCS12` ou `JKS`. |
| `file` | Caminho do arquivo de certificado / keystore. |
| `chainFile` | Caminho da cadeia (somente PEM). |
| `keyFile` | Caminho da chave privada (somente PEM). |
| `password` | Senha do PKCS#12. |
| `jksAlias` / `jksPassword` | Alias e senha do keystore JKS. |
| `backupFiles` | `true` faz backup `.bak` antes de sobrescrever. |
| `beforeInstallAction` | **Ação PRE** — comando/script executado antes de instalar. |
| `afterInstallAction` | **Ação POS** — comando/script executado após instalar (ex.: recarregar serviço). |

## Mapeamento do pedido original

| O que você pediu | Campo no playbook |
|---|---|
| O (organização) | `request.subject.organization` |
| OU (unidade) | `request.subject.organizationalUnits` |
| Algoritmo | `request.keyType` |
| Tamanho de chave | `request.keySize` (RSA) / `request.keyCurve` (ECDSA) |
| Período de validade | `request.validDays` |
| Prazo para iniciar a renovação | `certificateTasks[].renewBefore` |
| Ação PRE na renovação | `installations[].beforeInstallAction` |
| Ação POS na renovação | `installations[].afterInstallAction` |

> ⚠️ A **zone/política do servidor** pode sobrescrever validade, algoritmo, tamanho de chave e até o Subject. Se o resultado diferir do playbook, é a política do lado do servidor mandando. Valide com `vcert run -f arquivo.yaml --validate`.
