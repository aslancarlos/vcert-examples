# Installing VCERT

VCERT is distributed as a single binary (no dependencies). Download the release matching your platform.

## Linux (x86_64 / ARM)

```bash
# 1) Download the latest release (adjust the filename for your architecture)
curl -L -o vcert.zip https://github.com/Venafi/vcert/releases/latest/download/vcert_linux.zip

# 2) Unzip
unzip vcert.zip

# 3) Make it executable
chmod +x vcert

# 4) Move it to a directory on your PATH
sudo mv vcert /usr/local/bin/vcert

# 5) Verify
vcert --version
```

> For ARM (e.g., Raspberry Pi, Graviton), use the matching `vcert_linux_arm` artifact on the [releases](https://github.com/Venafi/vcert/releases) page.

## Integrity verification (recommended)

Always check the checksum published with the release before installing in production:

```bash
sha256sum vcert.zip
# compare with the value published on the releases page
```

## Suggested production layout

```
/usr/local/bin/vcert          # binary
/etc/vcert/playbook.yaml      # playbook (chmod 640)
/etc/vcert/vcert.env          # variables with secrets (chmod 600)
/var/log/vcert.log            # log
```

## Next steps

- [Authentication](authentication.md)
- [Playbook reference](playbook-reference.md)
- [Best practices](best-practices.md)
