## Steps to Set Up Telegram Bot:

    Create a Telegram Bot:
        Open Telegram and search for BotFather.
        Type /newbot and follow the instructions to create a bot.
        Copy the bot Token provided by BotFather.

    Get Your Chat ID:
        Open https://t.me/username_of_your_bot and start a chat with it.
        Open this URL in your browser (replace YOUR_BOT_TOKEN with your token):
```
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```
Send any message to the bot.
Check the response; look for "chat":{"id":YOUR_CHAT_ID} and copy the chat ID.
## Bash Script to Monitor Disk Usage & Send Telegram Alert
```
#!/bin/bash

# Set threshold percentage
THRESHOLD=90

# Get the disk usage percentage of the root filesystem
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# Telegram Bot Details
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# Check if usage exceeds the threshold
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    MESSAGE="🚨 *Alert:* Disk usage on $(hostname) is at *${USAGE}%*! 🚨"
    
    # Send message to Telegram
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$MESSAGE" \
        -d "parse_mode=Markdown"
fi

```

# How to Use:

1.   Replace YOUR_BOT_TOKEN and YOUR_CHAT_ID in the script.
2.   Save it as disk_monitor.sh.
3.   Make it executable:
```
chmod +x disk_monitor.sh
```

4.Add it to cron for automatic monitoring:
```
0 * * * * /path/to/disk_monitor.sh
```
Now, whenever disk usage exceeds 90%, you will receive a Telegram alert!

in continue we deep on bash script:

Script Breakdown:
```
#!/bin/bash
```
    This is called a shebang. It tells the system to execute the script using the Bash shell.
```
# Set threshold percentage
THRESHOLD=90
```
    We define a threshold of 90% disk usage. If usage goes above this, an alert is triggered.
```
# Get the disk usage percentage of the root filesystem
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
```
    df / → Gets the disk usage of the root / partition.
    awk 'NR==2 {print $5}' → Extracts the 5th column (which shows disk usage percentage) from the second row.
    sed 's/%//' → Removes the % symbol to get a clean numeric value.

### Telegram Bot Configuration
```
# Telegram Bot Details
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
```
    BOT_TOKEN → Replace with your Telegram bot’s token (from BotFather).
    CHAT_ID → Replace with your Telegram chat ID.

###Checking Disk Usage Against Threshold
```
# Check if usage exceeds the threshold
if [ "$USAGE" -ge "$THRESHOLD" ]; then
```
    This if condition checks if USAGE is greater than or equal to (-ge) THRESHOLD (90%).
    If disk usage is above 90%, the script will proceed to send an alert.

## Preparing Alert Message
```
    MESSAGE="🚨 *Alert:* Disk usage on $(hostname) is at *${USAGE}%*! 🚨"
```
    $(hostname) → Retrieves the system’s hostname.
    The message uses Markdown formatting (bold text using * for Telegram).

##Sending Telegram Notification
```
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$MESSAGE" \
        -d "parse_mode=Markdown"
```
    curl -s → Sends a silent (-s) HTTP POST request.
    The request is sent to the Telegram API:
    https://api.telegram.org/bot$BOT_TOKEN/sendMessage
    -d "chat_id=$CHAT_ID" → Specifies which Telegram chat will receive the message.
    -d "text=$MESSAGE" → The actual message text.
    -d "parse_mode=Markdown" → Enables Markdown formatting for bold text.

##End of Script
```
fi
```
    Closes the if condition. If the disk usage is below 90%, nothing happens.

### How to Set Up Automatic Monitoring

1. Save the script as disk_monitor.sh:
```
nano disk_monitor.sh
```
(Paste the script, then press CTRL+X, Y, and Enter to save)

2. Make it executable:
```
chmod +x disk_monitor.sh
```
3. Run it manually (for testing):
```
./disk_monitor.sh
```
4. Schedule it with cron (runs every hour):
```
crontab -e
```
Add this line at the end:
```
    0 * * * * /path/to/disk_monitor.sh
```
Summary

    The script monitors disk usage using df.
    If usage exceeds 90%, it sends a Telegram alert.
    Uses cron for automated execution.
