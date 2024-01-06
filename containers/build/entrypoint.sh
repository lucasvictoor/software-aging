#!/bin/bash

# Função de monitoramento
monitor_service() {
  #Obter a data atual
  start=$(date +%s%N)

  #nginx pgrep -x "nginx"
  #redis pgrep -f "redis-server"
  #rabbitmq pgrep -f "rabbitmq-server"

  until pgrep -f "rabbitmq-server" >/dev/null; do
    echo ""
  done

  # Calcular o tempo total e salvar no arquivo /root/log.txt
  end=$(date +%s%N)
  total=$((end - start))
  echo "$total" >/root/log.txt
}

# Chamar a função de monitoramento em segundo plano
monitor_service &

# Executar o comando para iniciar o nginx em primeiro plano
#/usr/lib/rabbitmq/bin/rabbitmq-server
nginx -g "daemon off;"
