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
