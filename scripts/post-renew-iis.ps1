# =============================================================================
# Hook POS-RENOVACAO - Windows / IIS
# Faz o bind do certificado recem-instalado (CAPI) no site do IIS.
# Chamado pelo afterInstallAction do playbooks/windows-iis.yaml.
#
# Uso:
#   powershell.exe -ExecutionPolicy Bypass -File post-renew-iis.ps1 `
#     -SiteName 'Default Web Site' `
#     -HostHeader 'site.suaempresa.com.br' `
#     -FriendlyName 'site.suaempresa.com.br (VCERT)' `
#     -Port 443
# =============================================================================
param(
    [Parameter(Mandatory = $true)] [string]$SiteName,
    [Parameter(Mandatory = $true)] [string]$FriendlyName,
    [string]$HostHeader = "",
    [int]$Port = 443,
    [string]$StorePath = "Cert:\LocalMachine\My",
    [string]$LogFile = "C:\vcert\vcert.log"
)

$ErrorActionPreference = "Stop"

function Write-Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$ts [POS][iis] $msg"
}

try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Log "Iniciando bind no site '$SiteName' (porta $Port, host '$HostHeader')"

    # 1) Localiza o certificado mais novo pelo nome amigavel (o recem-renovado).
    $cert = Get-ChildItem -Path $StorePath |
            Where-Object { $_.FriendlyName -eq $FriendlyName } |
            Sort-Object NotAfter -Descending |
            Select-Object -First 1

    if (-not $cert) {
        throw "Certificado com FriendlyName '$FriendlyName' nao encontrado em $StorePath"
    }
    $thumb = $cert.Thumbprint
    Write-Log "Certificado encontrado. Thumbprint: $thumb (validade ate $($cert.NotAfter))"

    # 2) Garante que existe o binding HTTPS no site.
    $existing = Get-WebBinding -Name $SiteName -Protocol "https" -ErrorAction SilentlyContinue |
                Where-Object { $_.bindingInformation -like "*:$Port`:$HostHeader" }

    if (-not $existing) {
        if ([string]::IsNullOrEmpty($HostHeader)) {
            New-WebBinding -Name $SiteName -Protocol "https" -Port $Port
        } else {
            # SslFlags 1 = SNI (necessario quando ha host header).
            New-WebBinding -Name $SiteName -Protocol "https" -Port $Port -HostHeader $HostHeader -SslFlags 1
        }
        Write-Log "Binding HTTPS criado"
    } else {
        Write-Log "Binding HTTPS ja existente, reutilizando"
    }

    # 3) Associa (ou reassocia) o certificado ao binding.
    $binding = Get-WebBinding -Name $SiteName -Protocol "https" |
               Where-Object { $_.bindingInformation -like "*:$Port`:$HostHeader" } |
               Select-Object -First 1
    $binding.AddSslCertificate($thumb, "My")
    Write-Log "Certificado associado ao binding com sucesso"

    Write-Log "Renovacao IIS concluida"
    exit 0
}
catch {
    Write-Log "ERRO: $($_.Exception.Message)"
    exit 1
}
