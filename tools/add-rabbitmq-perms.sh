#!/bin/bash
# Example of setting permissions on rabbitmq
# WARNING: uses splat permissions

set -ex

if docker info | grep -q 'Swarm: inactive'; then
  $(bobnet-set-docker-socket)
fi

HOST=$(docker stack ps rabbitmq | grep Running | awk '{ print $4 }')
CONTAINER_ID=$(ssh ${HOST} docker ps -q --filter label=com.docker.swarm.service.name=rabbitmq_rabbitmq)

RABBITMQCTL="ssh ${HOST} docker exec ${CONTAINER_ID} rabbitmqctl"
if $RABBITMQCTL list_users | grep -vq devices ; then
  set +x
  echo "Adding devices user"
  $RABBITMQCTL add_user devices "$(pass p/bobnet/secrets/rabbit_password)"
  set -x
fi

# double quote permis to avoid bash expansion
ssh ${HOST} docker exec ${CONTAINER_ID} rabbitmqctl set_permissions -p / devices "'.*'" "'.*'" "'.*'"
