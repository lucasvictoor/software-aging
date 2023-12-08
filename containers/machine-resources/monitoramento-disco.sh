#!/bin/bash

disco=$(df | grep /dev/sda1)
usado=$(echo $disco | awk '{print $3}')
disc_data1=$(iostat -d | grep sda)
sleep 1
disc_data2=$(iostat -d | grep sda)
kB_read1=$(echo $disc_data1 | awk '{print $6}')
kB_read2=$(echo $disc_data2 | awk '{print $6}')
kB_wrtn1=$(echo $disc_data1 | awk '{print $7}')
kB_wrtn2=$(echo $disc_data2 | awk '{print $7}')

kB_read=$(($kB_read1 - $kB_read2))
kB_wrtn=$(($kB_wrtn1 - $kB_wrtn2))

echo "$usado;$kB_read;$kB_wrtn;$iteration;$date_time" >>logs/monitoramento-disco.csv