🔹## Advanced Backup and Secure Transfer System

This script will:
✅ Create a compressed backup of a specified folder with a timestamp.
✅ Use SCP to transfer the backup to another server securely.
✅ Automate the process using SSH key authentication and cron.


🔹## Step 1: Set Up SSH Key Authentication

Before transferring files securely using scp, you need to set up SSH key-based authentication.
1️⃣### Generate SSH Key (if not already created)

Run this on your local server:
```
ssh-keygen -t rsa -b 4096
```
Press Enter for all prompts to use the default settings.
2️⃣### Copy the Key to the Remote Server

Replace user and remote_server_ip with your actual username and server IP:
```
ssh-copy-id user@remote_server_ip
```
Test SSH login without a password:
```
ssh user@remote_server_ip
```
If you log in successfully without a password, SSH key authentication is set up correctly.

🔹## Step 2: Create the Backup and Transfer Script

The script will:

    Create a timestamped backup of a folder (/home/user/data/).
    Compress it using tar and store it in /backups/.
    Transfer the backup to a remote server via scp.
    Delete old backups (older than 7 days) to save space.

Script: backup_transfer.sh
```
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
```
🔹 Step 3: Automate with Cron

To schedule the backup at 11 PM and transfer it at 12 AM:

1️⃣ Make the script executable:
```
chmod +x backup_transfer.sh
```
2️⃣ Edit the cron jobs:
```
crontab -e
```
3️⃣ Add these lines to schedule backup & transfer:
```
0 23 * * * /path/to/backup_transfer.sh  # Runs at 11 PM
```
This ensures the backup is created at 11 PM and transferred immediately after creation.
🔹 Summary

✅ Creates a timestamped backup in .tar.gz format.
✅ Transfers backup securely to another server using SCP.
✅ Deletes old backups (older than 7 days).
✅ Runs automatically every night at 11 PM.
