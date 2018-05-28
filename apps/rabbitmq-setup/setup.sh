#!/bin/sh

set -x

RABBITMQ_PASSWORD="$(cat /run/secrets/rabbit_password)"
DEVICES_PASSWORD="$(cat /run/secrets/devices_password)"

AUTH="rabbit:${RABBITMQ_PASSWORD}"
URL="http://rabbitmq:15672"

# wait for rabbitmq to come up
echo "Gonna wait for RabbitMQ"
while ! curl --silent --fail --output /dev/null -u ${AUTH} ${URL}/api/users; do
  echo "Checking for RabbitMQ"
  sleep 1;
done
echo "RabbitMQ UP"

# create the devices user if it doesn't exist
echo "Gonna add devices user"
if ! curl -u ${AUTH} ${URL}/api/users | jq '.[].name' | grep -q devices; then
  echo "Adding devices user"
  curl -u ${AUTH} -X PUT -H 'Content-type: application/json' -d @- ${URL}/api/users/devices <<EOF
{"password": "${DEVICES_PASSWORD}", "tags": ""}
EOF
fi
echo "DONE"

# add permissions for devices user if it doesn't have any
echo "Gonna add permissions"
if ! curl --silent --fail --output /dev/null -u ${AUTH} ${URL}/api/permissions/%2F/devices; then
  echo "Adding permissions for devices user"
  curl -u ${AUTH} -X PUT -H 'Content-type: application/json' -d @- ${URL}/api/permissions/%2F/devices <<EOF
{"confgure": ".*", "write": ".*", "read": ".*"}
EOF
fi

echo "ALL DONE"
