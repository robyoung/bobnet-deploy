#!/bin/bash

echo "Init databases"
set -e

for db in $(echo $POSTGRES_DATABASES); do
  echo "Creating database ${db}"
  query_for_database="SELECT 1 FROM pg_database WHERE datname = '${db}'"
  psql \
    --username "$POSTGRES_USER" \
    -tc "$query_for_database" \
    | grep -q 1 \
    || psql --username "$POSTGRES_USER" -c "CREATE DATABASE ${db}";

  echo "Creating user for database ${db}"
  query_for_user="SELECT 1 FROM pg_roles WHERE rolname='${db}'"
  user_password_env="POSTGRES_$(echo $db | tr '[:lower:]' '[:upper:]')_PASSWORD_FILE"
  user_password="$(cat ${!user_password_env})"
  create_user="CREATE ROLE ${db} WITH LOGIN PASSWORD '${user_password}'"
  grant_access="GRANT ALL ON DATABASE ${db} TO ${db}"
  psql \
    --username "$POSTGRES_USER" \
    -tc "$query_for_user" \
    | grep -q 1 \
    || {
      psql --username "$POSTGRES_USER" -c "$create_user";
      psql --username "$POSTGRES_USER" -c "$grant_access";
    }
done 

# allow replication
echo "host replication all all md5" >> $PGDATA/pg_hba.conf
