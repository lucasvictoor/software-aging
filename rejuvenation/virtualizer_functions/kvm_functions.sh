#!/usr/bin/env bash
# usage:
#   $ bash kvm_functions.sh

######################################## KVM FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
#   utilities for managing kvm virtual machines                                               #
###############################################################################################

readonly VM_NAME="debian12"

TURN_VM_OFF() {
  virsh shutdown "$VM_NAME"
}

DELETE_VM() {
  virsh undefine "$VM_NAME"
}

GRACEFUL_REBOOT() {
  virsh shutdown "$VM_NAME"
  
  until virsh start "$VM_NAME"; do
    sleep 1
    echo "Waiting for machine to shutdown"
  done
}

FORCED_REBOOT() {
  virsh reset "$VM_NAME"
}

SSH_REBOOT() {
  ssh -p 2222 root@localhost "virsh reboot $VM_NAME"
}

# FUNCTION=CREATE_DISKS()
# USAGE:
#   CREATE_DISKS 3 1G
CREATE_DISKS() {
  local count=1
  local disks_quantity=$1         # amount of disks to be created
  local allocated_disk_size=$2    # size for disk

  mkdir -p ./disks_kvm

  while [[ "$count" -le "$disks_quantity" ]]; do
    qemu-img create -f qcow2 -o preallocation=full ./disks_kvm/disk"$count".qcow2 "$allocated_disk_size"
    ((count++))
  done
}

# FUNCTION=START_VM()
# RUN FOR HELPER:
#   virsh start --help
START_VM() {
  virsh start "$VM_NAME"
}

# FUNCTION=ATTACH_DISK()
# RUN FOR HELPER:
#   virsh attach-disk --help
ATTACH_DISK() {
  local disk_path="$1"

  virsh attach-disk "$VM_NAME" "$disk_path" sdb --type hdd --live --config

}

# FUNCTION=DETACH_DISK()
# RUN FOR HELPER:
#   virsh detach-disk --help
DETACH_DISK() {
  local disk_path="$1"

  virsh detach-disk "$VM_NAME" "$disk_path"
}

# FUNCTION=TURN_ON_GRAPHICAL_INTERFACE()
# RUN FOR HELPER:
#   virt-viewer --help
TURN_ON_GRAPHICAL_INTERFACE() {
  virt-viewer --connect qemu:///session --wait "$VM_NAME"
}