#!/bin/bash

# Função de monitoramento
monitor_service() {
    #Obter a data atual
    start=$(date +%s%N)

    until pgrep -x "nginx" > /dev/null; do
        sleep 1
    done

    # Calcular o tempo total e salvar no arquivo /root/log.txt
    end=$(date +%s%N)
    total=$((end - start))
    echo "$total" > /root/log.txt
}

# Chamar a função de monitoramento em segundo plano
monitor_service &

# Executar o comando para iniciar o nginx em primeiro plano
nginx -g "daemon off;"
