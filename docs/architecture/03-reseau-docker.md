# Réseau Docker - SLHub

## Vue d'ensemble

Tous les services SLHub partagent un réseau Docker bridge nommé `lcg-solutions` pour communiquer entre eux.

## Topologie réseau

```mermaid
graph TB
    subgraph "Réseau Docker: lcg-solutions"
        subgraph "Infrastructure"
            Kong[kong-gateway<br/>kong-database<br/>kong-migration]
            Keycloak[keycloak<br/>keycloak-postgresql-16]
            Monitoring[prometheus<br/>grafana]
        end

        subgraph "Services Backend"
            NestJS[nodejs-nest-backend]
        end

        subgraph "Bases de données"
            PostgreSQL[postgresql]
            MongoDB[mongodb]
        end

        Kong <--> Keycloak
        Kong <--> NestJS
        NestJS <--> PostgreSQL
        NestJS <--> MongoDB
        NestJS <--> Keycloak

        Monitoring -.-> Kong
        Monitoring -.-> Keycloak
        Monitoring -.-> NestJS
    end

    subgraph "Host Network"
        Host[Machine hôte<br/>localhost]
    end

    Host -->|Port 8000-8002| Kong
    Host -->|Port 8080| Keycloak
    Host -->|Port 3000| NestJS
    Host -->|Port 3001| Monitoring
    Host -->|Port 5432| PostgreSQL
    Host -->|Port 27017| MongoDB

    classDef infrastructure fill:#e1f5ff,stroke:#01579b
    classDef service fill:#f3e5f5,stroke:#4a148c
    classDef database fill:#fff3e0,stroke:#e65100
    classDef host fill:#fce4ec,stroke:#880e4f

    class Kong,Keycloak,Monitoring infrastructure
    class NestJS service
    class PostgreSQL,MongoDB database
    class Host host
```

## Réseau lcg-solutions

### Configuration

```yaml
networks:
  lcg-solutions:
    name: lcg-solutions
    driver: bridge
    external: true
```

### Caractéristiques

- **Type** : Bridge
- **Nom** : lcg-solutions
- **Externe** : true (créé manuellement avant le démarrage)
- **DNS interne** : Les conteneurs se résolvent par leur nom

### Création du réseau

```bash
docker network create lcg-solutions
```

Le script `up.sh` crée automatiquement ce réseau s'il n'existe pas.

## Communication inter-services

### Résolution DNS

Chaque conteneur peut joindre les autres par leur nom de service :

```mermaid
graph LR
    A[Kong] -->|http://nodejs-nest-backend:3000| B[Backend NestJS]
    A -->|http://keycloak:8080| C[Keycloak]
    B -->|postgresql:5432| D[PostgreSQL]
    B -->|mongodb:27017| E[MongoDB]
    C -->|keycloak-postgresql-16:5432| F[Keycloak DB]
```

### Exemples de connexion

#### Kong → Backend NestJS
```bash
# Dans Kong
Service URL: http://nodejs-nest-backend:3000
```

#### Backend NestJS → PostgreSQL
```bash
# Dans NestJS config
DB_HOST=postgresql
DB_PORT=5432
```

#### Backend NestJS → MongoDB
```bash
# Dans NestJS config
MONGO_URI=mongodb://mongodb:27017/mydb
```

#### Kong/NestJS → Keycloak
```bash
# URLs Keycloak
KEYCLOAK_URL=http://keycloak:8080
ISSUER=http://keycloak:8080/realms/slhub
```

## Exposition des ports

### Ports mappés (Host → Container)

```mermaid
graph LR
    subgraph "localhost (Host)"
        H8000[":8000"]
        H8001[":8001"]
        H8002[":8002"]
        H8080[":8080"]
        H3000[":3000"]
        H5432[":5432"]
        H27017[":27017"]
    end

    subgraph "lcg-solutions network"
        K8000["kong:8000"]
        K8001["kong:8001"]
        K8002["kong:8002"]
        KC8080["keycloak:8080"]
        N3000["nestjs:3000"]
        P5432["postgresql:5432"]
        M27017["mongodb:27017"]
    end

    H8000 -.->|mapping| K8000
    H8001 -.->|mapping| K8001
    H8002 -.->|mapping| K8002
    H8080 -.->|mapping| KC8080
    H3000 -.->|mapping| N3000
    H5432 -.->|mapping| P5432
    H27017 -.->|mapping| M27017
```

### Tableau des ports

| Service | Port interne | Port externe | Usage |
|---------|--------------|--------------|-------|
| Kong Gateway | 8000 | 8000 | API Proxy HTTP |
| Kong Gateway | 8443 | 8443 | API Proxy HTTPS |
| Kong Admin | 8001 | 8001 | Admin API |
| Kong Manager | 8002 | 8002 | Interface Web |
| Keycloak | 8080 | 8080 | Console & API |
| Backend NestJS | 3000 | 3000 | API REST |
| PostgreSQL (App) | 5432 | 5432 | Base de données |
| PostgreSQL (Keycloak) | 5432 | 5433 | Base Keycloak |
| MongoDB | 27017 | 27017 | Base NoSQL |
| Grafana | 3000 | 3001 | Dashboard |
| Prometheus | 9090 | 9090 | Métriques |

## Isolation et sécurité

### Communication interne uniquement

Certains services ne devraient communiquer qu'en interne :

```mermaid
graph TB
    subgraph "Accessible depuis l'extérieur"
        Kong[Kong :8000-8002]
        Keycloak[Keycloak :8080]
        Grafana[Grafana :3001]
    end

    subgraph "Interne uniquement (dev expose pour debug)"
        NestJS[NestJS :3000]
        PostgreSQL[PostgreSQL :5432]
        MongoDB[MongoDB :27017]
        KongDB[Kong DB]
        KeycloakDB[Keycloak DB]
    end

    Kong --> NestJS
    Kong --> KongDB
    Keycloak --> KeycloakDB
    NestJS --> PostgreSQL
    NestJS --> MongoDB
```

### En production

En production, retirer l'exposition des ports internes :

```yaml
# ❌ En dev (exposition pour debug)
ports:
  - "3000:3000"  # Backend accessible directement

# ✅ En production (pas d'exposition)
# ports:
#   - "3000:3000"
# Accès uniquement via Kong sur le port 8000
```

## Inspection du réseau

### Lister les conteneurs sur le réseau

```bash
docker network inspect lcg-solutions
```

### Voir les connexions actives

```bash
# Depuis le host
docker network inspect lcg-solutions | grep -A 5 "Containers"

# Depuis un conteneur
docker exec -it kong-gateway ping nodejs-nest-backend
```

### Tester la connectivité

```bash
# Tester Kong → NestJS
docker exec -it kong-gateway curl http://nodejs-nest-backend:3000/health

# Tester Kong → Keycloak
docker exec -it kong-gateway curl http://keycloak:8080/health
```

## Schéma de déploiement

```mermaid
graph TB
    Internet([Internet]) -->|HTTPS| LB[Load Balancer]

    subgraph "Production Environment"
        LB --> Kong1[Kong Instance 1]
        LB --> Kong2[Kong Instance 2]

        Kong1 --> Services
        Kong2 --> Services

        subgraph "Network: lcg-solutions"
            Services[Services Layer]
            Services --> NestJS1[NestJS 1]
            Services --> NestJS2[NestJS 2]
            Services --> Keycloak[Keycloak Cluster]

            NestJS1 --> DBCluster
            NestJS2 --> DBCluster

            subgraph "Data Layer"
                DBCluster[PostgreSQL Cluster]
                MongoCluster[MongoDB Cluster]
            end
        end
    end

    classDef lb fill:#ffcdd2,stroke:#c62828
    classDef gateway fill:#e1f5ff,stroke:#01579b
    classDef service fill:#f3e5f5,stroke:#4a148c
    classDef db fill:#fff3e0,stroke:#e65100

    class LB lb
    class Kong1,Kong2 gateway
    class NestJS1,NestJS2,Keycloak service
    class DBCluster,MongoCluster db
```

## Troubleshooting

### Service ne peut pas joindre un autre service

```bash
# 1. Vérifier que les deux services sont sur le même réseau
docker inspect <container-name> | grep NetworkMode

# 2. Tester la résolution DNS
docker exec -it <container-name> nslookup <target-service-name>

# 3. Tester la connectivité
docker exec -it <container-name> ping <target-service-name>
```

### Recréer le réseau

```bash
# Arrêter tous les services
docker compose down

# Supprimer le réseau
docker network rm lcg-solutions

# Recréer le réseau
docker network create lcg-solutions

# Redémarrer les services
docker compose up -d
```
