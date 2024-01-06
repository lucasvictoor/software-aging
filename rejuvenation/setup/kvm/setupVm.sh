#!/user/bin/env bash

source ../../virtualizer_functions/gerenciar_kvm.sh

ISO_FIND() {
  if find / -name debian-12.4.0-amd64-netinst.iso | grep "debian-12.4.0-amd64-netinst.iso"; then
    echo "O arquivo debian-12.4.0-amd64-netinst.iso foi encontrado." && return 0
  else
    echo "O arquivo debian-12.4.0-amd64-netinst.iso não foi encontrado." && exit 1
  fi
}

CREATE_VM() {
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


# CREATE_VIRTUAL_MACHINE
# DESCRIPTION:
#   TURN_VM_OFF:
#     Tries to turn off the virtual machine
#   
#   DELETE_VM:
#     Attempts to unregister the virtual machine and delete all files associated with it
#
#   CREATE_VM:
#     Imports the virtual machine vmDebian.ova
#     Attempts to modify the virtual machine to forward traffic from host port 8080 to virtual machine port 80
CREATE_VIRTUAL_MACHINE() {
  ISO_FIND

  # TURN_VM_OFF

  # DELETE_VM

  read -rp "deseja criar uma nova maquina virtual? [s/n] " escolha

  [[ "$escolha" == "s" ]] && CREATE_VM || printf "%s\n" "Não criando uma nova vm"
  cd .. || exit
}

# DISKS_MANAGEMENT
# DESCRIPTION:
#     Removes all disks from the virtual machine
#     Creates disks in the virtual machine from the given quantity and size
# 
# PARAMETERS:
#     $1 == create disks
#     $2 == remove disks
#
# DISC RECOMMENDATIONS:
#     disks_quantity=50
#     disks_size=1024
DISKS_MANAGEMENT() {
  REMOVE_DISKS
  # ERROR_HANDLING "ERROR REMOVING DISKS" 0

  CREATE_DISKS 50 1024
  # ERROR_HANDLING "ERROR CREATING DISKS" 0
}

# START_VIRTUAL_MACHINE_IN_BACKGROUND
# DESCRIPTION:
#     START_VM:
#         Starts vm in headless mode
START_VIRTUAL_MACHINE_IN_BACKGROUND() {
  read -r -p "Do you want to connect the vm? ( y | n ) - Default=n: \n" choice

  if [[ "$choice" == "y" ]]; then
    START_VM
  fi
}

# COPY_SSH_ID_AND_TEST_VIRTUAL_MACHINE_SERVER
# DESCRIPTION:
#   ssh-copy-id:
#       have an ssh key already created, then it will be copied with ssh-copy 
#       and a port will be added and in the end your current shell will be connected to the virtual machine
#
#   curl:
#       Checks whether the request to the server was successful
TEST_VIRTUAL_MACHINE_SERVER() {
  sleep 10
  if ! curl http://localhost:8080; then
    echo -e "ERROR: error when trying to start vmDebian's nginx server\n"
  fi
}

SETUP_VM() {
  DISKS_MANAGEMENT
  CREATE_VIRTUAL_MACHINE
  START_VM
  TEST_VIRTUAL_MACHINE_SERVER
}

SETUP_VM
