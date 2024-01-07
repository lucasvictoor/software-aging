#!/usr/bin/env bash

# ############## IMPORTS ###############
source ../../vbox_functions.sh
# ######################################

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

# ERROR MESSAGES
readonly poweroff="error when turning off the virtual machine, it may already be turned off!"
readonly unregister="unregistering and deleting files from vmDebian"
readonly import_modify="Importing vmDebian.ova and modifying vmDebian ports and network"

# CHECK_DEBIAN_IMAGE
# DESCRIPTION:
#   Checks if the virtual machine file vmDebian.ova is in a folder before the rejuvenation folder
CHECK_DEBIAN_IMAGE() {
  read -r -p "Have you copied the VM vmDebian.ova file? It should have been put inside the setup folder (y/n): " copy

  if [ "$copy" != "y" ]; then
    echo -e "right, copy the debian system image to the location provided!\n"
    exit 1
  fi
}

# CREATE_VIRTUAL_MACHINE
# DESCRIPTION:
#   TURN_VM_OFF:
#     Tries to turn off the virtual machine
#   
#   DELETE_VM:
#     Attempts to unregister the virtual machine and delete all files associated with it
#
#   CREATE_VM:
#     Imports the virtual machine vmDebian.ova
#     Attempts to modify the virtual machine to forward traffic from host port 8080 to virtual machine port 80
CREATE_VIRTUAL_MACHINE() {
  CHECK_DEBIAN_IMAGE

  TURN_VM_OFF
  ERROR_HANDLING "$poweroff" 0

  DELETE_VM
  ERROR_HANDLING "$unregister" 0

  CREATE_VM
  ERROR_HANDLING "$import_modify" 0
  cd .. || exit
}

# DISKS_MANAGEMENT
# DESCRIPTION:
#     Removes all disks from the virtual machine
#     Creates disks in the virtual machine from the given quantity and size
# 
# PARAMETERS:
#     $1 == create disks
#     $2 == remove disks
#
# DISC RECOMMENDATIONS:
#     disks_quantity=50
#     disks_size=1024
DISKS_MANAGEMENT() {
  REMOVE_DISKS
  ERROR_HANDLING "ERROR REMOVING DISKS" 0

  CREATE_DISKS 50 1024
  ERROR_HANDLING "ERROR CREATING DISKS" 0
}

# START_VIRTUAL_MACHINE_IN_BACKGROUND
# DESCRIPTION:
#     START_VM:
#         Starts vm in headless mode
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
#       Checks whether the request to the server was successful
TEST_VIRTUAL_MACHINE_SERVER() {
  sleep 10
  if ! curl http://localhost:8080; then
    echo -e "ERROR: error when trying to start vmDebian's nginx server\n"
  fi
}

SETUP_VM() {
  DISKS_MANAGEMENT
  CREATE_VIRTUAL_MACHINE
  START_VM
  TEST_VIRTUAL_MACHINE_SERVER
}

SETUP_VM
