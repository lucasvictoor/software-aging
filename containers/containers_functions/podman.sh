#!/bin/bash

source config.sh

function download_command() {
  scp root@"$server_link":/root/$service/$image_name.tar image.tar
}

function load_command() {
  podman load -i image.tar
  rm -f image.tar
}

function start_command() {
  if ! podman run --name "$image_name" -td -p "$mapping_port:$mapping_port" --init "$image_name"; then
    exit 1
  fi
}

function stop_command() {
  if ! podman container stop "$image_name"; then
    exit 1
  fi
}

function remove_image_command() {
  if ! podman rmi "$image_name"; then
    exit 1
  fi
}

function remove_container_command() {
  if ! podman rm "$image_name"; then
    exit 1
  fi
}

function get_up_time() {
    if ! podman exec -it "$image_name" cat /root/log.txt; then
      exit 1
    fi
}

function is_image_available() {
  podman image ls -a | grep "$image_name" | awk '{print $3}'
}
