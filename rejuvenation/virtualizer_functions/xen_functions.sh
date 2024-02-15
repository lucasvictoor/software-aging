#!/usr/bin/env bash

######################################## KVM FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
#   utilities for managing xen virtual machines                                               #
###############################################################################################

VM_NAME="xenDebian"
HOST_IP="$(hostname -I | awk '{print $1}')"

# FUNCTION=TURN_VM_OFF()
# DESCRIPTION:
#   Tries to turn off the virtual machine
TURN_VM_OFF() {
  xl shutdown "$VM_NAME"
  sleep 10 
}

# FUNCTION=DELETE_VM()
# DESCRIPTION:
#   Unregisters the virtual machine and deletes all files associated with it
DELETE_VM() {
  TURN_VM_OFF 
  xl destroy "$VM_NAME"
  xl delete "$VM_NAME"
  # rm -rf /etc/xen/"$VM_NAME".cfg  # Remove configuration file
  # rm -rf /var/lib/xen/images/"$VM_NAME".img  # Remove disk image file
}

# FUNCTION=GRACEFUL_REBOOT()
# DESCRIPTION:
#   Graceful reboot by turning vm off and on again
GRACEFUL_REBOOT() {
  xl shutdown "$VM_NAME"
  until xl create -c /etc/xen/"$VM_NAME".cfg; do
    sleep 1
    echo "Waiting for machine to shutdown"
  done
}

REBOOT_VM() {
  xl reboot "$VM_NAME"
}

SSH_REBOOT() {
  ssh -p 2222 root@"$HOST_IP" "xl reboot $VM_NAME"
}

# FUNCTION=START_VM()
# DESCRIPTION:
#   Attempts to start the vm in the background
#
# GLOBAL VARIABLES:
#   $VM_NAME
#
START_VM(){
  xl create -c /etc/xen/"$VM_NAME".cfg
}

# FUNCTION=CREATE_VM()
# DESCRIPTION:
# 
# hostname - VM name;
#
# ip - IP address for communication with the VM;
# netmask - network mask, leave the default 255.255.255.0;
# gateway - IP address of the router;
#
# vcpus - number of processor cores used by the vm;
# memory - amount of Ram memory that the VM will use;
# size - size of the system image that will be created;
# dist - linux distribution to be installed on the VM, in this case Debian 12 (bookworm);
# password - password to access the virtualized system;
# arch - system architecture;
# bridge - in order for the VM to communicate via the network with the host machine,
# it must have its own network interface connected as a bridge.
CREATE_VM() {
    local memory=512M
    local size=5G
    # local ip 
    # local netmask="255.255.255.0"
    # local gateway 
    local vcpus=2
    local password=12345678

    # ip=$(ip route get 8.8.8.8 | awk '/src/ {print $7}')
    # gateway=$(ip route | awk '/default via/ {print $3}')

    xen-create-image \
    --hostname "$VM_NAME" \
    --bridge=xenbr0 \
    --dhcp \
    --vcpus "$vcpus" \
    --memory "$memory" \
    --size "$size" \
    --dist bookworm \
    --password "$password" \
    --arch=amd64 \
    --lvm=vg0 # creates two new logical volumes within vg0 for the xenDebian vm: one for the root disk and another for the swap device
    # --ip "$ip" \
    # --netmask "$netmask" --gateway "$gateway" \
}

# FUNCTION=CREATE_DISKS()
# DESCRIPTION:
#   Creates disks in the virtual machine from the given quantity and size
#
# PARAMETERS:
#   $1 = disks_quantity --> set in 'virtualizer_functions/xen/setup.sh' as 50
#   $2 = disk_size --> set in 'virtualizer_functions/xen/setup.sh' as 1024
#
# LVM COMMANDS:
#  lvcreate - creates a Logical Volume in an existing Volume Group
#  Firstly, the -L flag is used to specify the size of the volume. Secondly, the -n flag is used to specify a name for the logical volume.
#  Finally the name of the Volume Group to which the logical volume is to belong (and from which the space is to be acquired) is specified.
CREATE_DISKS() {
  local count=1
  local disks_quantity="$1"
  local disk_size="$2"
  local volume_group="vg0"  

  mkdir -p ../xen_disks

  while [[ "$count" -le "$disks_quantity" ]]; do
    lvcreate -L "${disk_size}MB" -n disk$count "$volume_group"
    ((count++))
  done
}

# FUNCTION=REMOVE_DISKS()
# DESCRIPTION:
#   Attempts to remove all disks from virtual machine
#
# LVM COMMANDS:
# lvremove - removes a Logical Volume.
REMOVE_DISKS() {
  local count=1
  local disks_quantity="$1"
  local volume_group="vg0"

  while [[ "$count" -le "$disks_quantity" ]]; do
    lvremove -f "$volume_group/disk$count" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
      echo "Disk$count removed successfully."
    else
      echo "Error: Failed to remove disk$count."
    fi

    ((count++))
  done
}


# FUNCTION=ATTACH_DISK()
# DESCRIPTION:
#   Attaches disks to a Xen domU (xen "normal" virtual machines with no priviledges)
#   https://www.systutorials.com/how-to-dynamically-attach-a-disk-to-running-domu-in-xen/
#  
# xl [-v] block-attach <Domain> <BackDev> <FrontDev> 
# [<Mode>] [BackDomain] 
#
# GLOBAL VARIABLES:
#   $VM_NAME
#
# PARAMETERS:
#   $1 = disk_path  -->  set in en_workload.sh
#   $2 = port       --> //
#
# USAGE:
#   In the workload script for xen (xen_workload.sh):
#       source ./virtualizer_functions/xen_functions.sh
#       ATTACH_DISK "${disk_path}${count_disks}" "$port"   
ATTACH_DISK() {
  local disk_path="$1"
  local port="$2"

  xl block-attach "$VM_NAME" \
    phy:"$disk_path" \
    "$port" \
    0 \
    w
}

# FUNCTION=DETACH_DISK()
# DESCRIPTION:
#   Dettaches disks to virtual machine
#
# GLOBAL VARIABLES:
#   $VM_NAME
#
DETACH_DISK() {
  local disk_count="$1"
  local port="$2"

  xl block-detach "$VM_NAME" "$port"
}
