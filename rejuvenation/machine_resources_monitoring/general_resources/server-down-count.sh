#!/bin/bash

started_at=0
is_offline=0
down_count=0

while true; do
  if [ "$is_offline" -eq 0 ]; then
    started_at=$(date +%s)
  fi

  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)

  if [ "$response" -eq 200 ]; then
    if [ "$is_offline" -eq 1 ]; then
      date_time=$(date +%d-%m-%Y-%H:%M:%S)
      end_time=$(date +%s)
      offline_time=$((end_time - started_at))
      ((down_count++))
      echo "$down_count;$offline_time;$date_time" >>logs/server_status.csv
      is_offline=0
    fi
  else
    is_offline=1
  fi
  sleep 1
done
