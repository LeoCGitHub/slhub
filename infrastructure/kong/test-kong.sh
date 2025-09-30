#!/bin/bash

# Script de test de la configuration Kong

KONG_PROXY="http://localhost:8000"
KONG_ADMIN="http://localhost:8001"

echo "🧪 Test de la configuration Kong"
echo ""

# Test 1: Kong est accessible
echo "1️⃣  Test: Kong Admin API accessible..."
if curl -s ${KONG_ADMIN}/status > /dev/null 2>&1; then
    echo "   ✅ Kong Admin API OK"
else
    echo "   ❌ Kong Admin API non accessible"
    exit 1
fi

# Test 2: Lister les services
echo ""
echo "2️⃣  Services configurés:"
curl -s ${KONG_ADMIN}/services | grep -o '"name":"[^"]*' | cut -d'"' -f4 | sed 's/^/   - /'

# Test 3: Lister les routes
echo ""
echo "3️⃣  Routes configurées:"
curl -s ${KONG_ADMIN}/routes | grep -o '"name":"[^"]*' | cut -d'"' -f4 | sed 's/^/   - /'

# Test 4: Test de la route /health
echo ""
echo "4️⃣  Test: Route /health..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${KONG_PROXY}/health)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "503" ]; then
    echo "   ✅ Route /health accessible (HTTP $HTTP_CODE)"
else
    echo "   ⚠️  Route /health retourne HTTP $HTTP_CODE"
fi

# Test 5: Test de la route /api
echo ""
echo "5️⃣  Test: Route /api..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${KONG_PROXY}/api)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "   ✅ Route /api accessible (HTTP $HTTP_CODE)"
    if [ "$HTTP_CODE" = "401" ]; then
        echo "      ℹ️  Authentification requise (normal si Keycloak configuré)"
    fi
else
    echo "   ⚠️  Route /api retourne HTTP $HTTP_CODE"
fi

# Test 6: Plugins actifs
echo ""
echo "6️⃣  Plugins actifs:"
PLUGINS=$(curl -s ${KONG_ADMIN}/plugins | grep -o '"name":"[^"]*' | cut -d'"' -f4)
if [ -z "$PLUGINS" ]; then
    echo "   ℹ️  Aucun plugin actif"
else
    echo "$PLUGINS" | sed 's/^/   - /'
fi

echo ""
echo "✨ Tests terminés!"
echo ""
echo "🌐 Accès:"
echo "  - Kong Proxy: ${KONG_PROXY}"
echo "  - Kong Manager: http://localhost:8002"
echo "  - Kong Admin API: ${KONG_ADMIN}"
