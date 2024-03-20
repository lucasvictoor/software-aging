#!/bin/bash

# REFERENCES:
# https://wiki.xenproject.org/wiki/Xenstored
# Xen uses a xenstore daemon to allow dom0 and guests get access to information about configuration space for itself and the system.
# Xen currently supports two versions of the daemons: cxenstored and oxenstored

# Script to continuously monitor the Xen process Xenstore and log resource usage to a CSV file

while true; do
  :
  pid_oxenstored=$(pidof -s oxenstored)
  
  date_time=$(date +%d-%m-%Y-%H:%M:%S)

  if [ -n "$pid_oxenstored" ]; then
    data=$(pidstat -u -h -p $pid_oxenstored -T ALL -r 1 1 | sed -n '4p')
    thread=$(cat /proc/"$pid_oxenstored"/status | grep Threads | awk '{print $2}')
    cpu=$(echo "$data" | awk '{print $8}')
    mem=$(echo "$data" | awk '{print $14}')
    vmrss=$(echo "$data" | awk '{print $13}')
    vsz=$(echo "$data" | awk '{print $12}')
    swap=$(cat /proc/"$pid_oxenstored"/status | grep Swap | awk '{print $2}')

    echo "$cpu;$mem;$vmrss;$vsz;$thread;$swap;$date_time" >> logs/xen_monitoring-oxenstored.csv
  else
    sleep 1
    echo "0;0;0;0;0;0;0" >> logs/xen_monitoring-oxenstored.csv
  fi

done
