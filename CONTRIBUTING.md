# Contributing

Thank you for your interest in contributing to **vcert-examples**! 🎉

## How to contribute

1. **Fork** the repository.
2. Create a descriptive branch: `git checkout -b feat/haproxy-example`.
3. Make your changes following the guidelines below.
4. Open a **Pull Request** describing what changed and why.

## Guidelines

### Examples and playbooks

- Use **placeholder values** (`yourcompany.com`, generic paths, example URLs).
- **Never** include real secrets (tokens, passwords, keys, CSRs).
- Comment the important fields in **English** to make them easy to understand.
- Validate the playbook before submitting:

  ```bash
  vcert run -f playbooks/your-example.yaml --validate
  ```

- Make sure the YAML is valid:

  ```bash
  # with yamllint (optional)
  yamllint playbooks/your-example.yaml
  ```

### Documentation

- Keep `README.md` and `docs/` up to date when you add an example.
- Use clean Markdown, with code blocks tagged by language.

### Scripts

- Shell scripts must start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Make them idempotent whenever possible.

## Pull Request checklist

- [ ] No secrets in the diff (`git diff` reviewed).
- [ ] New playbooks validated with `--validate`.
- [ ] Documentation updated when needed.
- [ ] Entry added to `CHANGELOG.md` (the *Unreleased* section).

## Code of conduct

Be respectful and collaborative. Technical discussions are welcome; personal attacks are not.
