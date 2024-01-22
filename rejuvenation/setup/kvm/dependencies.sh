#!/usr/bin/env bash
# usage:
#   $ bash dependencies.sh

# ############################## IMPORTS #############################
source ../../machine_resources_monitoring/general_dependencies.sh
# ####################################################################

INSTALL_KVM_LIBVIRT_DEPENDENCIES() {
    reset

    if ! which qemu-system-x86_64 >/dev/null; then
        apt install qemu-system libvirt-daemon-system -y
    fi

    # add root user group on libvirt
    sudo adduser "$USER" libvirt

    # Make Network active and auto-restart
    virsh net-start default
    virsh net-autostart default
}

INSTALL_KVM_WITHOUT_LIBVIRT_DEPENDENCIES() {
    reset

    if ! which qemu-system-x86_64 > /dev/null; then
        apt install qemu-system -y
    fi
}

printf "[1] - to download kvm with virtlib\n[2] - to download kvm without virtlib\n"
read -rp "choice: " choice

INSTALL_GENERAL_DEPENDENCIES

if [[ "$choice" -eq 1 ]]; then
    INSTALL_KVM_LIBVIRT_DEPENDENCIES

elif [[ "$choice" -eq 2 ]]; then
    INSTALL_KVM_WITHOUT_LIBVIRT_DEPENDENCIES
else
    echo "enter valid value!" && exit 1
fi
