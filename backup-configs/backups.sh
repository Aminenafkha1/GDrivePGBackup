#!/bin/bash
source /pgenv.sh 

MYDATE=$(date +%d-%B-%Y)
MONTH=$(date +%B)
YEAR=$(date +%Y) 
MYBASEDIR=/${BUCKET}
MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH} 
echo "Backing up specified database: ${PGDATABASE}"


ALL_DBS=$(PGPASSWORD="${PGPASSWORD}" psql -U "${PGUSER}" -h "${PGHOST}" -p "${PGPORT}" -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" 2>>/var/log/cron.log)
echo "[$(date)] All user databases: $ALL_DBS" >> /var/log/cron.log
 
# Check if PGDATABASE is set
if [ -n "${PGDATABASE}" ]; then
  # Check if the specified database exists in ALL_DBS
  DBEXISTS=$(echo "$ALL_DBS" | grep -w "${PGDATABASE}")

  if [ -n "${DBEXISTS}" ]; then
    DBLIST="${PGDATABASE}"
    echo "Backing up specified database: ${DBLIST}" >> /var/log/cron.log
  else
    echo "Database '${PGDATABASE}' does not exist. Backing up all databases." >> /var/log/cron.log
    DBLIST="$ALL_DBS"
  fi
else
  # If PGDATABASE is not set, back up all databases
  echo "Backing up all databases." >> /var/log/cron.log
  DBLIST="$ALL_DBS"
fi


# Loop through each pg database backing up schema and data
echo "Databases to backup (schema and data): ${ALL_DBS}" >> /var/log/cron.log

for DB in ${DBLIST}; do
  echo "Backing up schema and data for $DB" >> /var/log/cron.log 

  CONNECTION_STRING="postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${DB}"

  # Backup both schema and data to tar format 
  pg_dump "$CONNECTION_STRING" -F t -b -v | rclone rcat "gdrive:${DB}.${MYDATE}.tar" --config /root/.config/rclone/rclone.conf 

done

echo "Backup completed." >> /var/log/cron.log
