#!/bin/bash

source config.sh

function pull_command() {
  podman pull "$image:$image_tag"
}

function download_command() {
  if [ "$local" == "local" ]; then
    scp root@"$download_link":/root/docker/"$image_tag".tar image.tar
  else
    wget -O image.tar "$download_link"
  fi
}

function load_command() {
  podman load -i image.tar
  rm image.tar
}

function start_command() {
  if ! podman run -td "$image:$image_tag"; then
    exit 1
  fi
}

function stop_command() {
  if ! podman container stop $(podman container ls -aq); then
    exit 1
  fi
}

function remove_image_command() {
  if ! podman rmi "$image:$image_tag"; then
    exit 1
  fi
}

function remove_container_command() {
  if ! podman rm $(podman container ls -aq); then
    exit 1
  fi
}

function is_image_available() {
  podman image ls -a | grep "$image_tag" | awk '{print $3}'
}
