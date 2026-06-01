# Contribuindo

Obrigado pelo interesse em contribuir com o **vcert-examples**! 🎉

## Como contribuir

1. Faça um **fork** do repositório.
2. Crie uma branch descritiva: `git checkout -b feat/exemplo-haproxy`.
3. Faça suas mudanças seguindo as diretrizes abaixo.
4. Abra um **Pull Request** descrevendo o que mudou e por quê.

## Diretrizes

### Exemplos e playbooks

- Use **valores fictícios** (`suaempresa.com.br`, caminhos genéricos, URLs de exemplo).
- **Nunca** inclua segredos reais (tokens, senhas, chaves, CSRs).
- Comente os campos importantes em **português** para facilitar o entendimento.
- Valide o playbook antes de enviar:

  ```bash
  vcert run -f playbooks/seu-exemplo.yaml --validate
  ```

- Garanta que o YAML é válido:

  ```bash
  # com yamllint (opcional)
  yamllint playbooks/seu-exemplo.yaml
  ```

### Documentação

- Mantenha o `README.md` e o `docs/` atualizados quando adicionar um exemplo.
- Use Markdown limpo, com blocos de código identificados pela linguagem.

### Scripts

- Scripts de shell devem começar com `#!/usr/bin/env bash` e `set -euo pipefail`.
- Torne-os idempotentes sempre que possível.

## Checklist do Pull Request

- [ ] Não há segredos no diff (`git diff` revisado).
- [ ] Playbooks novos foram validados com `--validate`.
- [ ] Documentação atualizada quando necessário.
- [ ] Entrada adicionada ao `CHANGELOG.md` (seção *Unreleased*).

## Código de conduta

Seja respeitoso e colaborativo. Discussões técnicas são bem-vindas; ataques pessoais não.
