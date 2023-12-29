#!/usr/bin/env bash

###############################
# REFERENCIAS

# https://www.baeldung.com/linux/qemu-from-terminal
###############################

# configs create_disks
disco_kvm="kvm_disk"

CREATE_DISKS() {
    local count=1
    local disks_quantity=$1             # amount of disks to be created
    local unallocated_disk_size=$2      # size in MB for each disk
    
    mkdir -p ../disks_kvm

  while [[ "$count" -le "$disks_quantity" ]]; do
    qemu-img create -f qcow2 "$disco_kvm$count.qcow2" "$unallocated_disk_size"MB
    ((count++))
  done
}

NEW_DISK() {
    local unallocated_disk_size=20G
    qemu-img create -f qcow2 "$disco_kvm.qcow2" "$unallocated_disk_size"
}

CONFIGURE_NEW_VM() {
    # configs configure_new_vm
    local ram_emulate=2G                                            # quantidade de ram a ser usada
    local nucleos=2                                                 # quantidade de cpus
    local disco_emulado="myVirtualDisk.qcow2"                       # disco criado para instalar o so
    local os_installer="algum_caminho_a_iso/iso_em_questao.iso"     # caminho para a iso
    local ip_dhcp4_with_netmask="192.168.0.0/24"                    # configure de acordo com seu ip
    local ip_dhcp4="192.168.0.9"                                    # configure de acordo com seu ip

    qemu-system-x86_64 \
        -enable-kvm                                                               \
        -m "$ram_emulate"                                                         \
        -smp "$nucleos"                                                           \
        -hda "$disco_emulado"                                                     \
        -boot d                                                                   \
        -cdrom "$os_installer"                                                    \
        -netdev user,id=net0,net="$ip_dhcp4_with_netmask", dhcpstart="$ip_dhcp4"  \
        -device virtio-net-pci,netdev=net0                                        \
        -vga qxl                                                                  \
        -device AC97
}

# start vm 
VM_POWER_ON() {
    # configs vm_power_on
    local ram=2G                                        # ram que deseja usar
    local caminho="/caminho/completo/do/debian.qcow2"   # caminho do disco com o so instalado
    local formato_disco="qcow2"                         # formato do disco usado

    qemu-system-x86_64 -m "$ram" -drive file="$caminho",format="$formato_disco" -enable-kvm
}