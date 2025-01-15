# ConfigureWinRM.ps1
$ErrorActionPreference = "Stop"

Write-Output "Starting WinRM configuration..."

# Set all network connections to Private
Write-Output "Setting network connections to Private..."
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromProgID("HNetCfg.HNetShare"))
$connections = $networkListManager.EnumEveryConnection
foreach($connection in $connections) {
    $network = $networkListManager.NetConnectionProps($connection)
    $network = $networkListManager.GetNetworkProperties($connection)
    $network.SetCategory(1) # 1 = Private, 0 = Public, 2 = Domain
}

# Configure WinRM
Write-Output "Configuring WinRM..."
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'

# Remove existing firewall rule if it exists
Write-Output "Configuring firewall rules..."
$ruleName = "WinRM-HTTP-In-TCP"
$existingRule = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
if ($existingRule) {
    Remove-NetFirewallRule -Name $ruleName
}

# Create new firewall rule
New-NetFirewallRule -Name $ruleName `
    -DisplayName "Windows Remote Management (HTTP-In)" `
    -Direction Inbound -Protocol TCP -LocalPort 5985 `
    -Action Allow

# Enable PSRemoting
Write-Output "Enabling PSRemoting..."
Enable-PSRemoting -Force -SkipNetworkProfileCheck

Write-Output "WinRM configuration completed successfully"
