FROM postgres:9.4
MAINTAINER nayan@oizom.com
 
RUN apt-get -y update; apt-get install -y postgresql-client wget
# Install Gdrive on Server
RUN wget https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
RUN mv gdrive-linux-x64 gdrive
RUN cp gdrive /usr/bin
RUN chmod +x /usr/bin/gdrive
ADD gdrive_config.json /gdrive_config.json

ADD backups-cron /etc/cron.d/backups-cron
RUN touch /var/log/cron.log
ADD backups.sh /backups.sh
ADD restore.sh /restore.sh
ADD gdrive.sh /gdrive.sh
ADD start.sh /start.sh

ENTRYPOINT []
CMD ["/start.sh"]
