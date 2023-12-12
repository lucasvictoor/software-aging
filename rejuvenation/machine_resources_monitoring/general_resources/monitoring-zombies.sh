#!/bin/bash

# Script to monitor the number of zombie processes and log the count to a CSV file

num=$(ps aux | awk '{if ($8~"Z"){print $0}}' | wc -l)

echo "$num;$date_time" >>logs/monitoring-zombies.csv