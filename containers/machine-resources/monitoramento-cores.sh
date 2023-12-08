#!/bin/bash

frequencies=$(cat /proc/cpuinfo | grep MHz | awk '{print $4}')
core=0
for frequency in $frequencies; do
    echo "$frequency;$date_time" >> logs/"core_$core.csv"
    ((core++))
done


