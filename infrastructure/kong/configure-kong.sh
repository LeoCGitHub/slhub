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
# Service Backend NestJS
# ========================================
echo "📦 Configuration du service Backend NestJS..."

# Créer le service
SERVICE_RESPONSE=$(curl -s -X POST ${KONG_ADMIN}/services \
  --data "name=backend-nestjs" \
  --data "url=http://nodejs-nest-backend:3000")

SERVICE_ID=$(echo $SERVICE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$SERVICE_ID" ]; then
    echo "⚠️  Le service existe peut-être déjà, tentative de récupération..."
    SERVICE_ID=$(curl -s ${KONG_ADMIN}/services/backend-nestjs | grep -o '"id":"[^"]*' | cut -d'"' -f4)
fi

echo "Service ID: $SERVICE_ID"

# Créer la route pour /api
echo "📍 Création de la route /api..."
curl -s -X POST ${KONG_ADMIN}/services/backend-nestjs/routes \
  --data "name=api-route" \
  --data "paths[]=/api" \
  --data "strip_path=false" > /dev/null

# Créer la route pour /health (sans auth)
echo "📍 Création de la route /health (publique)..."
curl -s -X POST ${KONG_ADMIN}/services/backend-nestjs/routes \
  --data "name=health-route" \
  --data "paths[]=/health" \
  --data "strip_path=false" > /dev/null

echo "✅ Backend NestJS configuré"
echo ""

# ========================================
# Configuration Keycloak OIDC (optionnel)
# ========================================
if [ "$KEYCLOAK_CLIENT_SECRET" != "your-secret-here" ]; then
    echo "🔐 Configuration de l'authentification Keycloak..."

    # Récupérer l'ID de la route API
    ROUTE_ID=$(curl -s ${KONG_ADMIN}/routes/api-route | grep -o '"id":"[^"]*' | cut -d'"' -f4)

    # Activer le plugin OIDC sur la route /api
    curl -s -X POST ${KONG_ADMIN}/routes/${ROUTE_ID}/plugins \
      --data "name=openid-connect" \
      --data "config.issuer=${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}" \
      --data "config.client_id=${KEYCLOAK_CLIENT_ID}" \
      --data "config.client_secret=${KEYCLOAK_CLIENT_SECRET}" \
      --data "config.bearer_only=yes" \
      --data "config.ssl_verify=false" > /dev/null

    echo "✅ Authentification Keycloak activée sur /api"
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
echo "  - http://localhost:8000/api      → Backend NestJS (avec auth si configuré)"
echo "  - http://localhost:8000/health   → Health check (public)"
echo ""
echo "🔍 Vérifier la configuration:"
echo "  curl http://localhost:8001/services"
echo "  curl http://localhost:8001/routes"
echo ""
echo "🌐 Accès Kong Manager: http://localhost:8002"
