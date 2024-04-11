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

  lxc init debian12 --vm --empty
  lxc config device override debian12 root size=5G
  lxc config set debian12 limits.cpu=2 limits.memory=512M
  #lxc config device add debian12 vtpm tpm path=/dev/tpm0
  
  lxc exec debian12 -- apt-get update
  lxc exec debian12 -- apt-get install -y openssh-server
  lxc exec debian12 -- apt-get install -y nginx
  
  lxc config device add install disk source=/path/to/software-aging/debian12.lxd.iso boot.priority=10
}

START_VM() {
  lxc-start -n "$VM_NAME"
}

STOP_VM() {
  lxc-stop -n "$VM_NAME"
}

DELETE_VM() {
  lxc-destroy -n "$VM_NAME"
}

RESTART_VM() {
  STOP_VM
  START_VM
}

SETUP_LXC_VM() {
  CREATE_VM
  START_VM
}

SETUP_LXC_VM
