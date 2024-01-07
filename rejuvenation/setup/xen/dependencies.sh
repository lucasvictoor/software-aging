#!/usr/bin/env bash

source ../../machine_resources_monitoring/general_dependencies.sh

INSTALL_XEN_DEPENDENCIES() {
    apt install xen-system xen-tools lvm2

    #network backup
    cp /etc/network/interfaces /etc/network/interfaces.backup
}

INSTALL_GENERAL_DEPENDENCIES

INSTALL_XEN_DEPENDENCIES