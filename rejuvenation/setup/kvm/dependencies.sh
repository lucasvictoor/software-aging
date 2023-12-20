#!/usr/bin/env bash

INSTALL_KVM_DEPENDENCIES() {
    reset

    if ! which qemu-system-x86_64 > /dev/null; then
        apt install qemu-system
    fi
}

INSTALL_KVM_DEPENDENCIES