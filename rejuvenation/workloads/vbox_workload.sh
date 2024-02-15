#!/usr/bin/env bash
# usage:
#   $ bash workload.sh

######################################## VBOX - WORKLOAD ######################################
# ABOUT:                                                                                      #
#   used to simulate workload on (virtualbox) virtualization infrastructure                 #
#                                                                                             #
# WORKLOAD TYPE:                                                                              #
#   DISKS                                                                                     #
###############################################################################################

# ####################### IMPORTS #######################
source ./virtualizer_functions/vbox_functions.sh
# #######################################################

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

# FUNCTION=VBOX_WORKLOAD()
VBOX_WORKLOAD() {
  local count_disks=1                   # start disk count from 1 to n
  local disk_path="setup/virtualbox/disks/disk"    # path where the disks are to start the workload
  local max_disks=50

  while true; do
    # looping to attach
    for port in {1..3}; do
      ATTACH_DISK "${disk_path}${count_disks}.vhd" "$port"

      if [[ "$count_disks" -eq "$max_disks" ]]; then
        count_disks=1
      else
        ((count_disks++))
      fi
      sleep $wait_time_after_attach
    done

    # looping to detach
    for port in {1..3}; do
      DETACH_DISK "$port"
      sleep $wait_time_after_detach

    done
  done
}

VBOX_WORKLOAD
