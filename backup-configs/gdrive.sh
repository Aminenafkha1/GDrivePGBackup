#!/bin/bash
echo "2options"
 
# Load environment variables from the pgenv.sh file
source /pgenv.sh

base_path="/backups"

# Sync the local backup folder to Google Drive using Rclone
rclone sync $base_path gdrive:$GD_DIR --config /root/.config/rclone/rclone.conf >> /var/log/cron.log 2>&1

# Check if the Rclone sync command succeeded
if [ $? -eq 0 ]; then
  echo "Backup successfully synced to Google Drive" >> /var/log/cron.log
else
  echo "Error occurred during Rclone sync" >> /var/log/cron.log
fi
