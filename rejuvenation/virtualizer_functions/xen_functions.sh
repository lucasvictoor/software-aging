#!/usr/bin/env bash

######################################## XEN FUNCTIONS ########################################
# Universidade Federal do Agreste de Pernambuco                                               #
# Uname Research Group                                                                        #
#                                                                                             #
# ABOUT:                                                                                      #
#   utilities for managing Xen virtual machines                                               #
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
#   Deletes the DomU /etc/xen/xenDebian.cfg configuration file and all associated LVM volumes (swap and root disk) located in vg0
DELETE_VM() {
  xen-delete-image --lvm=vg0 "$VM_NAME"
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

# FUNCTION=FORCED_REBOOT()
# DESCRIPTION:
#   Forcibly reboot the virtual machine
FORCED_REBOOT() {
  xl destroy "$VM_NAME"
  START_VM
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
  xl create /etc/xen/"$VM_NAME".cfg
  # takes a few seconds for the status to e updated
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
# memory - amount of RAM that the VM will use;
# size - size of the system image that will be created;
# dist - linux distribution to be installed on the VM, in this case Debian 12 (bookworm);
# password - password to access the virtualized system;
# arch - system architecture;
# bridge - in order for the VM to communicate via the network with the host machine,
# it must have its own network interface connected as a bridge.
# lvm=vg0 - creates two new logical volumes within vg0 for the xenDebian vm: one for the root disk and another for the swap device
CREATE_VM() {
    local memory=512M
    local size=5G
    local ip 
    local netmask="255.255.255.0"
    local gateway 
    local vcpus=2
    local password=12345678

    ip=$(ip route get 8.8.8.8 | awk '/src/ {print $7}')
    gateway=$(ip route | awk '/default via/ {print $3}')


    xen-create-image \
    --hostname "$VM_NAME" \
    --dhcp \
    --vcpus "$vcpus" \
    --memory "$memory" \
    --size "$size" \
    --dist bookworm \
    --password "$password" \
    --arch=amd64 \
    --lvm=vg0 \ 
    --bridge=xenbr0 
    #--ip "$ip" \
    #--netmask "$netmask" --gateway "$gateway" 
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
#   Attempts to remove all disks from virtual machine, except the VM's swap and disk volumes
#
# LVM COMMANDS:
# lvremove - removes a Logical Volume.
REMOVE_DISKS() {
  local volume_group="vg0"
  local disks_list=$(lvdisplay | grep "LV Path" | grep "$volume_group"| grep -vE "${VM_NAME}-swap|${VM_NAME}-disk" | awk '{print $3}')

  if [ -z "$disks_list" ]; then
    echo "No disks found in volume group $volume_group."
    return
  fi

  for disk in $disks_list; do
    lvremove -f "$disk" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
      echo "Disk $disk removed successfully."
    else
      echo "Error: Failed to remove $disk."
    fi
  done
}

# FUNCTION=ATTACH_DISK()
# DESCRIPTION:
#   Attaches disks to a Xen domU 
#   https://www.systutorials.com/how-to-dynamically-attach-a-disk-to-running-domu-in-xen/
#  
# xl [-v] block-attach <Domain> <BackDev> <FrontDev> 
# [<Mode>] [BackDomain] 
#
# GLOBAL VARIABLES:
#   $VM_NAME
#
# PARAMETERS:
#   $1 = disk_path  -->  set in xen_workload.sh
#   $2 = frotend_name  --> set in xen_workload.sh
#
# USAGE:
#   In the workload script for xen (xen_workload.sh):
#       source ./virtualizer_functions/xen_functions.sh
#       ATTACH_DISK "${disk_path}${count_disks}" "$frontend_name"   
ATTACH_DISK() {
  local disk_path="$1"
  local frontend_name="$2"

  if xl block-attach "$VM_NAME" phy:"$disk_path" "$frontend_name" w; then
    echo "Disk attached successfully: $disk_path -> $frontend_name"
  else
    echo "Failed to attach disk: $disk_path"
  fi
}

# FUNCTION=DETACH_DISK()
# DESCRIPTION:
#   Dettaches disks from virtual machine
#
# GLOBAL VARIABLES:
#   $VM_NAME
#
DETACH_DISK() {
  local frontend_name="$1"

  if xl block-detach "$VM_NAME" "$frontend_name"; then
    echo "Disk detached successfully: $frontend_name"
  else
    echo "Failed to detach disk: $frontend_name"
  fi
}