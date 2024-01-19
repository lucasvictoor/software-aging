#!/bin/bash

# Script to monitor the disk usage of the host machine and log used space and date time in a CSV file

disk=$( df | grep '/$' )
used=$(echo $disk | awk '{print $3}')

echo "$used;$date_time" >>logs/machine_monitoring-disk.csv