#!/bin/bash
source ./vbox_functions.sh

# PARAMETERS
# $1= disks path
# $2= quantity of disks
# USAGE
# ./workload.sh /disks/disk 50

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

WORKLOAD() {
  local count_disks=1
  local disk_path="disks/disk"
  local max_disks=50

  while true; do
    for port in {1..3}; do
      ATTACH_DISK "${disk_path}${count_disks}.vhd" "$port"

      if [[ "$count_disks" -eq "$max_disks" ]]; then
        count_disks=1
      else
        ((count_disks++))
      fi
      sleep $wait_time_after_attach
    done

    for port in {1..3}; do
      DETACH_DISK "$port"
      sleep $wait_time_after_detach

    done
  done
}

WORKLOAD
