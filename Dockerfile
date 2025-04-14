FROM ubuntu:22.04 

# Update the package list and install necessary packages
# RUN apt-get -y update && \
#     apt-get install -y postgresql-client curl unzip cron
# # Install Rclone
# RUN curl https://rclone.org/install.sh | bash


# Add PostgreSQL APT repository and install PostgreSQL client 16
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-16 curl unzip cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl https://rclone.org/install.sh | bash

# Ensure the config directory exists for rclone
RUN mkdir -p /root/.config/rclone


# Copy Rclone config file (with Google Drive configuration details)
COPY backup-configs/rclone.conf /root/.config/rclone/rclone.conf


# Copy Google Drive service account credentials
COPY backup-configs/gdrive_config.json /root/.config/rclone/gdrive_config.json


# Copy cron jobs and scripts into the container
COPY backup-configs/backups-cron /etc/cron.d/backups-cron

# Set permissions for the cron job files
RUN chmod 644 /etc/cron.d/backups-cron

# Ensure the log file exists
RUN touch /var/log/cron.log

# Copy cron jobs and scripts into the container
COPY backup-configs/backups-cron /etc/cron.d/backups-cron 
COPY backup-configs/backups.sh /backups.sh  
COPY backup-configs/start.sh /start.sh 
COPY backup-configs/cleanup.sh /cleanup.sh 



# Make the scripts executable 
RUN chmod +x /backups.sh && \ 
    chmod +x /cleanup.sh && \
    chmod +x /start.sh


 # Start the backup process and cron service when the container starts
CMD ["/start.sh"]
