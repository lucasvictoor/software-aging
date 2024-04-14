#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../virtualizer_functions/lxc_functions.sh
# ####################################################################

readonly VM_NAME="vmDebian"

CREATE_VM() {
  local rootfs="/var/lib/lxc/$VM_NAME/rootfs"

  lxc launch images:debian/12 $VM_NAME --vm -s default
  lxc config set $VM_NAME limits.cpu=2 limits.memory=512MB

  sleep 10
  lxc exec $VM_NAME -- bash -c "apt-get update && apt-get install -y openssh-server nginx"
}

START_VM() {
  lxc start "$VM_NAME"
}

STOP_VM() {
  lxc stop "$VM_NAME"
}

DELETE_VM() {
  lxc delete "$VM_NAME" --force
}

RESTART_VM() {
  STOP_VM
  sleep 5
  START_VM
}

SETUP_LXC_VM() {
  CREATE_VM
  START_VM
}

SETUP_LXC_VM