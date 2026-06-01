# Windows / IIS

Como usar o VCERT no Windows para instalar o certificado no **Windows Certificate Store (CAPI)** e fazer o **bind no IIS** automaticamente.

## Visão geral

No Windows, em vez de gravar arquivos PEM, o vcert instala o certificado direto no store usando `format: CAPI`. O hook de pós-renovação (PowerShell) localiza o certificado novo e o associa ao binding HTTPS do site no IIS.

## Pré-requisitos

- `vcert.exe` ([releases](https://github.com/Venafi/vcert/releases) — artefato Windows).
- PowerShell com o módulo **WebAdministration** (vem com o IIS / RSAT).
- Executar como **Administrador** (escrita em `LocalMachine\My` e bind no IIS exigem privilégio).

## Instalação sugerida

```
C:\vcert\vcert.exe                     # binário
C:\vcert\playbook.yaml                 # playbook
C:\vcert\scripts\post-renew-iis.ps1    # hook de bind
C:\vcert\vcert.log                     # log
```

## Campos CAPI do playbook

| Campo | Descrição |
|---|---|
| `format: CAPI` | Instala no Windows Certificate Store. |
| `capiLocation` | `LocalMachine\\My` (computador) ou `CurrentUser\\My` (usuário). Escape as barras. |
| `capiFriendlyName` | Nome amigável exibido no `mmc` / usado pelo script para achar o cert. |
| `capiIsNonExportable` | `true` = chave privada não exportável (mais seguro). |
| `backupFiles` | `true` faz backup antes de sobrescrever. |
| `afterInstallAction` | Comando executado via `powershell.exe` após instalar (faz o bind). |

> O playbook **não** faz o bind sozinho — isso é feito pelo PowerShell no `afterInstallAction`. Veja [`scripts/post-renew-iis.ps1`](../scripts/post-renew-iis.ps1).

## Executar

```powershell
$env:VCERT_TOKEN = "seu_access_token"
C:\vcert\vcert.exe run -f C:\vcert\playbook.yaml
```

## Agendamento (Task Scheduler)

Rode 2x/dia. O vcert só renova dentro da janela `renewBefore`.

```powershell
$action  = New-ScheduledTaskAction -Execute "C:\vcert\vcert.exe" `
           -Argument "run -f C:\vcert\playbook.yaml"
$trigger = New-ScheduledTaskTrigger -Daily -At 6am
$trigger2 = New-ScheduledTaskTrigger -Daily -At 6pm
# Rode como SYSTEM (ou conta de serviço com acesso ao store e ao IIS).
Register-ScheduledTask -TaskName "VCERT-IIS" `
  -Action $action -Trigger @($trigger, $trigger2) `
  -User "SYSTEM" -RunLevel Highest -Description "Renovacao de certificado IIS via VCERT"
```

> Defina `VCERT_TOKEN` como variável de ambiente de **máquina** (ou leia de um cofre no início do script), pois a tarefa roda sem a sua sessão.

## Dicas

- Para sites com **host header** (SNI), o script usa `SslFlags 1` e `-HostHeader`.
- Após renovar, o script **reassocia** o binding ao novo thumbprint — não é preciso reiniciar o IIS.
- Se preferir reiniciar o serviço mesmo assim: `afterInstallAction: "powershell.exe -Command Restart-Service W3SVC"`.
- Para diagnosticar, veja `C:\vcert\vcert.log`.
