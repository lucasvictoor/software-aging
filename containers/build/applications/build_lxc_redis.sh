#!/bin/bash

IMAGE_FILE="debian12-20231228"
MAPPING_PORT="6379"

# Loop para criar imagens com tamanhos específicos
while true; do
  # Perguntar ao usuário pelo tamanho desejado
  read -p "Informe o tamanho desejado para a imagem em MB: " SIZE

  # Perguntar ao usuário pelo tamanho desejado
  read -p "Informe o tamanho (label) para a imagem: " SIZE_LABEL

  # Construir a imagem
  IMAGE_NAME="redis-${SIZE_LABEL}-temp"
  REAL_NAME="redis-${SIZE_LABEL}"
  lxc image import "$IMAGE_FILE.tar" "$IMAGE_FILE.tar.root" --alias "$IMAGE_NAME"
  lxc launch "$IMAGE_NAME" "$IMAGE_NAME"

  #Instalação do nginx
  lxc exec "$IMAGE_NAME" -- bash -c "apt update && apt install -y lsb-release curl gpg && \
                                         curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
                                         # shellcheck disable=SC2046
                                         echo deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main | sudo tee /etc/apt/sources.list.d/redis.list && \
                                         apt update"
  lxc exec "$IMAGE_NAME" -- bash -c "apt install -y redis-server"
  lxc exec "$IMAGE_NAME" -- bash -c "systemctl stop redis-server"
  lxc exec "$IMAGE_NAME" -- bash -c "systemctl disable redis-server"
  lxc exec "$IMAGE_NAME" -- bash -c "sudo update-rc.d redis-server disable"

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

echo "Processo concluído. para "
