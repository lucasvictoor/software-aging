#!/bin/bash

apt install sysstat wget -y

echo -e "Are you using a local server? If so, type the remote server ip address, else, press enter:"
read -r ip
if [ -z "$ip" ]; then
  echo "No remote server ip address provided, skipping..."
else
  ssh-keygen
  ssh-copy-id -i /root/.ssh/id_rsa.pub root@"$ip"
fi

echo -e "Which service are you using? 1 - [Docker] 2 - [Podman] 3 - [LXD/LXC]"
read -r service
if [ "$service" == "1" ]; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  echo "Docker installed!"
elif [ "$service" == "2" ]; then
  echo "Installing Podman..."
  apt-get install podman -y
  echo "Podman installed!"
elif [ "$service" == "3" ]; then
  echo "Installing LXD/LXC..."
  apt-get install lxd lxc -y
  echo "LXD/LXC installed!"
else
  echo "Invalid option, exiting..."
  exit 1
fi