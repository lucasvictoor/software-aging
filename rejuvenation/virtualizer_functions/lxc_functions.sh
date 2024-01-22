#!/usr/bin/env bash

######################################## LXC FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
#   Utilities for managing LXC (Linux Containers) virtual machines                            #
###############################################################################################

# GLOBAL VARIABLES:
CONTAINER_NAME="containerDebian"

# FUNCTION=TURN_CONTAINER_OFF()
# DESCRIPTION: Tries to turn off the LXC container
# LXC COMMANDS:
#   lxc stop containerDebian
TURN_CONTAINER_OFF() {
  lxc stop "$CONTAINER_NAME"
}

# FUNCTION=DELETE_CONTAINER()
# DESCRIPTION: Stops and deletes the LXC container
# LXC COMMANDS:
#   lxc stop containerDebian
#   lxc delete containerDebian
DELETE_CONTAINER() {
  lxc stop "$CONTAINER_NAME"
  lxc delete "$CONTAINER_NAME"
}

# FUNCTION=GRACEFUL_REBOOT_CONTAINER()
# DESCRIPTION: Initiates a graceful reboot of the LXC container
# LXC COMMANDS:
#   lxc restart containerDebian
GRACEFUL_REBOOT_CONTAINER() {
  lxc restart "$CONTAINER_NAME"
}

# FUNCTION=FORCED_REBOOT_CONTAINER()
# DESCRIPTION: Initiates a forced reboot of the LXC container
# LXC COMMANDS:
#   lxc restart --force containerDebian
FORCED_REBOOT_CONTAINER() {
  lxc restart --force "$CONTAINER_NAME"
}

# FUNCTION=CREATE_CONTAINER()
# DESCRIPTION: Creates and starts an LXC container named "containerDebian"
# LXC COMMANDS:
#   lxc launch <image> containerDebian
#   lxc config device add containerDebian <device-name> disk source=<disk-path>
CREATE_CONTAINER() {
  lxc launch ubuntu:20.04 "$CONTAINER_NAME"
  #Adição de uma config adicional aqui, mas não sei como ainda
}

# FUNCTION=CREATE_DISKS_CONTAINER()
# DESCRIPTION: Creates disks in the LXC container from the given quantity and size
CREATE_DISKS_CONTAINER() {
  #Ainda não adicionado/implementado
  echo "Not implemented for LXC"
}

# FUNCTION=REMOVE_DISKS_CONTAINER()
# DESCRIPTION: Attempts to remove all disks from the LXC container
REMOVE_DISKS_CONTAINER() {
  #Ainda não adicionado/implementado
  echo "Not implemented for LXC"
}

# FUNCTION=START_CONTAINER()
# DESCRIPTION: Attempts to start the LXC container
# LXC COMMANDS:
#   lxc info --state containerDebian | grep -q "Running"
#   lxc start containerDebian
START_CONTAINER() {
  if lxc info --state "$CONTAINER_NAME" | grep -q "Running"; then
    echo -e "WARNING: o conteiner já está em execucão.\n"
  else
    lxc start "$CONTAINER_NAME"
  fi
}

# FUNCTION=ATTACH_DISK_CONTAINER()
# DESCRIPTION: Attaches disks to the LXC container
ATTACH_DISK_CONTAINER() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ATTACH_DISK_CONTAINER <disk_path>"
    return 1
  fi

  local disk_path="$1"
  local container_pid

  # PID é usado para indicar qual processo dentro do conteiner o comando deve ser executado.
  # Obter o PID do processo do contêiner:
  container_pid=$(lxc info --name "$CONTAINER_NAME" | grep "PID:" | awk '{print $2}')

  # Executar lxc-attach para anexar o disco:
  lxc-attach --clear-env --set-var "container=lxc" --pid="$container_pid" -- /bin/sh -c "mount /dev/sdb1 /mnt && echo 'Disk attached successfully.'"

  # Verificar se o dispositivo do disco é /dev/sbd1 e a montagem ser /mnt
}

# FUNCTION=DETACH_DISK_CONTAINER()
# DESCRIPTION: Detaches disks from the LXC container
DETACH_DISK_CONTAINER() {
  #Ainda não adicionado/implementado
  echo "Not implemented for LXC"
}