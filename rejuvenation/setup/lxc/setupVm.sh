#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../virtualizer_functions/lxc_functions.sh
# ####################################################################

readonly VM_NAME="vmDebian"

# FUNCTION=CREATE_VM()
# DESCRIPTION:
# 
# Init - initialize a new VM debian12
# Override - sets the disk size
# Limits.cpu and limits.memory - configure cpu and memory limit
# Disk source - adds and installation disk to the VM
# Install openssh-server - installation ssh
# Installl nginx - installation web server
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