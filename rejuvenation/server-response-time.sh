#!/bin/bash

# usage ./remoteServiceResponse.sh 192.168.0.109 8080 6
# Define a ADDRESS do servidor
ADDRESS=$1
PORT=$2
LIMIT=${3:-0}
#LIMIT é o tempo de resposta médio máximo aceitável

# Cria o cabeçalho do arquivo CSV
echo "date_time;response_time" >response_times.csv
echo "reset_date_time" >reset_times.csv

ITEMS=(0 0 0 0 0 0)
count=0

function media_array {
  local soma=0
  local num_elementos="${#ITEMS[@]}"

  # itera sobre os valores do array e soma os valores
  for valor in "${ITEMS[@]}"; do
    soma=$(echo "$soma + $valor" | bc -l)
  done
  # calcula a média
  media=$(echo "$soma / $num_elementos" | bc -l)

  # arredonda a média para o inteiro mais próximo
  media_arredondada=$(echo "($media + 0.5) / 1" | bc)
  echo "$media_arredondada"
}

# Loop infinito para medir o tempo de resposta
while true; do
  # Captura o timestamp atual
  timestamp=$(date +%d-%m-%Y-%H:%M:%S)

  # Faz a requisição HTTP e captura o tempo de resposta
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

    media=$(media_array "${ITEMS[@]}")

    if [ "$media" -ge "$LIMIT" ]; then
      ssh "root@$PORT" "ssh -p 2222 root@localhost "/sbin/shutdown -r now" > /dev/null 2>&1" >/dev/null 2>&1
      echo "$timestamp" >>reset_times.csv
    fi

    count=$((count + 1))
  fi

  # Adiciona o timestamp e o tempo de resposta ao arquivo CSV
  echo "$timestamp;$response_time" >>response_times.csv

  # Espera 1 segundos antes de fazer a próxima requisição
  sleep 1
done
