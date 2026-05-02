# This script installs the Room Radar certificate into the Trusted Root Certification Authorities store.
# It must be run as Administrator.

$certPath = Join-Path $PSScriptRoot "AppRadar.cer"

if (-not (Test-Path $certPath)) {
    Write-Error "Certificate file not found at $certPath"
    exit 1
}

Write-Host "Installing certificate to Trusted Root Certification Authorities (Local Machine)..."
try {
    Import-Certificate -FilePath $certPath -CertStoreLocation "Cert:\LocalMachine\Root"
    Write-Host "Success! The certificate is now trusted."
    Write-Host "You can now run the RoomRadarInstaller.msix file."
} catch {
    Write-Error "Failed to install certificate. Please make sure you are running this script as Administrator."
}

Pause
