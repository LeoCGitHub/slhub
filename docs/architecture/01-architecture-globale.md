# Architecture Globale - SLHub

## Vue d'ensemble

Architecture microservices avec un hub centralisé utilisant Kong API Gateway, Keycloak pour l'authentification, et monitoring Prometheus/Grafana.

```mermaid
graph TB
    subgraph "Clients"
        FrontAngular[Front Angular]
        FrontReact[Front React]
        Mobile[Apps Mobile]
    end

    subgraph "Infrastructure - API Gateway"
        Kong[Kong Gateway<br/>:8000]
    end

    subgraph "Infrastructure - Auth"
        Keycloak[Keycloak<br/>:8080]
        KeycloakDB[(PostgreSQL<br/>Keycloak)]
    end

    subgraph "Infrastructure - Monitoring"
        Prometheus[Prometheus]
        Grafana[Grafana]
    end

    subgraph "Services Backend"
        NestJS[Backend NestJS<br/>:3000]
    end

    subgraph "Bases de données"
        PostgreSQL[(PostgreSQL<br/>:5432)]
        MongoDB[(MongoDB<br/>:27017)]
    end

    subgraph "Infrastructure - Kong DB"
        KongDB[(PostgreSQL<br/>Kong)]
    end

    %% Relations Clients
    FrontAngular --> Kong
    FrontReact --> Kong
    Mobile --> Kong

    %% Relations Kong
    Kong --> NestJS
    Kong --> Keycloak
    Kong --> KongDB

    %% Relations Keycloak
    Keycloak --> KeycloakDB

    %% Relations Backend
    NestJS --> PostgreSQL
    NestJS --> MongoDB
    NestJS --> Keycloak

    %% Relations Monitoring
    Kong -.metrics.-> Prometheus
    NestJS -.metrics.-> Prometheus
    Keycloak -.metrics.-> Prometheus
    Prometheus --> Grafana

    classDef infrastructure fill:#e1f5ff,stroke:#01579b
    classDef service fill:#f3e5f5,stroke:#4a148c
    classDef database fill:#fff3e0,stroke:#e65100
    classDef client fill:#e8f5e9,stroke:#1b5e20

    class Kong,Keycloak,Prometheus,Grafana infrastructure
    class NestJS service
    class PostgreSQL,MongoDB,KeycloakDB,KongDB database
    class FrontAngular,FrontReact,Mobile client
```

## Composants principaux

### Infrastructure
- **Kong Gateway** : Point d'entrée unique (API Gateway)
- **Keycloak** : Gestion d'identité et authentification (OAuth2/OIDC)
- **Prometheus + Grafana** : Monitoring et métriques

### Services
- **Backend NestJS** : API REST principale
- **Front Angular** : Application front principale
- **Front React** : Application front alternative

### Bases de données
- **PostgreSQL** : Base de données relationnelle
- **MongoDB** : Base de données NoSQL

## Réseau Docker

Tous les services partagent le réseau Docker `lcg-solutions` pour communiquer entre eux.

## Ports exposés

| Service | Port | Description |
|---------|------|-------------|
| Kong Proxy | 8000 | Point d'entrée API (HTTP) |
| Kong Proxy | 8443 | Point d'entrée API (HTTPS) |
| Kong Admin | 8001 | API d'administration Kong |
| Kong Manager | 8002 | Interface web Kong |
| Keycloak | 8080 | Console d'administration et API |
| Backend NestJS | 3000 | API REST (accès direct) |
| PostgreSQL | 5432 | Base de données principale |
| MongoDB | 27017 | Base de données NoSQL |
| Grafana | 3001 | Dashboard de monitoring |
| Prometheus | 9090 | Métriques et alertes |

## Flux de requête standard

```mermaid
sequenceDiagram
    participant Client as Client (Browser/App)
    participant Kong as Kong Gateway
    participant Keycloak as Keycloak
    participant NestJS as Backend NestJS
    participant DB as Database

    Client->>Kong: GET /api/users<br/>(+ Bearer Token)
    Kong->>Keycloak: Valider token JWT
    Keycloak-->>Kong: Token valide
    Kong->>NestJS: Proxy vers /api/users
    NestJS->>DB: Query users
    DB-->>NestJS: Résultat
    NestJS-->>Kong: Response JSON
    Kong-->>Client: Response JSON
```

## Sécurité

- **Authentification centralisée** : Tous les appels passent par Kong qui vérifie le token Keycloak
- **Réseau isolé** : Les services communiquent via un réseau Docker privé
- **Pas d'accès direct** : Les clients ne peuvent pas accéder directement aux backends (sauf en dev)
