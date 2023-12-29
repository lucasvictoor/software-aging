#!/bin/bash

source config.sh

container_name="mycontainer"

function pull_command() {
  exit 1
}

function download_command() {
  if [ "$local" == "local" ]; then
    scp root@"$download_link":/root/lxc/"$image_tag".tar.gz image.tar.gz > /dev/null
  else
    wget -O image.tar.gz "$download_link" >/dev/null
  fi
}

function load_command() {
  lxc image import image.tar.gz --alias "$image_tag"
  rm image.tar.gz
}

function start_command() {
  if ! lxc launch "$image_tag" $container_name; then
    exit 1
  fi
  if ! lxc config device add $container_name myport$mapping_port proxy listen=tcp:0.0.0.0:$mapping_port connect=tcp:127.0.0.1:$mapping_port; then
    exit 1
  fi
}

function stop_command() {
  if ! lxc stop $(lxc list -c n --format csv); then
    exit 1
  fi
}

function remove_image_command() {
  if ! lxc image delete $(lxc image list -c f --format csv); then
    exit 1
  fi
}

function remove_container_command() {
  if ! lxc delete --force $(lxc list -c n --format csv); then
    exit 1
  fi
}

function get_up_time() {
    if ! lxc exec $container_name -- cat /root/log.txt; then
      exit 1
    fi
}

function is_image_available() {
  lxc image list | grep "$image_tag" | awk '{print $4}'
}
