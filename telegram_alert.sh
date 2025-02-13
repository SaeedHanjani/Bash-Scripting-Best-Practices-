#!/bin/bash

# Telegram Bot API Token and Chat ID

TOKEN="8089618976:AAFwGZQuoXLgHRyNcdbrenXDEh3V3NGgRo4"
CHAT_ID="92330626"


# Function to send a Telegram message

send_telegram_alert() {
    local MESSAGE=$1
    local TELEGRAM_API="https://api.telegram.org/bot$TOKEN/sendMessage"
# با دستور curl براي اريال درخواست هاي http است. -s براي سايلنت مد است که خطاها و خروجي>
    curl -s -X POST "$TELEGRAM_API" -d "chat_id=$CHAT_ID" -d "text=$MESSAGE" -d "parse_>
}
