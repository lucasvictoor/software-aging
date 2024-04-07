#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../virtualizer_functions/lxc_functions.sh
# ####################################################################

readonly VM_NAME="vmDebian"

CREATE_VM() {
  local rootfs="/var/lib/lxc/$VM_NAME/rootfs"

  case $DISTRO_ID in
  "debian" | "ubuntu")
    lxc-create -n "$VM_NAME" -t download -- -d $DISTRO_ID -r focal -a amd64
    ;;
  *)
    echo "Distribuição não suportada para criação de VM LXC."
    exit 1
    ;;
  esac
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