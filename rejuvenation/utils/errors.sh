#!/usr/bin/env bash

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