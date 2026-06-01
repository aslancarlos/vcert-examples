# Boas Práticas

Recomendações para usar o VCERT com o CyberArk Certificate Manager de forma segura e confiável em produção.

## 1. Segredos

- **Nunca** versione tokens, API keys, senhas ou chaves privadas.
- Injete segredos via `{{ Env "VCERT_TOKEN" }}` lendo de variável de ambiente, e forneça essa variável a partir de um **cofre** (CyberArk Conjur, Vault) ou de um arquivo protegido (`chmod 600`, dono root).
- Rotacione tokens periodicamente e revogue imediatamente qualquer segredo exposto.
- Revise `git status`/`git diff` antes de cada commit. O `.gitignore` já bloqueia os padrões comuns.

## 2. Chave privada

- Prefira **`csr: local`** para que a chave privada seja gerada e permaneça apenas na máquina.
- Restrinja permissões: `chmod 600` no `keyFile`, dono igual ao usuário do serviço.
- Gere **chave nova a cada renovação** (comportamento padrão do `csr: local`) em vez de reutilizar a mesma chave por anos.

## 3. Algoritmo e tamanho de chave

- RSA mínimo recomendado: **2048 bits** (use 3072/4096 para requisitos mais rígidos).
- ECDSA (`P256`/`P384`) oferece chaves menores e melhor performance — use se a sua stack e a CA suportarem.
- Centralize o padrão na **política/zone** do servidor para manter consistência na frota.

## 4. Validade e renovação

- Defina `renewBefore` com **folga** (ex.: `30d`). Certificados curtos (90 dias) exigem janelas e automação confiáveis.
- Rode a automação **com frequência** (a cada 6–12h via cron ou systemd timer). O VCERT só renova dentro da janela, então rodar com frequência é seguro.
- Em frotas grandes, use `RandomizedDelaySec` (systemd) para evitar pico simultâneo de requisições na CA.

## 5. Hooks de pré e pós renovação

- **Pré (`beforeInstallAction`)**: prepare o ambiente (manutenção, snapshot). Use `|| true` em comandos que podem falhar sem comprometer a renovação.
- **Pós (`afterInstallAction`)**: garanta que o serviço **leia o certificado novo**. Prefira `reload` a `restart` quando possível (sem downtime) e **teste a config antes** (ex.: `nginx -t && systemctl reload nginx`).
- Mantenha os hooks **idempotentes** e com **log** (registre início/fim em `/var/log/vcert.log`).
- Teste a renovação ponta a ponta com `--force-renew` em um ambiente de homologação.

## 6. Segurança operacional

- Habilite `backupFiles: true` para reverter rapidamente em caso de problema.
- Monitore o `vcert.log` e alerte sobre falhas de renovação.
- Tenha alerta independente de **expiração** (ex.: blackbox/monitoramento externo) — não confie só na automação.
- Documente qual zone/política cada host usa.

## 7. Validação antes de aplicar

```bash
vcert run -f playbooks/seu-playbook.yaml --validate
```

Use sempre antes de promover mudanças para produção.

## 8. Versionamento

- Versione os **playbooks** (sem segredos) num repositório como este.
- Use o `CHANGELOG.md` para registrar mudanças relevantes.
- Faça revisão por PR antes de alterar playbooks de produção.
