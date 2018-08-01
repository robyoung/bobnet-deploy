#!/bin/sh

set -e

mkdir $BACKUP_BASE/new $BACKUP_BASE/ready

while true; do
  # Prepare the backup directory
  STAMP="$(date -uIseconds | cut -d + -f 1)"
  NEW_BACKUP_PATH="$BACKUP_BASE/new/$STAMP"
  READY_BACKUP_PATH="$BACKUP_BASE/ready"
  mkdir $NEW_BACKUP_PATH

  # Prepare the postgres password file
  export PGPASSFILE=/tmp/pgpassfile
  echo "*:*:*:${POSTGRES_USER}:$(cat ${POSTGRES_PASSWORD_FILE})" >> $PGPASSFILE
  chmod 600 $PGPASSFILE
  chown $UID:$UID $PGPASSFILE

  # Do the backup
  pg_basebackup \
    --pgdata=$NEW_BACKUP_PATH \
    -h $POSTGRES_HOST \
    -p 5432 \
    -U $POSTGRES_USER

  # Make the backup directory readable
  chown -R $UID:$UID $NEW_BACKUP_PATH
  chmod -R o+rx $NEW_BACKUP_PATH

  # Archive the backup ready for upload
  tar \
    -jcvf "$(dirname $NEW_BACKUP_PATH)/$STAMP.tar.bz2" \
    -C $(dirname $NEW_BACKUP_PATH) \
    $(basename $NEW_BACKUP_PATH)

  mv "$(dirname $NEW_BACKUP_PATH)/$STAMP.tar.bz2" $READY_BACKUP_PATH

  rm -rf $NEW_BACKUP_PATH

  echo "pg_basebackup done"
  # sleep for a day
  sleep 86400
done
