# Instalação do VCERT

O VCERT é distribuído como um binário único (sem dependências). Baixe o release correspondente à sua plataforma.

## Linux (x86_64 / ARM)

```bash
# 1) Baixe o release mais recente (ajuste o nome do arquivo conforme a arquitetura)
curl -L -o vcert.zip https://github.com/Venafi/vcert/releases/latest/download/vcert_linux.zip

# 2) Descompacte
unzip vcert.zip

# 3) Dê permissão de execução
chmod +x vcert

# 4) Mova para um diretório no PATH
sudo mv vcert /usr/local/bin/vcert

# 5) Verifique
vcert --version
```

> Para ARM (ex.: Raspberry Pi, Graviton), use o artefato `vcert_linux_arm` correspondente na página de [releases](https://github.com/Venafi/vcert/releases).

## Verificação de integridade (recomendado)

Sempre confira o checksum publicado no release antes de instalar em produção:

```bash
sha256sum vcert.zip
# compare com o valor publicado na página de releases
```

## Estrutura sugerida em produção

```
/usr/local/bin/vcert          # binário
/etc/vcert/playbook.yaml      # playbook (chmod 640)
/etc/vcert/vcert.env          # variáveis com segredos (chmod 600)
/var/log/vcert.log            # log
```

## Próximos passos

- [Autenticação](authentication.md)
- [Referência do playbook](playbook-reference.md)
- [Boas práticas](best-practices.md)
