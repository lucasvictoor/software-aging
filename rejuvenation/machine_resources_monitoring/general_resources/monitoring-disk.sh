#!/bin/bash

disk=$(df | grep /dev/nvme0n1p5)
used=$(echo $disk | awk '{print $3}')

echo "$used;$date_time" >>logs/monitoring-disk.csv