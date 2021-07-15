
$group = "WinSSHD Fail2Ban"
$prefixLength = $group.Length + 1;

Write-Host "Listing duplicate firewall rules..."

$addresses =@()
$duplicates =@()
foreach ($rule in Get-NetFirewallRule -Group $group -ErrorAction SilentlyContinue) {
    # For some reason, Get-NetFirewallAddressFilter is ludicrously slow.
    # Since our custom rules have the address in the title, we're going to use that instead.
    $address = $rule.DisplayName.Substring($prefixLength);
    if ($address -in $addresses) {
        $duplicates += $rule
        Write-Host -NoNewline "X"
    } else {
        $addresses += $address
        Write-Host -NoNewline "."
    }
}

$count = $duplicates.count
Write-Host "`nRemoving $count duplicates..."

# This is still slow as hell.
# There might be a way of speeding things up by deleting the rules directly from the registry.
# https://stackoverflow.com/a/40915201/5845942
Remove-NetFirewallRule -InputObject $duplicates

Write-Host "`nDuplicate rules have been removed."