#!/bin/bash

source config.sh

function pull_command() {
  docker pull "$image:$image_tag"
}

function download_command() {
  if [ "$local" == "local" ]; then
    scp root@"$download_link":/root/docker/"$image_tag".tar image.tar
  else
    wget -O image.tar "$download_link"
  fi
}

function load_command() {
  docker load -i image.tar
  rm image.tar
}

function start_command() {
  if ! docker run -td "$image:$image_tag"; then
    exit 1
  fi
}

function stop_command() {
  if ! docker container stop $(docker container ls -aq); then
    exit 1
  fi
}

function remove_image_command() {
  if ! docker rmi "$image:$image_tag"; then
    exit 1
  fi
}

function remove_container_command() {
  if ! docker rm $(docker container ls -aq); then
    exit 1
  fi
}

function is_image_available() {
  docker image ls -a | grep "$image_tag" | awk '{print $3}'
}
