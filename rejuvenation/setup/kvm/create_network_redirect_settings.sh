#!/usr/bin/env bash

# ############################## IMPORTS #############################
source ../../virtualizer_functions/kvm_functions.sh
# ####################################################################

VM_NAME=$1

readonly GUEST_IP="$GET_GUEST_IP"
readonly HOST_IP="$GET_HOST_IP"

readonly NETWORK_INTERFACE="virbr0"

readonly REDIRECT_SSH_PORT="2222, 22"       # origem, destino
readonly REDIRECT_NGINX_PORT="8080, 80"     # origem, destino

mv ./libvirt-hook-qemu/hooks.json ./libvirt-hook-qemu/hooks.json.backup

echo -e "{
    // Note: comments in two styles are supported
    /* Note: comments in two styles are supported */

    // Name of the guest VM
    \"$VM_NAME\": {

        // Name of the network interface the guest is using
        \"interface\": \"$NETWORK_INTERFACE\",

        // IP address of the guest
        \"private_ip\": \"$GUEST_IP\",

        // Remote IP which gets permission to access the ports
        // This line can be omitted, allowing any remote IP access
       // \"source_ip\": \"$HOST_IP\",

        /*
        When opening ports, you have two choices:
        1. Opening single ports one by one using \"port_map\"
           This allows you to map an external port x to an internal port y if you wish

        2. Opening a range of ports altogether using \"port_range\"

        You can use one or both of these, as the examples below illustrate.
        */

        \"port_map\": {
            // Protocol can be one of tcp, udp or icmp
            \"tcp\": [
                [$REDIRECT_SSH_PORT],   // ssh redirect port
                [$REDIRECT_NGINX_PORT]  // nginx redirect port
            ]
        }
    }
}" > ./libvirt-hook-qemu/hooks.json     # /etc/libvirt/hooks/hooks.json

[[ $? -eq 0 ]] && printf "\nredirecionamento de rede configurado\n" || printf "\nerro em configuracoes de redirecionamento de rede\n"
