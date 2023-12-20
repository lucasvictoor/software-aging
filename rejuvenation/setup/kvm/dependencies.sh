#!/usr/bin/env bash

INSTALL_KVM_LIBVIRT_DEPENDENCIES() {
    reset

    if ! which qemu-system-x86_64 >/dev/null; then
        apt install qemu-system libvirt-daemon-system -y
    fi

    # add root user group on libvirt
    adduser "$USER" libvirt
}

INSTALL_KVM_WITHOUT_LIBVIRT_DEPENDENCIES() {
    reset

    if ! which qemu-system-x86_64 > /dev/null; then
        apt install qemu-system
    fi
}

read -rp "[1] - to download kvm with virtlib [2] - to download kvm without virtlib: " choice

if [[ "$choice" -eq 1 ]]; then
    INSTALL_KVM_LIBVIRT_DEPENDENCIES

elif [[ "$choice" -eq 2 ]]; then
    INSTALL_KVM_WITHOUT_LIBVIRT_DEPENDENCIES
else
    echo "enter valid value!"
fi
