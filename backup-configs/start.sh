#!/bin/bash

# Check if each var is declared and if not,
# set a sensible default

if [ -z "${POSTGRES_USER}" ]; then
  POSTGRES_USER=docker
fi

if [ -z "${POSTGRES_PASS}" ]; then
  POSTGRES_PASS=docker
fi

if [ -z "${POSTGRES_PORT}" ]; then
  POSTGRES_PORT=5432
fi

if [ -z "${POSTGRES_HOST}" ]; then
  POSTGRES_HOST=db
fi

if [ -z "${POSTGRES_DBNAME}" ]; then
  POSTGRES_DBNAME="postgres"
fi
 

if [ -z "${GD_CLEAN_DAYS_OLD}" ]; then
  GD_CLEAN_DAYS_OLD=30
fi
 

if [ -z "${BUCKET}" ]; then
	BUCKET=backups
fi

# Write environment variables to pgenv.sh
echo "
export PGUSER=$POSTGRES_USER
export PGPASSWORD=\"$POSTGRES_PASS\"
export PGPORT=$POSTGRES_PORT
export PGHOST=$POSTGRES_HOST
export PGDATABASE=$POSTGRES_DBNAME 
export ARCHIVE_FILENAME=${ARCHIVE_FILENAME}
export GD_DIR=$GD_FOLDER
export GD_DAYS_OLD=$GD_CLEAN_DAYS_OLD
export BUCKET=\"${BUCKET}\"

" > /pgenv.sh

echo "Start script running with these environment options"
set | grep PG

# Launch cron in the foreground
cron -f 
 