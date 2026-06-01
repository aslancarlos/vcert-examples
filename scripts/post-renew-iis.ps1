# =============================================================================
# POST-RENEWAL hook - Windows / IIS
# Binds the freshly installed certificate (CAPI) to the IIS site.
# Called by the afterInstallAction in playbooks/windows-iis.yaml.
#
# Usage:
#   powershell.exe -ExecutionPolicy Bypass -File post-renew-iis.ps1 `
#     -SiteName 'Default Web Site' `
#     -HostHeader 'site.yourcompany.com' `
#     -FriendlyName 'site.yourcompany.com (VCERT)' `
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
    Add-Content -Path $LogFile -Value "$ts [POST][iis] $msg"
}

try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Log "Starting binding on site '$SiteName' (port $Port, host '$HostHeader')"

    # 1) Find the newest certificate by friendly name (the one just renewed).
    $cert = Get-ChildItem -Path $StorePath |
            Where-Object { $_.FriendlyName -eq $FriendlyName } |
            Sort-Object NotAfter -Descending |
            Select-Object -First 1

    if (-not $cert) {
        throw "Certificate with FriendlyName '$FriendlyName' not found in $StorePath"
    }
    $thumb = $cert.Thumbprint
    Write-Log "Certificate found. Thumbprint: $thumb (valid until $($cert.NotAfter))"

    # 2) Ensure the HTTPS binding exists on the site.
    $existing = Get-WebBinding -Name $SiteName -Protocol "https" -ErrorAction SilentlyContinue |
                Where-Object { $_.bindingInformation -like "*:$Port`:$HostHeader" }

    if (-not $existing) {
        if ([string]::IsNullOrEmpty($HostHeader)) {
            New-WebBinding -Name $SiteName -Protocol "https" -Port $Port
        } else {
            # SslFlags 1 = SNI (required when a host header is present).
            New-WebBinding -Name $SiteName -Protocol "https" -Port $Port -HostHeader $HostHeader -SslFlags 1
        }
        Write-Log "HTTPS binding created"
    } else {
        Write-Log "HTTPS binding already exists, reusing it"
    }

    # 3) Associate (or re-associate) the certificate with the binding.
    $binding = Get-WebBinding -Name $SiteName -Protocol "https" |
               Where-Object { $_.bindingInformation -like "*:$Port`:$HostHeader" } |
               Select-Object -First 1
    $binding.AddSslCertificate($thumb, "My")
    Write-Log "Certificate associated with the binding successfully"

    Write-Log "IIS renewal complete"
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
