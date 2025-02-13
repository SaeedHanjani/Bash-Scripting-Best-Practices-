#!/bin/bash

# Source the Telegram alert function
source /home/user/scripts/telegram_alert.sh  # Adjust the path!

# Log file to monitor
LOG_FILE="/var/log/auth.log"  # For Debian/Ubuntu
# LOG_FILE="/var/log/secure"  # Uncomment for CentOS/RHEL

TMP_FILE="/tmp/failed_login_lastpos"

# Ensure TMP_FILE exists
if [ ! -f "$TMP_FILE" ]; then
    echo "0" > "$TMP_FILE"
fi

# Ensure LOG_FILE exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file $LOG_FILE does not exist!"
    exit 1
fi

# Read last position
LAST_POS=$(cat "$TMP_FILE")
CURRENT_POS=$(wc -c < "$LOG_FILE")

# Ensure LAST_POS is a number
if ! [[ "$LAST_POS" =~ ^[0-9]+$ ]]; then
    LAST_POS=0
fi

# Handle log rotation
if [ "$CURRENT_POS" -lt "$LAST_POS" ]; then
    LAST_POS=0
fi

# Extract new failed login attempts
NEW_LINES=$(tail -c +"$((LAST_POS + 1))" "$LOG_FILE" | grep "Failed password")

# Update last position
echo "$CURRENT_POS" > "$TMP_FILE"

# Send Telegram alert if new failed logins detected
if [ ! -z "$NEW_LINES" ]; then
    MESSAGE="🚨 Failed SSH login attempts detected on $(hostname) 🚨%0A"
    MESSAGE+="$(echo "$NEW_LINES" | tail -5 | sed 's/$/%0A/g')"

    send_telegram_alert "$MESSAGE"
fi
