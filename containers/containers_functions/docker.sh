#!/bin/bash

source config.sh

function download_command() {
  scp root@"$server_link":/root/$service/$image_name.tar image.tar
}

function load_command() {
  docker load -i image.tar
  rm -f image.tar
}

function start_command() {
  if ! docker run --name "$image_name" -td -p "$mapping_port:$mapping_port" --init "$image_name"; then
    exit 1
  fi
}

function stop_command() {
  if ! docker container stop "$image_name"; then
    exit 1
  fi
}

function remove_image_command() {
  if ! docker rmi "$image_name"; then
    exit 1
  fi
}

function remove_container_command() {
  if ! docker rm "$image_name"; then
    exit 1
  fi
}

function get_up_time() {
    if ! docker exec -it "$image_name" cat /root/log.txt; then
      exit 1
    fi
}

function is_image_available() {
  docker image ls -a | grep "$image_name" | awk '{print $3}'
}
