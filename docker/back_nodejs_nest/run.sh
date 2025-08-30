#!/bin/bash

usage() {
    echo "Usage: $0 [-d]"
    echo "  -d    Lance l'application en mode debug"
    exit 1
}

# Initialisation de la variable debug
DEBUG=false

# Traitement des options
while getopts ":d" opt; do
  case ${opt} in
    d )
      DEBUG=true
      ;;
    \? )
      usage
      ;;
  esac
done

# Configuration du docker-compose file
COMPOSE_FILE="-f docker-compose.yml"

# Si le mode debug est activé, utiliser le fichier docker-compose.debug.yml
if [ "$DEBUG" = true ] ; then
    COMPOSE_FILE="-f docker-compose.yml -f docker-compose.debug.yml"
    echo "Lancement en mode debug..."
else
    echo "Lancement en mode normal..."
fi

# Lancement de docker-compose avec le fichier approprié
docker-compose $COMPOSE_FILE up -d