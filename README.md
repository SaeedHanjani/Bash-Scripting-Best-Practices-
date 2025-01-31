# bash
# first project
## Advanced monitoring of failed logins in linux with bash using Telegram Alert

To implement advanced monitoring of failed logins in Linux using Bash, you can create a custom script that analyzes system logs, tracks failed login attempts, and takes appropriate actions (e.g., sending alerts, blocking IPs, or logging details). Below is an example of a Bash script that monitors failed logins and provides advanced functionality.

How the Script Works
Log File Monitoring:

The script uses tail -Fn0 to monitor the /var/log/auth.log file in real-time.

It looks for lines containing "Failed password" to identify failed login attempts.

Extracting Details:

The script extracts the username and IP address from the log entry using grep and regular expressions.

Logging Failed Attempts:

Each failed login attempt is logged to a custom log file (/var/log/failed_logins.log).

Counting Attempts:

The script counts the number of failed attempts from each IP address.

Blocking IPs:

If an IP exceeds the maximum allowed failed attempts (MAX_ATTEMPTS), it is added to /etc/hosts.deny to block further access.

Sending Alerts:

An email alert is sent to the administrator when an IP is blocked.


How to Use the Script
Save the script to a file, e.g., monitor_failed_logins.sh.

Make the script executable:
```
bash
Copy
chmod +x monitor_failed_logins.sh
Run the script as root (since it requires access to system logs and /etc/hosts.deny):
```
```
bash
Copy
sudo ./monitor_failed_logins.sh
To run the script in the background, use:
```
```
bash
Copy
sudo nohup ./monitor_failed_logins.sh &
```

Additional Enhancements
Log Rotation:

Ensure the custom log file (/var/log/failed_logins.log) is rotated periodically to avoid growing too large.

Integration with fail2ban:

Use fail2ban in conjunction with this script for more advanced IP blocking and jail rules.

Database Logging:

Log failed login attempts to a database (e.g., MySQL or PostgreSQL) for easier analysis and reporting.

Slack/Telegram Alerts:

Replace the email alert with a Slack or Telegram notification using webhooks.


```
#!/bin/bash

# Configuration
LOG_FILE="/var/log/auth.log"  # Path to the auth log file (may vary based on distro)
FAILED_LOG="/var/log/failed_logins.log"  # Custom log file for failed login attempts
MAX_ATTEMPTS=3  # Maximum allowed failed attempts before taking action
BLOCKLIST_FILE="/etc/hosts.deny"  # File to block IPs (using hosts.deny)

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"  # Replace with your bot token
TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"  # Replace with your chat ID

# Function to send Telegram alerts
send_telegram_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$message" \
        -d "parse_mode=Markdown" > /dev/null
}

# Function to block an IP address
block_ip() {
    local ip="$1"
    if ! grep -q "$ip" "$BLOCKLIST_FILE"; then
        echo "ALL: $ip" >> "$BLOCKLIST_FILE"
        echo "Blocked IP: $ip" | tee -a "$FAILED_LOG"
        send_telegram_alert "🚨 *Blocked IP:* $ip\n🔒 Added to \`/etc/hosts.deny\`."
    fi
}

# Main script
echo "Starting failed login monitor..."

# Continuously monitor the log file
tail -Fn0 "$LOG_FILE" | while read -r line; do
    # Check for failed login attempts
    if echo "$line" | grep -q "Failed password"; then
        # Extract relevant details (username and IP address)
        username=$(echo "$line" | grep -oP 'for \K\S+')
        ip=$(echo "$line" | grep -oP 'from \K\S+')

        # Log the failed attempt
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        log_entry="$timestamp - Failed login attempt for user '$username' from IP '$ip'"
        echo "$log_entry" | tee -a "$FAILED_LOG"

        # Send Telegram alert for the failed attempt
        send_telegram_alert "⚠️ *Failed Login Attempt:*\n- User: \`$username\`\n- IP: \`$ip\`\n- Time: \`$timestamp\`"

        # Count the number of failed attempts for this IP
        attempt_count=$(grep -c "from $ip" "$FAILED_LOG")

        # Take action if the maximum attempts are exceeded
        if [ "$attempt_count" -ge "$MAX_ATTEMPTS" ]; then
            block_ip "$ip"
        fi
    fi
done

```


How to Set Up Telegram Alerts
Create a Telegram Bot:

Open Telegram and search for the BotFather.

Use the /newbot command to create a new bot.

Follow the instructions to name your bot and get the Bot Token.

Get Your Chat ID:

Start a chat with your bot.

Send a message to the bot.

Use the following URL to get your Chat ID (replace YOUR_BOT_TOKEN with your actual bot token):

```
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
Look for the chat.id field in the JSON response.
```
Update the Script:

Replace YOUR_TELEGRAM_BOT_TOKEN and YOUR_TELEGRAM_CHAT_ID in the script with your actual bot token and chat ID.

How the Telegram Alert Works
The send_telegram_alert function uses curl to send a POST request to the Telegram Bot API.

The message is formatted using Markdown for better readability.

Alerts are sent for:

Every failed login attempt.

When an IP is blocked.

Example Telegram Alerts
Failed Login Attempt:

```
⚠️ Failed Login Attempt:
- User: `root`
- IP: `192.168.1.100`
- Time: `2023-10-15 14:30:45`
```

Blocked IP:

```
🚨 Blocked IP: 192.168.1.100
🔒 Added to `/etc/hosts.deny`.
```
Running the Script
Save the script to a file, e.g., monitor_failed_logins.sh.

Make the script executable:
```
bash

chmod +x monitor_failed_logins.sh
Run the script as root:
```
```
Copy
sudo ./monitor_failed_logins.sh
To run the script in the background:
```
```
bash

sudo nohup ./monitor_failed_logins.sh &
```
Additional Notes
Ensure curl is installed on your system (most Linux distributions have it by default).

Test the Telegram alerts by manually triggering a failed login attempt (e.g., SSH with an incorrect password).

Customize the alert messages and thresholds (MAX_ATTEMPTS) as needed.
