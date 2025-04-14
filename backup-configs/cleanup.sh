#!/bin/bash

# Define directories and settings
LOCAL_DIR="/${BUCKET}"
GDRIVE_REMOTE="gdrive:$GD_DIR" # This should be configured in rclone config
DAYS_OLD=$GD_DAYS_OLD

# Function to delete local files older than a specified number of days
cleanup_local() {
    echo "Deleting local files older than $DAYS_OLD days in $LOCAL_DIR" >> /var/log/cron.log
    local files_deleted=0
    local files_found=$(find "$LOCAL_DIR" -type f -mtime +$DAYS_OLD)
 
    if [ -z "$files_found" ]; then
        echo "No local files older than $DAYS_OLD days found in $LOCAL_DIR." >> /var/log/cron.log
    else
        echo "$files_found" | while read -r file; do
            if [ -f "$file" ]; then
                rm -f "$file"
                echo "Deleted local file: $file" >> /var/log/cron.log
                files_deleted=$((files_deleted + 1))
            fi
        done

        if [ "$files_deleted" -eq 0 ]; then
            echo "No local files were deleted." >> /var/log/cron.log
        fi
    fi
}

# Function to delete files in Google Drive older than a specified number of days
cleanup_gdrive() {
    echo "Deleting Google Drive files older than $DAYS_OLD days in $GDRIVE_REMOTE" >> /var/log/cron.log

    local files_deleted=0
    local files_list=$(rclone lsl "$GDRIVE_REMOTE" --config /root/.config/rclone/rclone.conf | awk -v days="$DAYS_OLD" '{ if ($1 < strftime("%s", systime() - days * 86400)) print $NF }')
 
    if [ -z "$files_list" ]; then
        echo "No Google Drive files older than $DAYS_OLD days found in $GDRIVE_REMOTE." >> /var/log/cron.log
    else
        echo "$files_list" | while read -r file; do
            if [ -n "$file" ]; then
                rclone delete "$GDRIVE_REMOTE/$file" --config /root/.config/rclone/rclone.conf
                echo "Deleted Google Drive file: $file" >> /var/log/cron.log
                files_deleted=$((files_deleted + 1))
            fi
        done

        if [ "$files_deleted" -eq 0 ]; then
            echo "No Google Drive files were deleted." >> /var/log/cron.log
        fi
    fi
}
 
# Execute cleanup and sync functions
cleanup_local
cleanup_gdrive 
