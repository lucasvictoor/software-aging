#!/usr/bin/env bash

######################################## LXC FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #  
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
# utilities for managing LXC virtual machines                                                 #
###############################################################################################

VM_NAME="vmDebian"

START_VM() {
  lxc-start -n "$VM_NAME"
}

STOP_VM() {
  lxc-stop -n "$VM_NAME"
}

DELETE_VM() {
  lxc-destroy -n "$VM_NAME"
}

# FUNCTION=GRACEFUL_REBOOT()
# DESCRIPTION:
#   Graceful reboot by turning vm off and on again
GRACEFUL_REBOOT() {
  lxc-stop -n "$VM_NAME"
  lxc-start -n "$VM_NAME"
}

# FUNCTION=FORCED_REBOOT()
# DESCRIPTION:
#   Forcibly reboot the virtual machine
FORCED_REBOOT() {
  lxc-stop -n "$VM_NAME"
  lxc-start -n "$VM_NAME"
}

CREATE_DISKS() {
  local count=1
  local disks_quantity="$1"     
  local allocated_disk_size="$2"

  mkdir -p ./disks_lxc

  while [[ "$count" -le "$disks_quantity" ]]; do
    truncate -s "$allocated_disk_size" ./disks_lxc/disk"$count".img
    ((count++))
  done
}

REMOVE_DISKS() {
  local disk_files
  disk_files=$(ls ./disks_lxc/*.img)

  for disk_file in $disk_files; do
    echo -e "\n--->> Deletando o disco: $disk_file \n"
    rm -f "$disk_file"
    sleep 0.2
    if [[ -f $disk_file ]]; then
      echo -e "Erro: Falha ao deletar o disco: $disk_file \n"
    else
      echo "Disk $disk_file Deletado com Sucesso"
    fi
  done
}

# FUNCTION=ATTACH_DISK()
# DESCRIPTION:
#   Attaches disks to virtual machine
#
# PARAMETERS:
#   disk_path = $1
#   target = $2
ATTACH_DISK() {
  local disk_path="$1"
  local target="$2"

  if [[ -z "$disk_path" || -z "$target" ]]; then
    echo "ERRO: Parâmetros ausentes para anexar o disco."
    return 1
  fi

  if [[ ! -f "$disk_path" ]]; then
    echo "ERRO: Arquivo de disco não encontrado em $disk_path."
    return 1
  fi

  lxc device add "$VM_NAME" disk disk source="$disk_path" path="$target"

  if [[ $? -eq 0 ]]; then
    echo "Disco anexado com sucesso ao alvo $target."
  else
    echo "ERRO: Falha ao anexar o disco ao alvo $target."
  fi
}

# FUNCTION=DETACH_DISK()
# DESCRIPTION:
#   Detach disks to virtual machine
#
# PARAMETERS:
#   disk_path = $1
#   target = $2
DETACH_DISK() {
  local target="$1"

  if [[ -z "$target" ]]; then
    echo "ERRO: Parâmetro ausente para desanexar o disco."
    return 1
  fi

  lxc device remove "$VM_NAME" "$target"

  if [[ $? -eq 0 ]]; then
    echo "Disco desanexado com sucesso do alvo $target."
  else
    echo "ERRO: Falha ao desanexar o disco do alvo $target."
  fi
}