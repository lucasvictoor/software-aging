#!/bin/bash

######################################## KVM - WORKLOAD #######################################
# ABOUT:                                                                                      #
#   used to simulate workload on (xen) virtualization infrastructure                        #
#                                                                                             #
# WORKLOAD TYPE:                                                                              #
#   DISKS                                                                                     #
###############################################################################################

# ####################### IMPORTS #######################
source ../virtualizer_functions/xen_functions.sh
# #######################################################

# PARAMETERS
# $1 = volume group
# $2 = quantity of disks
# USAGE
# ./workload.sh vg0 50

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

XEN_WORKLOAD() {
  local volume_group="$1"
  local count_disks=1
  local max_disks="$2"
  local disk_path="/dev/${volume_group}/disk"

  while true; do
    for number in {1..3}; do
      local frontend_name="xvdb${number}"
      ATTACH_DISK "${disk_path}${count_disks}" "$frontend_name"
      sleep "$wait_time_after_attach"
      
      if [[ "$count_disks" -eq "$max_disks" ]]; then
        count_disks=1
      else
        ((count_disks++))
      fi
    done

    for number in {1..3}; do
      local frontend_name="xvdb${number}"
      DETACH_DISK "$frontend_name"
      sleep "$wait_time_after_detach"
    done
  done
}

XEN_WORKLOAD