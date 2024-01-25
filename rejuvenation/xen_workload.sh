#!/bin/bash

source ./virtualizer_functions/xen_functions.sh

# PARAMETERS
# $1 = volume group
# $2 = quantity of disks
# USAGE
# ./workload.sh vg0 50

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

WORKLOAD() {
  local volume_group="$1"
  local count_disks=1
  local max_disks="$2"
  local disk_path="/dev/${volume_group}/disk"

  while true; do
    for port in {1..3}; do
      ATTACH_DISK "${disk_path}${count_disks}" "$port"

      if [[ "$count_disks" -eq "$max_disks" ]]; then
        count_disks=1
      else
        ((count_disks++))
      fi
      sleep "$wait_time_after_attach"
    done

    for port in {1..3}; do
      DETACH_DISK "$port"
      sleep "$wait_time_after_detach"
    done
  done
}