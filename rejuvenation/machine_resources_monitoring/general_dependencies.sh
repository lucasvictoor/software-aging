#!/usr/bin/env bash

KERNEL_VERSION=$(uname -r)

source /etc/os-release
DISTRO_ID="$ID"
DISTRO_CODENAME="$VERSION_CODENAME"

INSTALL_GENERAL_DEPENDENCIES() {
  reset; apt update

  #Download general packages including systemtap
  apt install linux-headers-"$KERNEL_VERSION" linux-image-"$KERNEL_VERSION"-dbg gnupg wget curl sysstat systemtap -y || {
    echo -e "\nERROR: Error installing general packages\n"
    exit 1
  }

  #Copies the kernel symbols to the boot folder for systemtap
  cp /proc/kallsyms /boot/System.map-"$KERNEL_VERSION"
}