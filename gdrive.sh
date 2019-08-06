#!/bin/bash

source /pgenv.sh

base_path="/backups"

# https://github.com/prasmussen/gdrive
gdrive --config / --service-account gdrive_config.json sync upload $base_path $GD_DIR >> /var/log/cron.log
