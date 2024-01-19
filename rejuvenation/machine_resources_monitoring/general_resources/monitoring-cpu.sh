#!/bin/bash

# Script to monitor the cpu usage of the host machine and log it to a CSV file

cpu=$(mpstat | grep all)
usr=$(echo $cpu | awk '{print $3}')
nice=$(echo $cpu | awk '{print $4}')
sys=$(echo $cpu | awk '{print $5}')
iowait=$(echo $cpu | awk '{print $6}')
soft=$(echo $cpu | awk '{print $8}')

echo "$usr;$nice;$sys;$iowait;$soft;$date_time" >>logs/machine_monitoring-cpu.csv
