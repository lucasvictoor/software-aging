#!/bin/bash

# usage ./remoteServiceResponse.sh 192.168.0.109 8080 6
# Define the server ADDRESS
ADDRESS=$1
PORT=$2
LIMIT=${3:-0}
# LIMIT is the maximum acceptable average response time

# Create the CSV file header
echo "date_time;response_time" >response_times.csv
echo "reset_date_time" >reset_times.csv

ITEMS=(0 0 0 0 0 0)
count=0

function calculate_array_mean {
  local sum=0
  local num_elements="${#ITEMS[@]}"

  # Iterate over the array values and sum them
  for value in "${ITEMS[@]}"; do
    sum=$(echo "$sum + $value" | bc -l)
  done
  # Calculate the mean
  mean=$(echo "$sum / $num_elements" | bc -l)

  # Round the mean to the nearest integer
  rounded_mean=$(echo "($mean + 0.5) / 1" | bc)
  echo "$rounded_mean"
}

# Infinite loop to measure response time
while true; do
  # Capture the current timestamp
  timestamp=$(date +%d-%m-%Y-%H:%M:%S)

  # Make the HTTP request and capture the response time
  response=$(curl -w "%{http_code}  %{time_total}" -o /dev/null -s "http://$ADDRESS:$PORT")
  code=$(echo "$response" | awk '{print $1}')
  response_time=$(echo "$response" | awk '{print $2}')

  if [ ! "$code" -eq 200 ]; then
    response_time="-1"
  fi

  if [ "$LIMIT" -gt 0 ]; then
    if [ "$count" -ge ${#ITEMS[@]} ]; then
      count=0
    fi

    ITEMS[$count]=$response_time
    echo "${ITEMS[@]}"

    mean=$(calculate_array_mean "${ITEMS[@]}")

    if [ "$mean" -ge "$LIMIT" ]; then
      ssh "root@$PORT" "ssh -p 2222 root@localhost "/sbin/shutdown -r now" > /dev/null 2>&1" >/dev/null 2>&1
      echo "$timestamp" >>reset_times.csv
    fi

    count=$((count + 1))
  fi

  # Add the timestamp and response time to the CSV file
  echo "$timestamp;$response_time" >>response_times.csv

  # Wait for 1 second before making the next request
  sleep 1
done
