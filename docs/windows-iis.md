# Windows / IIS

How to use VCERT on Windows to install the certificate into the **Windows Certificate Store (CAPI)** and **bind it to IIS** automatically.

## Overview

On Windows, instead of writing PEM files, VCERT installs the certificate directly into the store using `format: CAPI`. The post-renewal hook (PowerShell) locates the new certificate and associates it with the site's HTTPS binding in IIS.

## Prerequisites

- `vcert.exe` ([releases](https://github.com/Venafi/vcert/releases) — Windows artifact).
- PowerShell with the **WebAdministration** module (ships with IIS / RSAT).
- Run as **Administrator** (writing to `LocalMachine\My` and binding in IIS require elevation).

## Suggested layout

```
C:\vcert\vcert.exe                     # binary
C:\vcert\playbook.yaml                 # playbook
C:\vcert\scripts\post-renew-iis.ps1    # binding hook
C:\vcert\vcert.log                     # log
```

## CAPI playbook fields

| Field | Description |
|---|---|
| `format: CAPI` | Installs into the Windows Certificate Store. |
| `capiLocation` | `LocalMachine\\My` (computer) or `CurrentUser\\My` (user). Escape the backslashes. |
| `capiFriendlyName` | Friendly name shown in `mmc` / used by the script to find the cert. |
| `capiIsNonExportable` | `true` = private key non-exportable (more secure). |
| `backupFiles` | `true` makes a backup before overwriting. |
| `afterInstallAction` | Command run via `powershell.exe` after installing (performs the binding). |

> The playbook does **not** bind by itself — that is done by PowerShell in the `afterInstallAction`. See [`scripts/post-renew-iis.ps1`](../scripts/post-renew-iis.ps1).

## Run

```powershell
$env:VCERT_TOKEN = "your_access_token"
C:\vcert\vcert.exe run -f C:\vcert\playbook.yaml
```

## Scheduling (Task Scheduler)

Run twice a day. VCERT only renews within the `renewBefore` window.

```powershell
$action  = New-ScheduledTaskAction -Execute "C:\vcert\vcert.exe" `
           -Argument "run -f C:\vcert\playbook.yaml"
$trigger = New-ScheduledTaskTrigger -Daily -At 6am
$trigger2 = New-ScheduledTaskTrigger -Daily -At 6pm
# Run as SYSTEM (or a service account with access to the store and IIS).
Register-ScheduledTask -TaskName "VCERT-IIS" `
  -Action $action -Trigger @($trigger, $trigger2) `
  -User "SYSTEM" -RunLevel Highest -Description "IIS certificate renewal via VCERT"
```

> Set `VCERT_TOKEN` as a **machine** environment variable (or read it from a vault at the start of the script), since the task runs without your session.

## Tips

- For sites with a **host header** (SNI), the script uses `SslFlags 1` and `-HostHeader`.
- After renewal, the script **re-associates** the binding with the new thumbprint — no IIS restart needed.
- If you prefer to restart the service anyway: `afterInstallAction: "powershell.exe -Command Restart-Service W3SVC"`.
- To troubleshoot, check `C:\vcert\vcert.log`.
