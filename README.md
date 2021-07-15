# WinSSHD Fail2Ban

A small PowerShell script that creates Windows firewall blocking rules from authentication failures in [Bitvise SSH Server](https://www.bitvise.com/ssh-server) logs, inspired by [Fail2Ban](https://www.fail2ban.org/wiki/index.php/Main_Page).

I wrote this because I wasn't satisfied with Bitvise SSH Server making only temporary bans, and not giving you the option of banning obfuscation failures and other types of events.


## Log scrapping script

### Usage


Will most certainly need an elevated command prompt.

```powershell
.\winsshd_fail2ban.ps1 "<path_to_the_log_file>"
```

### What it does

1. Check the given log for authentication failures.
2. Retrieve the corresponding IPs.
3. Check if there's already an existing blocking rule for each IP.
4. Create a new rule if it does not exist.

All firewall rules are created in the group "WinSSHD Fail2Ban" so they can easily be retrieved.


## Event subscriber script

### Usage

First, you need to configure Bitvise SSH Server to write into the Windows application event log.

```cmd
powershell -NoExit winevent_subscriber.ps1
```

You can put that in a scheduled task.

The `-NoExit` option is required.
The script uses `Register-ObjectEvent`, which is only valid for the current PowerShell session.
If you close the session, it stops working.

### What it does

The script listens for BvSshServer events in the event log.
When a corresponding event is fired, the script checks the event type and IP address.
If the event type is in the list of bannable events and the IP is not excluded, it immediately adds a new blocking firewall rule for that IP.

The whole event message is added to the rule description, so you can check precisely what event caused its creation.

### Cleaning up

There may be multiple simultaneous connection attempts from the same address, which result in duplicate rules.  
For lack of a better system, you can use the `remove_duplicates` script to cleanup these rules.  
