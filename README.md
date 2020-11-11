# WinSSHD Fail2Ban

A small PowerShell script that creates Windows firewall blocking rules from authentication failures in Bitvise SSH Server logs.

I wrote this because I wasn't satisfied with Bitvise SSH Server making only temporary bans, and not giving you the option of banning obfuscation failures.

## Usage

Will most certainly need an elevated command prompt.

```powershell
.\winsshd_fail2ban.ps1 "<path_to_the_log_file>"
```

## What it does

1. Check the given log for authentication failures.
2. Retrieve the corresponding IPs.
3. Check if there's already an existing blocking rule for each IP.
4. Create a new rule if it does not exist.

All firewall rules are created in the group "WinSSHD Fail2Ban" so they can easily be retrieved.

## TODO

Loading existing firewall rules is slow. Find a better way to check if a rule exists.

Make automation easier with PowerShell jobs or the Task Scheduler.  
Automatically checking yesterday logs on logon would be nice. Or maybe even all unchecked logs.

Make it possible to automatically delete all rules in the "WinSSHD Fail2Ban" group.
