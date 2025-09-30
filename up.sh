#!/bin/bash

# Création du réseau partagé si nécessaire
docker network create lcg-solutions 2>/dev/null || true

# Lancement de tous les modules via le docker-compose principal
docker compose up -d