# SLHub - Hub Microservices

Hub centralisé pour architecture microservices avec Kong API Gateway, Keycloak, monitoring et services backend.

## 📖 Documentation Architecture

La documentation complète de l'architecture est disponible dans [docs/architecture/](docs/architecture/) :

- **[Architecture Globale](docs/architecture/01-architecture-globale.md)** - Vue d'ensemble complète
- **[Flux d'Authentification](docs/architecture/02-flux-authentification.md)** - OAuth2/OIDC avec Keycloak
- **[Réseau Docker](docs/architecture/03-reseau-docker.md)** - Topologie et communication inter-services

## 🏗️ Microservices

### Convention de nommage

Les repositories de microservices suivent une **nomenclature métier** :
- ✅ `user-service` (gestion utilisateurs)
- ✅ `product-catalog` (catalogue produits)
- ✅ `order-management` (gestion commandes)
- ❌ `nestjs-users` (éviter le nom de la techno)

La stack technique est documentée dans le README de chaque service.

### Services actuels

| Service | Stack | Description | Port | Repo |
|---------|-------|-------------|------|------|
| user-service | NestJS + PostgreSQL | Gestion utilisateurs et auth | 3000 | [Lien](#) |
| front-angular | Angular | Interface principale | 4200 | [Lien](#) |

### Ajouter un nouveau microservice

Suivez le guide complet : **[docs/AJOUTER_MICROSERVICE.md](docs/AJOUTER_MICROSERVICE.md)**

Ressources disponibles :
- **[Template README](docs/templates/MICROSERVICE_README_TEMPLATE.md)** - À copier pour chaque nouveau service
- **[Guide d'intégration](docs/AJOUTER_MICROSERVICE.md)** - Étapes complètes pour créer et intégrer un service


TODO LIST
Gestion d'identité et sécuritéchekc
[x] Keycloak : solution open-source de gestion d'identité et d'accès, compatible OAuth2/OpenID Connect, facile à intégrer comme serveur d'authentification centralisé.

Check https://github.com/ferriskey/ferriskey

API Gateway
[] Spring Cloud Gateway (Java/Spring) : flexible, performant, intégration native avec Keycloak via OAuth2

[] Kong ou Traefik : gateways cloud-native, supportent l’authentification Keycloak

Microservices REST
[] Spring Boot (Java) : framework mature pour créer des microservices robustes et sécurisés

[] Quarkus ou Micronaut (Java) : frameworks modernes et légers, adaptés au cloud

[] Node.js + Express/Koa : si besoin de JavaScript/TypeScript

Messaging asynchrone
[] RabbitMQ : système de queues fiable, facile à intégrer

[] Apache Kafka : plateforme de streaming distribuée très scalable, idéale pour gros volumes

[] ActiveMQ : autre système de gestion de message éprouvé

Découverte et monitoring
[] Consul ou Eureka : service discovery et configuration centralisée

[] Prometheus + Grafana : monitoring métriques et visualisation

Autres
[] Docker + Kubernetes : pour containerisation, orchestration et scalabilité

[] PostgreSQL / MongoDB : bases de données relationnelles ou NoSQL selon besoins métier

En résumé, une stack typique Java/Spring avec Keycloak, Spring Cloud Gateway, RabbitMQ/Kafka, containers Docker/K8s offre un socle solide, flexible, et maintenable pour un hub microservices sécurisé.

## Gestion Docker Compose

### Démarrer tous les services
```bash
./up.sh
# ou directement
docker compose up -d
```

### Arrêter tous les services
```bash
./down.sh
# ou directement
docker compose down
```

### Commandes utiles
```bash
# Voir les logs de tous les services
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f keycloak

# Redémarrer un service
docker compose restart keycloak

# Lister les services actifs
docker compose ps

# Reconstruire et redémarrer
docker compose up -d --build
```

### Architecture
Le fichier [docker-compose.yml](docker-compose.yml) principal utilise `include:` pour référencer tous les modules :

**Infrastructure :**
- Kong API Gateway (point d'entrée unique) - Port 8000
- Keycloak (authentification) - Port 8080
- Prometheus + Grafana (monitoring)

**Bases de données :**
- PostgreSQL et MongoDB

**Services :**
- Backend Node.js/NestJS
- Frontends Angular et React (commentés)

Tous les services partagent le réseau `lcg-solutions`.

### Kong API Gateway
Kong est le point d'entrée unique de votre architecture. Les clients accèdent aux services via Kong qui gère :
- Authentification avec Keycloak (OIDC)
- Routing vers les microservices
- Rate limiting, logging, etc.

**Accès :**
- API Proxy : http://localhost:8000
- Kong Manager (UI) : http://localhost:8002
- Admin API : http://localhost:8001

Pour plus de détails, voir [infrastructure/kong/README.md](infrastructure/kong/README.md)

---