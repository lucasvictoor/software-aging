#!/usr/bin/env bash

KERNEL_VERSION=$(uname -r)
DISTRO_ID=$(lsb_release -a | grep "Distributor ID" | awk '{print $3}')
DISTRO_CODENAME=$(lsb_release -a | grep "Codename" | awk '{print $2}')

INSTALL_DEPENDENCIES_DEBIAN() {
  apt update

  #Download general packages including systemtap
  apt install linux-headers-"$KERNEL_VERSION" linux-image-"$KERNEL_VERSION"-dbg gnupg wget curl sysstat systemtap openssh-server -y || {
    echo -e "\nERROR: Error installing general packages\n"
    exit 1
  }

  #Copies the kernel symbols to the boot folder for systemtap
  cp /proc/kallsyms /boot/System.map-"$KERNEL_VERSION"

  #Download and install virtualbox if it's not installed
  if which vboxmanage; then
    echo "Skipping virtualbox addition as it's already configured."
  else
    cp /etc/apt/sources.list /etc/apt/sources.list.backup

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $DISTRO_CODENAME contrib" >>/etc/apt/sources.list

    wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

    apt update
    if ! apt install virtualbox-7.0 -y; then
      echo -e "\nVirtualBox installed successfully\n"
    else
      echo -e "\nERROR: Error when trying to install virtualbox\n" >&2
      exit 1
    fi
  fi
}

INSTALL_DEPENDENCIES_UBUNTU() {
  apt update

  #Download general packages including systemtap
  apt install linux-headers-"$KERNEL_VERSION" gnupg wget curl sysstat systemtap openssh-server -y || {
    echo -e "\nERROR: Error installing general packages\n"
    return 1
  }

  #Copies the kernel symbols to the boot folder for systemtap
  cp /proc/kallsyms /boot/System.map-"$KERNEL_VERSION"

  #Download and install virtualbox if it's not installed
  if which vboxmanage; then
    echo "Skipping virtualbox addition as it's already configured."
  else
    cp /etc/apt/sources.list /etc/apt/sources.list.backup

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian jammy contrib" >>/etc/apt/sources.list

    wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

    apt update
    if ! apt install virtualbox-7.0 -y; then
      echo -e "\nVirtualBox installed successfully\n"
    else
      echo -e "\nERROR: Error when trying to install virtualbox\n" >&2
      return 1
    fi
  fi
}

# START_DEPENDENCIES
# DESCRIPTION:
#   starts dependency checking and install dependencies requirements
INSTALL_DEPENDENCIES() {
  case $DISTRO_ID in
  "debian")
    reset

    INSTALL_DEPENDENCIES_DEBIAN

    echo -e "\nInstallations Completed\n"
    return 0
    ;;
  "Ubuntu")
    reset

    INSTALL_DEPENDENCIES_UBUNTU

    echo -e "\nInstallations Completed\n"
    return 0
    ;;

  *)
    echo "ERROR: error identifying the distribution"
    exit 1
    ;;
  esac
}

INSTALL_DEPENDENCIES
