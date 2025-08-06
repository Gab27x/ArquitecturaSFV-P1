#!/bin/bash

# Nombre de la imagen y contenedor
IMAGE_NAME="taller-softwarev"
CONTAINER_NAME="taller-softwarev-container"
PORT=8080

echo "Verificando si Docker está instalado..."

if ! command -v docker &> /dev/null; then
  echo "Docker no está instalado. Instálalo antes de continuar."
  exit 1
fi

echo "Docker está instalado."

# Construir la imagen
echo "Construyendo la imagen Docker..."
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
  echo "Error al construir la imagen."
  exit 1
fi

# Eliminar contenedor anterior si existe
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "Eliminando contenedor existente..."
  docker rm -f $CONTAINER_NAME > /dev/null
fi

# Ejecutar el contenedor
echo "Ejecutando el contenedor en el puerto $PORT..."
docker run -d --name $CONTAINER_NAME -p $PORT:3000 \
  $IMAGE_NAME

sleep 3

# Probar si el servicio responde
echo "Probando si el servicio responde en http://localhost:$PORT/..."

if curl --fail --silent http://localhost:$PORT/ > /dev/null; then
  echo "Servicio activo y respondiendo correctamente en el puerto $PORT."
  exit 0
else
  echo "El servicio no respondió. Verifica los logs del contenedor:"
  docker logs $CONTAINER_NAME
  exit 1
fi

