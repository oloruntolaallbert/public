# ConfigureWinRM.ps1
$ErrorActionPreference = "Stop"

# Configure WinRM
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'

# Configure firewall rules
New-NetFirewallRule -Name "WinRM-HTTP-In-TCP" `
    -DisplayName "Windows Remote Management (HTTP-In)" `
    -Direction Inbound -Protocol TCP -LocalPort 5985 `
    -Action Allow

# Enable PSRemoting
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# Set network profile to private
$networkProfile = Get-NetConnectionProfile
Set-NetConnectionProfile -NetworkCategory Private -InterfaceIndex $networkProfile.InterfaceIndex

Write-Host "WinRM has been configured successfully"
