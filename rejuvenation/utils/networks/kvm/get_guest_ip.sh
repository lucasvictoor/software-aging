#!/usr/bin/env bash

# shellcheck disable=SC2034

GET_GUEST_IP="$(virsh net-dhcp-leases default | grep "debian" | awk '/ipv4/ {gsub("/24", "", $5); print $5}')"