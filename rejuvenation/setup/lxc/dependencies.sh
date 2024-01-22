#!/usr/bin/env bash
# usage:
#   $ bash dependencies.sh

# ############################## IMPORTS #############################
source ../../machine_resources_monitoring/general_dependencies.sh
# ####################################################################

INSTALL_LXC_DEPENDENCIES() {
    reset

    if ! which lxc >/dev/null; then
        apt install lxc -y
    fi
    # Inicie o serviço LXD (pode variar dependendo do sistema)
    sudo systemctl start lxd

    # Habilite o serviço LXD para iniciar na inicialização
    sudo systemctl enable lxd
}

INSTALL_GENERAL_DEPENDENCIES

INSTALL_LXC_DEPENDENCIES