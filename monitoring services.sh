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
