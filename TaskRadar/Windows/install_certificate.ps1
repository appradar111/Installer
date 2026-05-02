# PowerShell script to install the TaskRadar self-signed certificate
# This script must be run as Administrator

$certFile = Join-Path $PSScriptRoot "TaskRadar.cer"

if (-not (Test-Path $certFile)) {
    Write-Error "Certificate file TaskRadar.cer not found in the current directory."
    exit 1
}

# Check for Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script needs to be run as Administrator. Attempting to relaunch..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Installing TaskRadar.cer to Trusted People and Root stores..." -ForegroundColor Cyan

try {
    # Load the certificate to get its thumbprint
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFile)
    $thumbprint = $cert.Thumbprint
    Write-Host "Certificate Thumbprint: $thumbprint" -ForegroundColor Gray

    # Remove existing certificate with same thumbprint if it exists
    $stores = "Cert:\LocalMachine\TrustedPeople", "Cert:\LocalMachine\Root"
    foreach ($storePath in $stores) {
        if (Test-Path "$storePath\$thumbprint") {
            Write-Host "Removing existing certificate from $storePath..." -ForegroundColor Yellow
            Remove-Item "$storePath\$thumbprint" -Force
        }
    }

    # Import to Trusted People
    Import-Certificate -FilePath $certFile -CertStoreLocation "Cert:\LocalMachine\TrustedPeople"
    
    # Import to Root
    Import-Certificate -FilePath $certFile -CertStoreLocation "Cert:\LocalMachine\Root"
    
    Write-Host "`nSuccess! The certificate has been installed and trusted." -ForegroundColor Green
    Write-Host "Publisher: $($cert.Subject)" -ForegroundColor Green
    Write-Host "You can now install the TaskRadar.msix package." -ForegroundColor Green
}
catch {
    Write-Error "Failed to install the certificate: $($_.Exception.Message)"
    exit 1
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
