#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../machine_resources_monitoring/general_dependencies.sh
# ####################################################################

# FUNCTION=SYSTEM_UPDATE()
# DESCRIPTION:
# Attempts to update the host's repositories and system apps
SYSTEM_UPDATE() {
  apt-get update && apt-get upgrade
} 

# Install LXC if it's not installed
LXC_INSTALL() {
  if dpkg -l | grep -q '^ii.*lxc'; then
    echo "Ignorando a adição do LXC porque já está configurado."
  else
    if ! apt install lxc -y; then
      echo -e "\nERRO: Erro ao tentar instalar o LXC\n" >&2
      exit 1
    else
      echo -e "\nLXC instalado com sucesso\n"
    fi
  fi
}

# START_DEPENDENCIES
# DESCRIPTION:
#   starts dependency checking and install dependencies requirements
INSTALL_DEPENDENCIES() {
  case $DISTRO_ID in
  "debian" | "ubuntu")
    INSTALL_GENERAL_DEPENDENCIES
    LXC_INSTALL

    echo -e "\nInstalações completas\n"
    return 0
    ;;

  *)
    echo "ERRO: erro ao identificar a distribuição"
    exit 1
    ;;
  esac
}

INSTALL_DEPENDENCIES