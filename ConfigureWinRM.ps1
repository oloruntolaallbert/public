# ConfigureWinRM.ps1
$ErrorActionPreference = "Stop"

Write-Output "Starting WinRM configuration..."

# Set network profile to private for all connections
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Configure WinRM
Write-Output "Configuring WinRM..."
Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Configure firewall
Write-Output "Configuring firewall rules..."
$ruleName = "WinRM-HTTP-In-TCP"
$existingRule = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
if ($existingRule) {
    Remove-NetFirewallRule -Name $ruleName
}

New-NetFirewallRule -Name $ruleName `
    -DisplayName "Windows Remote Management (HTTP-In)" `
    -Direction Inbound -Protocol TCP -LocalPort 5985 `
    -Action Allow

Write-Output "WinRM configuration completed successfully"
