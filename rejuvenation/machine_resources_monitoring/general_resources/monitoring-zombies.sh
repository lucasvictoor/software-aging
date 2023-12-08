num=$(ps aux | awk '{if ($8~"Z"){print $0}}' | wc -l)

echo "$num;$date_time" >>logs/monitoring-zombies.csv