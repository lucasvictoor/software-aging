#!/user/bin/env bash

###############################
# REFERENCIAS

# https://www.baeldung.com/linux/qemu-from-terminal
###############################

# configs create_vm
tamanho_nao_alocado=20G
disco_kvm="myVirtualDisk.qcow2"
formato="qcow2"

CREATE_VM() {
    qemu-img create -f "$formato" "$disco_kvm" "$tamanho_nao_alocado"
}

# configs vm_power_on
ram=2G
caminho="/caminho/completo/do/debian.qcow2"
formato_disco="qcow2"

# ligar vm
VM_POWER_ON() {
    qemu-system-x86_64 -m "$ram" -drive file="$caminho",format="$formato_disco" -enable-kvm
}

# configs emulate_vm
ram_emulate=2G
nucleos=2
disco_emulado="myVirtualDisk.qcow2"
os_installer="algum_caminho_a_iso/iso_em_questao.iso"
ip_dhcp4_with_netmask="192.168.0.0/24"  # configure de acordo com seu ip
ip_dhcp4="192.168.0.9" # configure de acordo com seu ip

EMULATE_VM() {
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