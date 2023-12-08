#!/usr/bin/env bash

############################ IMPORTS
source ../vbox_functions.sh

# UTILS
#   ERROR HANDLE
ERROR_HANDLING() {
    local error=$1
    local status=$2

    [[ $status -eq 0 ]] || {
        echo -e "\nERROR: $error\n"
        exit 1
    }
}

# ERRORS MESSAGES
readonly poweroff="error when turning off the virtual machine, it may already be turned off!"
readonly unregister="unregistering and deleting files from vmDebian"
readonly import_modify="Importing vmDebian.ova and modifying vmDebian ports and network"

# CHECK_DEBIAN_IMAGE
# DESCRIPTION:
#   checks if the virtual machine file vmDebian.ova is in a folder before the rejuvenation folder
CHECK_DEBIAN_IMAGE() {
  read -r -p "Have you copied the VM vmDebian.ova file? It should have been put one level before the rejuvenation folder (y/n): " copy

  if [ "$copy" != "y" ]; then
    echo -e "right, copy the debian system image to the location provided!\n"
    exit 1
  fi
}

# CONTROL_VIRTUAL_MACHINE
# DESCRIPTION:
#   TURN_VM_OFF:
#     try to turn off the virtual machine
#   
#   DELETE_VM:
#     Attempts to unregister the virtual machine and delete all files associated with it
#
#   CREATE_VM:
#     import the virtual machine vmDebian.ova
#     Attempts to modify the virtual machine to forward traffic from host port 8080 to virtual machine port 80
CONTROL_VIRTUAL_MACHINE() {
  cd ..
  TURN_VM_OFF
  ERROR_HANDLING "$poweroff" 0

  DELETE_VM
  ERROR_HANDLING "$unregister" 0

  CREATE_VM
  ERROR_HANDLING "$import_modify" 0
  cd setup || exit
}

# DISKS_MANAGMENT
# DESCRIPTION:
#     removes all disks from the virtual machine
#     creates disks in the virtual machine from the given quantity and size
# 
# PARAMETERS:
#     $1 == create disks
#     $2 == remove disks
#
# DISC RECOMMENDATIONS:
#     disks_quantity=50
#     disks_size=1024
DISKS_MANAGMENT() {
  local create_disks=$1
  local remove_disks=$2

  $remove_disks

  # define a desired quantity and size of disks to perform the tests
  local disks_quantity=50
  local disks_size=10

  if ! $create_disks $disks_quantity $disks_size; then
    echo -e "ERROR: error creating disk\n"
  else
    echo -e "SUCCESS: success in creating disks of quantity $disks_quantity and size $disks_size\n"
  fi
}

# START_VIRTUAL_MACHINE_IN_BACKGROUND
# DESCRIPTION:
#     START_VM:
#         start vm in headless
START_VIRTUAL_MACHINE_IN_BACKGROUND() {
  read -r -p "Do you want to connect the vm? ( y | n ) - Default=n: \n" choice

  if [[ "$choice" == "y" ]]; then
    START_VM
  fi
}

# COPY_SSH_ID_AND_TEST_VIRTUAL_MACHINE_SERVER
# DESCRIPTION:
#   ssh-copy-id:
#       have an ssh key already created, then it will be copied with ssh-copy 
#       and a port will be added and in the end your current shell will be connected to the virtual machine
#
#   curl:
#       check whether the request to the server was successful
COPY_SSH_ID_AND_TEST_VIRTUAL_MACHINE_SERVER() {
  if ! ssh-copy-id -i /root/.ssh/id_rsa.pub -p 2222 root@localhost; then
    echo -e "ERROR: error when trying to connect to vmDebian via ssh\n"
  fi

  if ! curl http://localhost:8080; then
    echo -e "ERROR: error when trying to start vmDebian's nginx server\n"
  fi
}
