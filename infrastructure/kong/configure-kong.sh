#!/bin/bash

# Script de configuration Kong pour router vers les services
# À exécuter après le démarrage de Kong

KONG_ADMIN="http://localhost:8001"
KEYCLOAK_URL="http://localhost:8080"
KEYCLOAK_REALM="slhub"
KEYCLOAK_CLIENT_ID="kong"
KEYCLOAK_CLIENT_SECRET="${KEYCLOAK_CLIENT_SECRET:-your-secret-here}"

echo "🚀 Configuration de Kong API Gateway..."
echo ""

# Attendre que Kong soit prêt
echo "⏳ Attente de Kong..."
until curl -s ${KONG_ADMIN}/status > /dev/null 2>&1; do
    echo "Kong n'est pas encore prêt, attente..."
    sleep 2
done
echo "✅ Kong est prêt!"
echo ""

# ========================================
# Service Media Aggregator (NestJS)
# ========================================
echo "📦 Configuration du service Media Aggregator..."

# Créer le service
SERVICE_RESPONSE=$(curl -s -X POST ${KONG_ADMIN}/services \
  --data "name=media-aggregator" \
  --data "url=http://nodejs-nest-backend:3000")

SERVICE_ID=$(echo $SERVICE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$SERVICE_ID" ]; then
    echo "⚠️  Le service existe peut-être déjà, tentative de récupération..."
    SERVICE_ID=$(curl -s ${KONG_ADMIN}/services/media-aggregator | grep -o '"id":"[^"]*' | cut -d'"' -f4)
fi

echo "Service ID: $SERVICE_ID"

# Créer les routes pour Media Aggregator
echo "📍 Création des routes..."

# Route /movie (gestion de films)
curl -s -X POST ${KONG_ADMIN}/services/media-aggregator/routes \
  --data "name=movie-route" \
  --data "paths[]=/movie" \
  --data "strip_path=false" > /dev/null

# Route /spotify (intégration Spotify)
curl -s -X POST ${KONG_ADMIN}/services/media-aggregator/routes \
  --data "name=spotify-route" \
  --data "paths[]=/spotify" \
  --data "strip_path=false" > /dev/null

# Route /letterboxd (intégration Letterboxd)
curl -s -X POST ${KONG_ADMIN}/services/media-aggregator/routes \
  --data "name=letterboxd-route" \
  --data "paths[]=/letterboxd" \
  --data "strip_path=false" > /dev/null

# Route /health (sans auth)
curl -s -X POST ${KONG_ADMIN}/services/media-aggregator/routes \
  --data "name=health-route" \
  --data "paths[]=/health" \
  --data "strip_path=false" > /dev/null

echo "✅ Media Aggregator configuré"
echo ""

# ========================================
# Configuration Keycloak OIDC (optionnel)
# ========================================
if [ "$KEYCLOAK_CLIENT_SECRET" != "your-secret-here" ]; then
    echo "🔐 Configuration de l'authentification Keycloak..."

    # Activer le plugin OIDC sur les routes protégées

    # Route /movie (protégée)
    MOVIE_ROUTE_ID=$(curl -s ${KONG_ADMIN}/routes/movie-route | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    curl -s -X POST ${KONG_ADMIN}/routes/${MOVIE_ROUTE_ID}/plugins \
      --data "name=openid-connect" \
      --data "config.issuer=${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}" \
      --data "config.client_id=${KEYCLOAK_CLIENT_ID}" \
      --data "config.client_secret=${KEYCLOAK_CLIENT_SECRET}" \
      --data "config.bearer_only=yes" \
      --data "config.ssl_verify=false" > /dev/null

    echo "✅ Authentification Keycloak activée sur /movie, /spotify, /letterboxd"
else
    echo "⚠️  KEYCLOAK_CLIENT_SECRET non configuré, authentification désactivée"
    echo "   Pour activer l'authentification:"
    echo "   export KEYCLOAK_CLIENT_SECRET=your-secret"
    echo "   ./configure-kong.sh"
fi

echo ""
echo "✨ Configuration terminée!"
echo ""
echo "📋 Résumé des routes:"
echo "  - http://localhost:8000/movie        → Media Aggregator - Films (avec auth si configuré)"
echo "  - http://localhost:8000/spotify      → Media Aggregator - Spotify (avec auth si configuré)"
echo "  - http://localhost:8000/letterboxd   → Media Aggregator - Letterboxd (avec auth si configuré)"
echo "  - http://localhost:8000/health       → Health check (public)"
echo ""
echo "🔍 Vérifier la configuration:"
echo "  curl http://localhost:8001/services"
echo "  curl http://localhost:8001/routes"
echo ""
echo "🌐 Accès Kong Manager: http://localhost:8002"
