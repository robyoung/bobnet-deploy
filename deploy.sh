#!/usr/bin/env bash

[ $# -eq 1 ] || { >&2 echo "I need to know what to deploy"; exit 1; }

compose_file=$1

[ -f $compose_file ] || { >&2 echo "That file doesn't exit"; exit 1; }

stack_name=$(basename $compose_file | sed s/\.yml$//g)

# Set up docker socket
docker_socket=/tmp/bobnet-docker-$$.sock
control_socket=/tmp/bobnet-ssh-$$.sock
ssh -nNTf -MS $control_socket -L $docker_socket:/var/run/docker.sock bob02
trap "{ ssh -S $control_socket -O exit bob02; rm -f $docker_socket; }" EXIT


DOCKER_HOST=unix://$docker_socket docker stack deploy --compose-file $compose_file $stack_name
