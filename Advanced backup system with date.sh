#!/bin/bash

# Define variables
SOURCE_DIR="/home/user/data"
BACKUP_DIR="/backups"
REMOTE_USER="user"
REMOTE_HOST="remote_server_ip"
REMOTE_DIR="/remote_backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="backup_$DATE.tar.gz"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create a compressed backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "$(date): Backup created successfully: $BACKUP_FILE"
else
    echo "$(date): Backup failed!"
    exit 1
fi

# Transfer backup to remote server using SCP
scp "$BACKUP_DIR/$BACKUP_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# Check if transfer was successful
if [ $? -eq 0 ]; then
    echo "$(date): Backup transferred successfully to $REMOTE_HOST:$REMOTE_DIR"
else
    echo "$(date): Backup transfer failed!"
    exit 1
fi

# Remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +7 -exec rm {} \;

echo "$(date): Old backups cleaned up."
