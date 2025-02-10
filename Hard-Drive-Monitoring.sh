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
