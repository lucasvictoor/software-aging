#!/user/bin/env bash

source ../../virtualizer_functions/kvm_functions.sh

DISKS_MANAGEMENT() {
  CREATE_DISKS 50 10
}

CREATE_VIRTUAL_MACHINE() {
  CONFIGURE_NEW_VM
  sleep 3
  VM_POWER_ON
}

SETUP_VM() {
  DISKS_MANAGEMENT
  CREATE_VIRTUAL_MACHINE
}