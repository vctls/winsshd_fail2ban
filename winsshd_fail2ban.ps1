param([string]$path="")

if ($path.Length -eq 0) {
    Write-Host "You must provide the path to a WinSSHD log file."
    exit
}

# Log file name examples: 
# BvSshServer20200130-055227539-P0100.log
# BvSshServer20200612-090506535-P0200.log
# C:\Program Files\Bitvise SSH Server\Logs\BvSshServer20201110-202611845-P0100.log
# Not sure what the P0X00 part is.

Write-Host "Starting WinSSHD Fail2Ban"

# Use group constant for firewall rule group and name.
Set-Variable group -Option Constant -Value "WinSSHD Fail2Ban"

Write-Host "Parsing log..."

# TODO Parse multiple scripts? Take log file path as argument?
[xml]$log = Get-Content $path
$failures = @()

foreach ($event in $log.log.event) {
    # TODO Add other events, like authentication failures and automatic bans.
    if ($event.name -in "I_CONNECT_OBFUSCATION_START_ERROR", "I_LOGON_AUTH_FAILED") {
        $address = (
            $event.session.remoteAddress  |
                Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" -AllMatches
        ).Matches.Value
        if ($address -notin $failures) {
            $failures += $address
        }
    }
}

if ($failures.count -eq 0) {
    Write-Host "`nNo failed authentication attemps found. Exiting..."
    exit
}

$failures = $failures | Sort-Object { $_ -as [System.Version]}

Write-Host "`nThe following IP addresses have failed authentication:"

foreach ($failure in $failures) {
    Write-Host($failure);
}

Write-Host "`nLoading firewall rules..."
$rules = Get-NetFirewallRule -Group $group -ErrorAction SilentlyContinue | 
    Get-NetFirewallAddressFilter | 
    Select-Object -ExpandProperty "RemoteAddress"

if ($rules.count -eq 0) {
    Write-Host "`nNo rule found."
}

$rules = $rules | Sort-Object { $_ -as [System.Version]}

foreach ($rule in $rules) {
    Write-Host($rule)
}

$notInRules =@()
foreach ($failure in $failures) {
    if ($failure -notin $rules) {
        $notInRules += $failure
    }
}

if ($notInRules.count -eq 0) {
    Write-Host "`nAll addresses already have a corresponding rule. Exiting..."
    exit
}

Write-Host "`nThe following addresses have no corresponding rule:"

foreach ($notInRules in $ip) {
    Write-Host $ip
}

Write-Host "`nCreating firewall rules..."

foreach ($ip in $notInRules) {
    New-NetFirewallRule `
        -Group $group `
        -DisplayName "$group $ip" `
        -RemoteAddress $ip `
        -Direction Inbound `
        -Action Block
}

Write-Host "`nAll addresses have been blocked in the firewall. Exiting..."