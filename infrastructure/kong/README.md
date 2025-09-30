# Kong API Gateway

Kong est configuré comme API Gateway pour l'ensemble de la solution slhub.

## Accès

- **Proxy API** : http://localhost:8000 (point d'entrée principal)
- **Admin API** : http://localhost:8001
- **Kong Manager (UI)** : http://localhost:8002

## Configuration rapide

### 1. Démarrer les services

```bash
cd /home/lcg/workspaces/slhub
./up.sh
```

### 2. Configurer les routes Kong

```bash
# Configuration de base (sans authentification)
./infrastructure/kong/configure-kong.sh

# Avec authentification Keycloak (après avoir créé le client dans Keycloak)
export KEYCLOAK_CLIENT_SECRET=your-secret-from-keycloak
./infrastructure/kong/configure-kong.sh
```

### 3. Tester la configuration

```bash
./infrastructure/kong/test-kong.sh
```

## Routes configurées automatiquement

Le script de configuration crée automatiquement :

- **`/api`** → Backend NestJS (avec auth Keycloak si configuré)
- **`/health`** → Health check (public, sans auth)

Accès via Kong :
- `http://localhost:8000/api` (au lieu de `http://localhost:3000/api`)
- `http://localhost:8000/health`

## Configuration Keycloak requise

1. Créer un client `kong` dans Keycloak
2. Type de client : `confidential`
3. Valid Redirect URIs : `http://localhost:8000/*`
4. Récupérer le client secret

## Variables d'environnement

Créer un fichier `.env` à la racine :

```env
KONG_DB_PASSWORD=kongpass
```

## Architecture des routes recommandée

```
http://localhost:8000/api/users      → Backend NestJS
http://localhost:8000/api/products   → Backend NestJS
http://localhost:8000/monitoring     → Grafana
http://localhost:8000/auth           → Keycloak (si besoin)
```

## Commandes utiles

```bash
# Lister les services
curl http://localhost:8001/services

# Lister les routes
curl http://localhost:8001/routes

# Lister les plugins
curl http://localhost:8001/plugins

# Vérifier la santé
curl http://localhost:8001/status
```

## Documentation

- [Kong Gateway Documentation](https://docs.konghq.com/gateway/latest/)
- [OpenID Connect Plugin](https://docs.konghq.com/hub/kong-inc/openid-connect/)
