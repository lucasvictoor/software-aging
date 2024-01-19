#!/bin/bash

# Script to monitor the various memory types usage of the host machine and log it alongside the datetime in a csv file

mem=$(free | grep Mem)
used=$(echo $mem | awk '{print $3}')
cached=$(cat /proc/meminfo | grep -i Cached | sed -n '1p' | awk '{print $2}')
buffer=$(cat /proc/meminfo | grep -i Buffers | awk '{print $2}')
swap=$(cat /proc/meminfo | grep -i Swap | grep -i Free | awk '{print $2}')

echo "$used;$cached;$buffer;$swap;$date_time" >>logs/machine_monitoring-mem.csv