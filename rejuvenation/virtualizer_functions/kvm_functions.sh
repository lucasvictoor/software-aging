#!/usr/bin/env bash
# usage:
#   $ bash kvm_functions.sh

######################################## KVM FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
#   utilities for managing kvm virtual machines                                               #
###############################################################################################

readonly VM_NAME="debian12"

TURN_VM_OFF() {
  # saida=$?

  # while "$saida" -eq 0; do
  #   virsh shutdown "$VM_NAME"
  #   saida=$?
  # done

  virsh shutdown "$VM_NAME"
  saida=$?

  while [ "$saida" -eq 0 ]; do
    printf "%s\n" "esperando para desligar"
    virsh shutdown "$VM_NAME"
    saida=$?

    sleep 3
  done

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

# FUNCTION=CREATE_DISKS()
# USAGE:
#   CREATE_DISKS 3 1G
CREATE_DISKS() {
  local count=1
  local disks_quantity=$1      # amount of disks to be created
  local allocated_disk_size=$2 # size for disk

  mkdir -p ./disks_kvm

  while [[ "$count" -le "$disks_quantity" ]]; do
    qemu-img create -f qcow2 -o preallocation=full ./disks_kvm/disk"$count".qcow2 "$allocated_disk_size"M
    sleep 1
    ((count++))
  done
}

REMOVE_DISKS() {
  local disk_files
  disk_files=$(ls ./disks_kvm/*.qcow2) # lista todos os discos no diretório 'disks'

  for disk_file in $disk_files; do
    echo -e "\n--->> Deletando o disco: $disk_file \n"
    rm -f "$disk_file"
    sleep 1
    if [[ -f $disk_file ]]; then
      echo -e "Erro: Falha ao deletar o disco: $disk_file \n"
    else
      echo "Disco $disk_file deletado com sucesso"
    fi
  done
}

# FUNCTION=START_VM()
# RUN FOR HELPER:
#   virsh start --help
START_VM() {
  virsh start "$VM_NAME"
}

# FUNCTION=ATTACH_DISK()
# RUN FOR HELPER:
#   virsh attach-disk --help
ATTACH_DISK() {
  local disk_path="$1"
  local target="$2"

  # virsh attach-disk "$VM_NAME" "$disk_path" "$target" --subdriver qcow2 --live --config
  # virsh attach-disk debian12 setup/kvm/disks_kvm/disk5.qcow2 sdb --type disk --live --config

  virsh attach-disk "$VM_NAME" --source "$disk_path" --target "$target" --persistent --config

}

# FUNCTION=DETACH_DISK()
# RUN FOR HELPER:
#   virsh detach-disk --help
DETACH_DISK() {
  local target="$1"

  # virsh detach-disk "$VM_NAME" "$disk_path"
  virsh detach-disk "$VM_NAME" "$target" --persistent --config
}

# FUNCTION=TURN_ON_GRAPHICAL_INTERFACE()
# RUN FOR HELPER:
#   virt-viewer --help
TURN_ON_GRAPHICAL_INTERFACE() {
  virt-viewer --connect qemu:///session --wait "$VM_NAME"
}
