#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../machine_resources_monitoring/general_dependencies.sh
# ####################################################################

# SYSTEM_UPDATE()
# DESCRIPTION:
# Attempts to update the host's repositories and system apps
SYSTEM_UPDATE() {
  sudo apt-get update && sudo apt-get upgrade -y
} 

INSTALL_UTILS() {
  echo "Instalando utilitários necessários: lxc-templates e bridge-utils..."
  if sudo apt-get install lxc-templates bridge-utils -y; then
    echo "Utilitários instalados com sucesso."
  else
    echo "Erro ao instalar utilitários." >&2
    exit 1
  fi
}

# LXC_INSTALL()
# DESCRIPTION:
# Install LXC if it's not installed
LXC_INSTALL() {
  if ! dpkg -l lxc | grep -q '^ii'; then
    echo "LXC não está instalado, instalando..."
    if ! sudo apt-get install lxc -y; then
      echo -e "\nERRO: Erro ao tentar instalar o LXC\n" >&2
      exit 1
    else
      echo -e "\nLXC instalado com sucesso\n"
    fi
  else
    echo "LXC já está instalado, ignorando."
  fi
}

# INSTALL_DEPENDENCIES()
# DESCRIPTION:
# Starts dependency checking and installs dependencies requirements
INSTALL_DEPENDENCIES() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
  else
    echo "Não foi possível determinar a distribuição do sistema."
    exit 1
  fi

  if [ $ID = "debian" ]; then
    SYSTEM_UPDATE
    INSTALL_GENERAL_DEPENDENCIES
    LXC_INSTALL
    echo -e "\nInstalações completas\n"
  else
    echo "ERRO: Este script é apenas para Debian."
    exit 1
  fi
}

INSTALL_DEPENDENCIES