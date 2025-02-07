you can use Bash scripting to monitor services using systemctl in Linux. The script can check if a service is running and restart it if necessary. You can also configure it to send a Telegram alert or email notification when a service is down.
🔹## Basic Script: Checking and Restarting a Service

This script checks if a specific service (e.g., nginx) is running. If the service is not active, it will restart it.
Script: service_monitor.sh
```
#!/bin/bash

# Define the service name
SERVICE="nginx"

# Check if the service is running
if systemctl is-active --quiet "$SERVICE"; then
    echo "$(date): $SERVICE is running."
else
    echo "$(date): $SERVICE is NOT running. Restarting..."
    
    # Restart the service
    systemctl restart "$SERVICE"

    # Check again if the restart was successful
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$(date): Successfully restarted $SERVICE."
    else
        echo "$(date): Failed to restart $SERVICE!"
    fi
fi
```
🔹## Advanced Script: With Telegram Notification

This script will send a Telegram alert if the service fails to restart.
Script: service_monitor_telegram.sh
```
#!/bin/bash

# Define service name
SERVICE="nginx"

# Telegram Bot Details
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# Function to send a Telegram message
send_telegram_message() {
    MESSAGE="🚨 *Alert:* $SERVICE is down on $(hostname)! Attempting restart..."
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$MESSAGE" \
        -d "parse_mode=Markdown"
}

# Check service status
if systemctl is-active --quiet "$SERVICE"; then
    echo "$(date): $SERVICE is running."
else
    echo "$(date): $SERVICE is NOT running. Restarting..."
    send_telegram_message
    
    # Restart service
    systemctl restart "$SERVICE"

    # Verify if restart was successful
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$(date): Successfully restarted $SERVICE."
    else
        echo "$(date): Failed to restart $SERVICE!"
        send_telegram_message
    fi
fi
```

🔹## Automate with Cron

To run the script automatically, add it to cron:

1️⃣## Make the script executable:
```
chmod +x service_monitor_telegram.sh
```
2️⃣## Edit cron jobs:
```
crontab -e
```
3️⃣## Add this line to check every 5 minutes:
```
*/5 * * * * /path/to/service_monitor_telegram.sh
```
🔹## Summary

✅ Checks if the service is running
✅ Restarts the service if it's down
✅ Sends a Telegram alert if the restart fails
✅ Automates monitoring with cron
