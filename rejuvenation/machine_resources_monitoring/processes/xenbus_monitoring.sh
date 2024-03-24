#!/bin/bash

# Script to continuously monitor the Xenbus process and log resource usage to a CSV file

while true; do
  pid_xenbus=$(pidof -s xenbus)
  
  date_time=$(date +%d-%m-%Y-%H:%M:%S)

  if [ -n "$pid_xenbus" ]; then
    data=$(pidstat -u -h -p $pid_xenbus -T ALL -r 1 1 | sed -n '4p')
    thread=$(cat /proc/"$pid_xenbus"/status | grep Threads | awk '{print $2}')
    cpu=$(echo "$data" | awk '{print $8}')
    mem=$(echo "$data" | awk '{print $14}')
    vmrss=$(echo "$data" | awk '{print $13}')
    vsz=$(echo "$data" | awk '{print $12}')
    swap=$(cat /proc/"$pid_xenbus"/status | grep Swap | awk '{print $2}')

    echo "$cpu;$mem;$vmrss;$vsz;$thread;$swap;$date_time" >> logs/xen_monitoring-xenbus.csv
  else
    sleep 1
    echo "0;0;0;0;0;0;0" >> logs/xen_monitoring-xenbus.csv
  fi

done
