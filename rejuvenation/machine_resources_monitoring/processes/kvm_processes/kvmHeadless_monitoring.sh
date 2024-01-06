#!/usr/bin/env bash

mkdir -p logs
echo "cpu;mem;vmrss;vsz;threads;swap;date_time" >logs/kvmHeadless_monitoring.csv

while true; do
  # Obtém o ID da VM
  vm_id=$(pgrep -f qemu-system-x86)
  DATETIME=$(date +%d-%m-%Y-%H:%M:%S)

  if [ -n "$vm_id" ]; then
    data=$(pidstat -u -h -p "$vm_id" -T ALL -r 1 1 | sed -n '4p')
    thread=$(cat /proc/"$vm_id"/status | grep Threads | awk '{print $2}')

    cpu=$(echo "$data" | awk '{print $8}')
    mem=$(echo "$data" | awk '{print $14}')
    vmrss=$(echo "$data" | awk '{print $13}')
    vsz=$(echo "$data" | awk '{print $12}')
    swap=$(cat /proc/"$vm_id"/status | grep Swap | awk '{print $2}')

    echo "$cpu;$mem;$vmrss;$vsz;$thread;$swap;$DATETIME" >>logs/kvmHeadless_monitoring.csv
  else
    sleep 1
    echo "0;0;0;0;0;0;0" >>logs/kvmHeadless_monitoring.csv
  fi
done
