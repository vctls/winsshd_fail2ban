# Create an Action script block to execute in response to an event.
$Action = {

    # Exclusion list.
    # TODO Make it configurable.
    $excluded = ,'127.0.0.1'

    # List of BvSSH event types that are considered as authentication failures
    # and should result in a ban. 
    # TODO Make it configurable.
    $failureTypes = 'I_CONNECT_OBFUSCATION_START_ERROR', 'I_LOGON_AUTH_FAILED'

    # Get the original event entry
    $entry = $event.SourceEventArgs.Entry

    if ($entry.EventId -eq 4097 -and $entry.Source -eq 'BvSshServer') 
    {
        # Get IP address from event message.
        # Message looks like this:
        # event
        #     time: 2020-11-17 11:25:45.183931 +0100
        #     app: BvSshServer 8.44
        #     name: I_CONNECT_OBFUSCATION_START_ERROR
        #     desc: Error starting SSH protocol obfuscation.
        #     session
        #         id: 1049
        #         service: SSH
        #         remoteAddress: 127.0.0.1:32109
        #     parameters
        #         statusCode: BadObfsKeyword

        # Check the event type.
        $entry.Message -match 'name: ([A-Z0-9_]+)'
        $type = $Matches.1

        if ($type -in $failureTypes) {
             # TODO Make it work for IPV6. Maybe.
            $entry.Message -match 'remoteAddress: ([0-9\.]+):\d+'
            $ip = $Matches.1

            $group = "WinSSHD Fail2Ban"

            # If the address is not in the exclusion list, create a new blocking firewall rule.
            if($ip -notin $excluded) {
                New-NetFirewallRule `
                -Group $group `
                -DisplayName "$group $ip" `
                -RemoteAddress $ip `
                -Direction Inbound `
                -Action Block
            } else {
                #[System.Windows.MessageBox]::Show($Matches.1)
            }
        }
    }

}

$Log = [System.Diagnostics.EventLog]'Application'
# Register a new EventSubscriber
Register-ObjectEvent `
  -InputObject $log `
  -EventName EntryWritten `
  -SourceIdentifier 'WinSSHD_fail2ban' `
  -Action $Action
