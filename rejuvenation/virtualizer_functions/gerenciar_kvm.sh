#!/usr/bin/env bash
# usage:
#   $ bash gerenciar_kvm.sh

readonly VM_NAME="debian12"

ISO_FIND() {
  if find / -name debian-12.4.0-amd64-netinst.iso | grep "debian-12.4.0-amd64-netinst.iso"; then
    echo "O arquivo debian-12.4.0-amd64-netinst.iso foi encontrado." && return 0
  else
    echo "O arquivo debian-12.4.0-amd64-netinst.iso não foi encontrado." && exit 1
  fi
}

TURN_VM_OFF() {
  virsh shutdown "$VM_NAME"
}

DELETE_VM() {
  virsh undefine "$VM_NAME"
}

GRACEFUL_REBOOT() {
  virsh shutdown "$VM_NAME"
  until virsh start "$VM_NAME"; do
    sleep 1
    echo "Waiting for machine to shutdown"
  done
}

FORCED_REBOOT() {
  virsh reset "$VM_NAME"
}

SSH_REBOOT() {
  ssh -p 2222 root@localhost "virsh reboot $VM_NAME"
}

CREATE_VM() {
  ISO_FIND

  local memory=2048
  local vcpus=2
  local disk_path="/var/lib/libvirt/images/$VM_NAME.qcow2"
  local disk_vm_size=20

  # local iso_path="/home/thayson-pc/Downloads/debian-12.4.0-amd64-netinst.iso"
  local iso_path
  iso_path=$( find / -name debian-12.4.0-amd64-netinst.iso -printf "%h/%f\n" )

  # import vm qcow2 and config vm with iso disk
  virt-install \
    --name "$VM_NAME"                         \
    --memory "$memory"                        \
    --vcpus "$vcpus"                          \
    --controller type=sata                    \
    --disk "$disk_path" size="$disk_vm_size"  \
    --os-variant generic                      \
    --network bridge=virbr0                   \
    --cdrom "$iso_path"                       \
    --virt-type kvm                           \
    --vnc
}

# usage:
#   CREATE_DISKS 3 1G
CREATE_DISKS() {
  local count=1
  local disks_quantity=$1      # amount of disks to be created
  local allocated_disk_size=$2 # size for disk

  mkdir -p ./disks_kvm

  while [[ "$count" -le "$disks_quantity" ]]; do
    qemu-img create -f qcow2 -o preallocation=full ./disks_kvm/disk"$count".qcow2 "$allocated_disk_size"
    ((count++))
  done
}

START_VM() {
  virsh start "$VM_NAME"
}

ATTACH_DISK() {
  local disk_path="$1" # /home/thayson-pc/Área\ de\ trabalho/software-aging/disco_alocado.qcow2

  # virsh attach-disk "$VM_NAME" "$disk_path" "$device" --targetbus sata --cache none --persistent
  # virsh attach-disk "$VM_NAME" "$disk_path" sda --live --config   # attach disks in executing

  virsh attach-disk "$VM_NAME" "$disk_path" sdb --type hdd --live --config

}

DETACH_DISK() {
  local disk_path="$1"

  # virsh detach-disk "$VM_NAME" sdb
  virsh detach-disk "$VM_NAME" "$disk_path"
}

LIGAR_INTERFACE_GRAFICA() {
  virt-viewer --connect qemu:///session --wait "$VM_NAME"
}
