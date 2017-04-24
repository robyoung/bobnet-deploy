#!/usr/bin/env bash

docker_socket=/tmp/bobnet-docker-$$.sock
control_socket=/tmp/bobnet-ssh-$$.sock
ssh -nNTf -MS $control_socket -L $docker_socket:/var/run/docker.sock bob02

export DOCKER_HOST=unix://$docker_socket

function close_docker_socket {
  ssh -S $control_socket -O exit bob02
  rm -f $docker_socket
  unset -f close_docker_socket
  unset DOCKER_HOST
}
