#!/bin/bash

source config.sh

function download_command() {
  scp root@$server_link:"/root/$service/$image_name.tar.gz" image.tar.gz > /dev/null
}

function load_command() {
  lxc image import image.tar.gz --alias "$image_name"
  rm -f image.tar.gz
}

function start_command() {
  if ! lxc launch "$image_name" "$image_name"; then
    exit 1
  fi
  if ! lxc config device add "$image_name" myport$mapping_port proxy listen=tcp:0.0.0.0:$mapping_port connect=tcp:127.0.0.1:$mapping_port; then
    exit 1
  fi
}

function stop_command() {
  if ! lxc stop "$image_name"; then
    exit 1
  fi
}

function remove_image_command() {
  if ! lxc image delete "$image_name"; then
    exit 1
  fi
}

function remove_container_command() {
  if ! lxc delete --force "$image_name"; then
    exit 1
  fi
}

function get_up_time() {
    if ! lxc exec "$image_name" -- cat /root/log.txt; then
      exit 1
    fi
}

function is_image_available() {
  lxc image list | grep "$image_name" | awk '{print $4}'
}
