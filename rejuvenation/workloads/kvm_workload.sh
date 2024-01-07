#!/usr/bin/env bash
# usage:
#   $ bash workload_kvm.sh

######################################## KVM - WORKLOAD #######################################
# ABOUT:                                                                                      #
#   used to simulate workload on ( kvm ) virtualization infrastructure                        #
#                                                                                             #
# WORKLOAD TYPE:                                                                              #
#   DISKS                                                                                     #
###############################################################################################

# ####################### IMPORTS #######################
source ./virtualizer_functions/kvm_functions.sh
# #######################################################

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

# FUNCTION=KVM_WORKLOAD()
# PARAMETERS:
#   $1= disks path
#   $2= quantity of disks
# USAGE:
#   ./workload.sh /disks/disk 50
KVM_WORKLOAD() {
  local attach_count_disks=1
  local detach_count_disks=1
  local disk_path="setup/kvm/disks/disk"
  local max_disks=50

  while true; do

    # attach loop
    for _ in {1..3}; do
      ATTACH_DISK "${disk_path}${attach_count_disks}.qcow2"

      if [[ "$attach_count_disks" -eq "$max_disks" ]]; then
        attach_count_disks=1
      else
        ((attach_count_disks++))
      fi
      sleep $wait_time_after_attach
    done

    # detach loop
    for _ in {1..3}; do
      DETACH_DISK "${disk_path}${detach_count_disks}.qcow2"

      if [[ "$detach_count_disks" -eq "$max_disks" ]]; then
        detach_count_disks=1
      else
        ((detach_count_disks++))
      fi
      sleep $wait_time_after_detach

    done
  done
}

KVM_WORKLOAD
