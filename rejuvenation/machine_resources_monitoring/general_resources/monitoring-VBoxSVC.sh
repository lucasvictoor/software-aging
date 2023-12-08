#!/bin/bash

pidSVC=$(pidof -s VBoxSVC)
#echo $pid
if [ -n "$pidSVC" ]; then
  data=$(pidstat -u -h -p $pidSVC -T ALL -r 1 1 | sed -n '4p')
  thread=$(cat /proc/"$pidSVC"/status | grep Threads | awk '{print $2}')
  cpu=$(echo "$data" | awk '{print $8}')
  mem=$(echo "$data" | awk '{print $14}')
  vmrss=$(echo "$data" | awk '{print $13}')
  vsz=$(echo "$data" | awk '{print $12}')
  swap=$(cat /proc/"$pidSVC"/status | grep Swap | awk '{print $2}')

  #vm_total_rss=$(($vmrss + $vm_total_rss))
  #vm_total_vsz=$(($vsz + $vm_total_vsz))

  echo "$cpu;$mem;$vmrss;$vsz;$thread;$swap;$date_time" >>logs/monitoring-VBoxSVC.csv
else
  echo "pid is empty"
  exit 1
fi