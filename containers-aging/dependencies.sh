#!/bin/bash

source /etc/os-release
DISTRO_ID="$ID"
DISTRO_CODENAME="$VERSION_CODENAME"

apt install python3.11-venv

python3.11 -m venv env

pip install PyYAML

soruce env/bin/activate

echo -e "Are you using a local server? If so, type the remote server ip address, else, press enter:"
read -r ip
if [ -z "$ip" ]; then
  echo "No remote server ip address provided, skipping..."
else
  ssh-keygen
  ssh-copy-id -i /root/.ssh/id_rsa.pub root@"$ip"
fi

echo -e "Would you like to install KVM? 1 - [Yes] 2 - [No]"
read -r vm
if [ "$vm" == "1" ]; then
  echo "Installing KVM..."
  apt install --no-install-recommends qemu-system -y
  apt install --no-install-recommends qemu-utils -y
  apt install --no-install-recommends libvirt-daemon-system -y

  # add root user group on libvirt
  sudo adduser "$USER" libvirt

  # Make Network active and auto-restart
  virsh net-start default
  virsh net-autostart default
fi

echo -e "Would you like to install monitoring libraries 1 - [Yes] 2 - [No]"
read -r stap
if [ "$stap" == "1" ]; then
  apt install linux-headers-"$KERNEL_VERSION" linux-image-"$KERNEL_VERSION"-dbg gnupg wget sysstat systemtap -y
  cp /proc/kallsyms /boot/System.map-"$KERNEL_VERSION"
fi

echo -e "Which service are you using? 1 - [Docker] 2 - [Podman] 3 - None"
read -r service
if [ "$service" == "1" ]; then
  apt install curl -y
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  echo "Docker installed!"
  rm -f get-docker.sh
elif [ "$service" == "2" ]; then
  pip install podman-compose
  echo "Installing Podman..."
  apt-get install podman -y
  echo "Podman installed!"
else
  echo "Invalid option, exiting..."
  exit 1
fi

echo "Finished and venv is active, change the config.yaml file"