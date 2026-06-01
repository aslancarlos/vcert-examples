# Política de Segurança

## Reportando uma vulnerabilidade

Se você encontrar uma vulnerabilidade de segurança neste repositório (ou um segredo exposto acidentalmente), **não abra uma issue pública** com os detalhes.

1. Use o canal privado **GitHub Security Advisories** ("Security" → "Report a vulnerability") deste repositório, ou
2. Entre em contato diretamente com o mantenedor.

Descreva:
- O problema e o impacto potencial.
- Passos para reproduzir.
- Arquivo(s) e linha(s) envolvidos, se aplicável.

## Boas práticas de segredos

Este repositório contém **apenas exemplos**. Antes de usar em produção:

- **Nunca** faça commit de tokens, API keys, senhas, chaves privadas (`.key`, `.pem`, `.p12`, `.jks`) ou CSRs reais. O [`.gitignore`](.gitignore) já bloqueia esses padrões, mas confira sempre com `git status` antes do commit.
- Forneça segredos via **variáveis de ambiente** (`{{ Env "VCERT_TOKEN" }}`) ou um **cofre** (CyberArk Conjur, HashiCorp Vault, etc.).
- Restrinja permissões de arquivos de chave: `chmod 600` e dono igual ao usuário do serviço.
- Rotacione tokens e API keys periodicamente e revogue os que vazarem.

## Se um segredo foi exposto

1. **Revogue imediatamente** o token/API key no CyberArk Certificate Manager.
2. **Reemita** o certificado afetado se a chave privada vazou.
3. Remova o segredo do histórico do Git (ex.: `git filter-repo`) e force o push.
4. Audite acessos que possam ter usado o segredo.
