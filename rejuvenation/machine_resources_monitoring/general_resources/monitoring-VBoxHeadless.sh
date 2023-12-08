#!/bin/bash

pidHead=$(pidof -s VBoxHeadless)
#echo $pid
if [ -n "$pidHead" ]; then
  data=$(pidstat -u -h -p $pidHead -T ALL -r 1 1 | sed -n '4p')
  thread=$(cat /proc/"$pidHead"/status | grep Threads | awk '{print $2}')
  cpu=$(echo "$data" | awk '{print $8}')
  mem=$(echo "$data" | awk '{print $14}')
  vmrss=$(echo "$data" | awk '{print $13}')
  vsz=$(echo "$data" | awk '{print $12}')
  swap=$(cat /proc/"$pidHead"/status | grep Swap | awk '{print $2}')

  #vm_total_rss=$(($vmrss + $vm_total_rss))
  #vm_total_vsz=$(($vsz + $vm_total_vsz))

  echo "$cpu;$mem;$vmrss;$vsz;$thread;$swap;$date_time" >>logs/monitoring-VBoxHeadless.csv
else
  echo "pid is empty"
  exit 1
fi