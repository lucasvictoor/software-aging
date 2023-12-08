#!/usr/bin/env bash

source ./vbox_functions.sh

LOG_ERRORS() {
        local commands=$1
        # local function_name=$2

        local current_time
        current_time=$(date +"%Y-%m-%d %H:%M:%S")

        "$commands" &>/dev/null

        if [[ $? -eq 1 ]]; then
                mkdir -p logs_vbox

                {
                        echo -e "============================="
                        echo "Error detected in( $current_time )"
                        # echo "Function: $function_name"
                        echo "Command: $commands" 
                        echo "Description "
                        echo "******"
                        $commands 2>> "logs_vbox/log_file.txt"
                        echo "******"
                        echo -e "=============================\n" 

                } >> "logs_vbox/log_file.txt"
        fi

}

LOG_ERRORS TURN_VM_OFF

LOG_ERRORS DELETE_VM

LOG_ERRORS GRACEFUL_REBOOT

LOG_ERRORS FORCED_REBOOT

LOG_ERRORS CREATE_VM

LOG_ERRORS CREATE_DISKS

LOG_ERRORS REMOVE_DISKS

LOG_ERRORS START_VM

LOG_ERRORS ATTACH_DISK

LOG_ERRORS DETACH_DISK