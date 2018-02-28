#!/bin/bash

set -e

for db in bobnet_control; do
  psql --username "$POSTGRES_USER" -tc "SELECT 1 FROM pg_database WHERE datname = '${db}'" \
    | grep -q 1 \
    || psql --username "$POSTGRES_USER" -c "CREATE DATABASE ${db}"
done 
