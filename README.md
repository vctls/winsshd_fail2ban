# WinSSHD Fail2Ban

A small PowerShell script that creates Windows firewall blocking rules from authentication failures in Bitvise SSH Server logs.

I wrote this because I wasn't satisfied with Bitvise SSH Server making only temporary bans, and not giving you the option of banning obfuscation failures.

## Usage

Will most certainly need an elevated command prompt.

```powershell
.\winsshd_fail2ban.ps1 "<path_to_the_log_file>"
```

