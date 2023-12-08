num=$(ps aux | awk '{if ($8~"Z"){print $0}}' | wc -l)

echo "$num;$iteration;$date_time" >>logs/monitoramento-zumbis.csv
