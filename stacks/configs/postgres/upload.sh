#!/bin/sh

set -e

function log {
  echo "$(date -uIseconds) $@"
}

pip install awscli

export AWS_ACCESS_KEY_ID=$(cat $AWS_ACCESS_KEY_ID_FILE)
export AWS_SECRET_ACCESS_KEY=$(cat $AWS_SECRET_ACCESS_KEY_FILE)

while true; do
  for archive in $(find $BACKUP_BASE/ready -name '*.tar.bz2'); do
    log "Uploading $archive"
    aws s3 mv $archive s3://$BACKUP_BUCKET
  done
  sleep 30
done
