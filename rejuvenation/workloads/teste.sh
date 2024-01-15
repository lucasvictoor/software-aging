#!/usr/bin/env bash

# readonly wait_time_after_attach=10
# readonly wait_time_after_detach=10

# KVM_WORKLOAD() {
#     local attach_count_disks=1
#     local detach_count_disks=1
#     # local disk_path="/home/thayson-pc/Área de trabalho/software-aging/rejuvenation/setup/kvm/disks_kvm/disk"
#     local disk
#     disk=$(find / -name disk1.qcow2)

#     local disk_path
#     disk_path=$(dirname "$disk")/disk

#     local max_disks=50
#     local identificador=("b" "c" "d")

#     while true; do
#         # detach loop
#         for i in {1..3}; do
#             virsh detach-disk debian12 "vd${identificador[$i - 1]}" --persistent --config # "$disk_path""$detach_count_disks".qcow2

#             if [[ "$detach_count_disks" -eq "$max_disks" ]]; then
#                 detach_count_disks=1
#             else
#                 ((detach_count_disks++))
#             fi
#             sleep $wait_time_after_detach

#         done

#         # attach loop
#         for i in {1..3}; do
#             virsh attach-disk debian12 --source "$disk_path""$attach_count_disks".qcow2 --target "vd${identificador[$i - 1]}" --persistent --config

#             if [[ "$attach_count_disks" -eq "$max_disks" ]]; then
#                 attach_count_disks=1
#             else
#                 ((attach_count_disks++))
#             fi
#             sleep $wait_time_after_attach
#         done

#     done
# }

# KVM_WORKLOAD









































# ####################### IMPORTS #######################
source ./virtualizer_functions/kvm_functions.sh
# #######################################################

readonly wait_time_after_attach=10
readonly wait_time_after_detach=10

KVM_WORKLOAD() {
    local attach_count_disks=1
    local detach_count_disks=1
    # local disk_path="/home/thayson-pc/Área de trabalho/software-aging/rejuvenation/setup/kvm/disks_kvm/disk"
    local disk
    disk=$(find / -name disk1.qcow2)

    local disk_path
    disk_path=$(dirname "$disk")/disk

    local max_disks=50
    local identificador=("b" "c" "d")

    while true; do
        # detach loop
        for i in {1..3}; do
            DETACH_DISK "vd${identificador[$i - 1]}"
            # virsh detach-disk debian12 "vd${identificador[$i - 1]}" --persistent --config # "$disk_path""$detach_count_disks".qcow2

            if [[ "$detach_count_disks" -eq "$max_disks" ]]; then
                detach_count_disks=1
            else
                ((detach_count_disks++))
            fi
            sleep $wait_time_after_detach

        done

        # attach loop
        for i in {1..3}; do
            ATTACH_DISK "${disk_path}${attach_count_disks}.qcow2" "vd${identificador[$i - 1]}"

            if [[ "$attach_count_disks" -eq "$max_disks" ]]; then
                attach_count_disks=1
            else
                ((attach_count_disks++))
            fi
            sleep $wait_time_after_attach
        done

    done
}

KVM_WORKLOAD
