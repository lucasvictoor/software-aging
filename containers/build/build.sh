#!/bin/bash

# Caminho para o Dockerfile
DOCKERFILE_PATH="./Dockerfile"

# Loop para criar imagens com tamanhos específicos
while true; do
    # Perguntar ao usuário pelo tamanho desejado
    read -p "Informe o tamanho desejado para a imagem em MB: " SIZE

    # Perguntar ao usuário pelo tamanho desejado
    read -p "Informe o tamanho (label) para a imagem: " SIZE_LABEL

    # Construir a imagem
    IMAGE_NAME="nginx-${SIZE_LABEL}"
    podman build -t "$IMAGE_NAME" --build-arg SIZE_MB="$SIZE" -f $DOCKERFILE_PATH .

    podman image ls -a

    # Perguntar ao usuário se a imagem tem o tamanho esperado
    read -p "A imagem está com o tamanho esperado? (s/n): " CONFIRM

    # Se a imagem tem o tamanho esperado, mover para o próximo tamanho
    if [[ $CONFIRM == "s" ]]; then
        podman save -o "$IMAGE_NAME.tar" "$IMAGE_NAME"
        echo "Agora construa a próxima imagem"
    else
        echo "Apagando a imagem ${IMAGE_NAME}..."
    fi
    podman rmi -f "$IMAGE_NAME"
done

echo "Processo concluído."
