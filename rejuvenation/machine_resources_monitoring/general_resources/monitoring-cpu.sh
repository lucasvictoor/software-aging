#!/bin/bash

cpu=$(mpstat | grep all)
usr=$(echo $cpu | awk '{print $3}')
nice=$(echo $cpu | awk '{print $4}')
sys=$(echo $cpu | awk '{print $5}')
iowait=$(echo $cpu | awk '{print $6}')
soft=$(echo $cpu | awk '{print $8}')

echo "$usr;$nice;$sys;$iowait;$soft;$date_time" >>logs/monitoring-cpu.csv
