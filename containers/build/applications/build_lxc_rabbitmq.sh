#!/bin/bash

IMAGE_FILE="debian12-20231228"
MAPPING_PORT="5672"

# Loop para criar imagens com tamanhos específicos
while true; do
    # Perguntar ao usuário pelo tamanho desejado
    read -p "Informe o tamanho desejado para a imagem em MB: " SIZE

    # Perguntar ao usuário pelo tamanho desejado
    read -p "Informe o tamanho (label) para a imagem: " SIZE_LABEL

    # Construir a imagem
    IMAGE_NAME="rabbitmq-${SIZE_LABEL}-temp"
    REAL_NAME="rabbitmq-${SIZE_LABEL}"
    lxc image import "$IMAGE_FILE.tar" "$IMAGE_FILE.tar.root" --alias "$IMAGE_NAME"
    lxc launch "$IMAGE_NAME" "$IMAGE_NAME"


    lxc exec "$IMAGE_NAME" -- bash -c "echo deb http://security.debian.org/debian-security buster/updates main | sudo tee -a /etc/apt/sources.list"
    lxc exec "$IMAGE_NAME" -- bash -c "sudo apt-get update && sudo apt-get install -y curl gnupg procps apt-transport-https libssl1.1"
    lxc exec "$IMAGE_NAME" -- bash -c "curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null"
    lxc exec "$IMAGE_NAME" -- bash -c "curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null"
    lxc exec "$IMAGE_NAME" -- bash -c "curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null"
    lxc file push "rabbitmq.list" "$IMAGE_NAME/etc/apt/sources.list.d/"
    lxc exec "$IMAGE_NAME" -- bash -c "sudo apt-get update && sudo apt-get install -y erlang-base \
                                                                                           erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                                                                                           erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                                                                                           erlang-runtime-tools erlang-snmp erlang-ssl \
                                                                                           erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl"
    lxc exec "$IMAGE_NAME" -- bash -c "sudo apt-get install -y rabbitmq-server -y --fix-missing"
    lxc exec "$IMAGE_NAME" -- bash -c " systemctl stop rabbitmq-server"
    lxc exec "$IMAGE_NAME" -- bash -c " systemctl disable rabbitmq-server"
    lxc file push "rabbitmq.conf" "$IMAGE_NAME/etc/rabbitmq/"


    #Configuração do entrypoint
    lxc file push "entrypoint.sh" "$IMAGE_NAME/root/"
    lxc file push "entrypoint.service" "$IMAGE_NAME/etc/systemd/system/"
    lxc exec "$IMAGE_NAME" -- bash -c "chmod a+wrx /root/entrypoint.sh"
    lxc exec "$IMAGE_NAME" -- bash -c "systemctl enable /etc/systemd/system/entrypoint.service"
    lxc exec "$IMAGE_NAME" -- bash -c "systemctl daemon-reload"
    lxc exec "$IMAGE_NAME" -- bash -c "systemctl start entrypoint.service"
    lxc exec "$IMAGE_NAME" -- bash -c "systemctl status entrypoint.service"

    #Geração do arquivo aleatório
    lxc exec "$IMAGE_NAME" -- bash -c "dd if=/dev/urandom of=/root/random_file.bin bs=1M count=${SIZE}"

    #Exposição da porta
    lxc config device add "$IMAGE_NAME" myport$MAPPING_PORT proxy listen=tcp:0.0.0.0:$MAPPING_PORT connect=tcp:127.0.0.1:$MAPPING_PORT

    #Exibir tamanho da imagem
    lxc stop "$IMAGE_NAME"
    lxc publish "$IMAGE_NAME" --alias "$REAL_NAME"
    lxc image list

    # Perguntar ao usuário se a imagem tem o tamanho esperado
    read -p "A imagem está com o tamanho esperado? (s/n): " CONFIRM

    # Se a imagem tem o tamanho esperado, mover para o próximo tamanho
    if [[ $CONFIRM == "s" ]]; then
        lxc image export "$REAL_NAME" "$REAL_NAME"
        echo "Agora construa a próxima imagem"
    else
        echo "Apagando a imagem ${IMAGE_NAME}..."
    fi
    lxc delete --force "$IMAGE_NAME"
    lxc image delete "$IMAGE_NAME"
    lxc image delete "$REAL_NAME"
done

echo "Processo concluído."
