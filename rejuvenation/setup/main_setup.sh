#!/usr/bin/env bash

################################################# START IMPORTS
source ./dependencies.sh
source ./setupVm.sh
source ../vbox_functions.sh

# CHECK_ROOT
# DESCRIPTION:
#   check if script is running as root
CHECK_ROOT() {
   if [[ "$EUID" -ne 0 ]]; then
        echo "Run Script as Super Administrator ( need root )"
        exit 1
    fi
}

# MAIN_SETUP
# DESCRIPTION:
#   start setup
MAIN_SETUP() {
    CHECK_ROOT

    read -r -p "Do you want to check dependencies? ( y | n ) - Default=n: " choice

    if [[ "$choice" == "y" ]]; then
        echo "checking dependencies"

        START_DEPENDENCIES # ./dependencies.sh
    else
        echo "will not check dependencies"

        ################################## START ./setupVm.sh
        CHECK_DEBIAN_IMAGE
        CONTROL_VIRTUAL_MACHINE

        DISKS_MANAGMENT CREATE_DISKS REMOVE_DISKS

        START_VIRTUAL_MACHINE_IN_BACKGROUND
        COPY_SSH_ID_AND_TEST_VIRTUAL_MACHINE_SERVER
        ################################## END ./setupVm.sh
    fi
}
MAIN_SETUP
