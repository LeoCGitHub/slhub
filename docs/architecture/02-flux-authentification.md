# Flux d'Authentification - SLHub

## Vue d'ensemble

L'authentification dans SLHub utilise le protocole OAuth2/OpenID Connect avec Keycloak comme serveur d'autorisation et Kong comme gateway de validation.

## Flux de connexion utilisateur

```mermaid
sequenceDiagram
    participant User as Utilisateur
    participant Front as Front Angular
    participant Kong as Kong Gateway
    participant Keycloak as Keycloak
    participant NestJS as Backend NestJS

    User->>Front: 1. Clic sur "Se connecter"
    Front->>Keycloak: 2. Redirection vers login<br/>/realms/slhub/protocol/openid-connect/auth
    User->>Keycloak: 3. Saisie credentials
    Keycloak->>Keycloak: 4. Validation credentials
    Keycloak-->>Front: 5. Redirection avec code
    Front->>Keycloak: 6. Exchange code for tokens<br/>(access_token, refresh_token)
    Keycloak-->>Front: 7. JWT tokens
    Front->>Front: 8. Stockage tokens (memory/localStorage)

    Note over Front,Kong: L'utilisateur est maintenant authentifié

    Front->>Kong: 9. GET /api/users<br/>Authorization: Bearer {access_token}
    Kong->>Keycloak: 10. Valider token JWT
    Keycloak-->>Kong: 11. Token valide + user info
    Kong->>NestJS: 12. Proxy avec user context
    NestJS-->>Kong: 13. Response
    Kong-->>Front: 14. Response
    Front-->>User: 15. Affichage données
```

## Flux de rafraîchissement de token

```mermaid
sequenceDiagram
    participant Front as Front Angular
    participant Kong as Kong Gateway
    participant Keycloak as Keycloak
    participant NestJS as Backend NestJS

    Front->>Kong: 1. GET /api/users<br/>Authorization: Bearer {expired_token}
    Kong->>Keycloak: 2. Valider token
    Keycloak-->>Kong: 3. Token expiré (401)
    Kong-->>Front: 4. HTTP 401 Unauthorized

    Front->>Front: 5. Détection token expiré
    Front->>Keycloak: 6. POST /token<br/>grant_type=refresh_token<br/>refresh_token={refresh_token}
    Keycloak->>Keycloak: 7. Valider refresh_token
    Keycloak-->>Front: 8. Nouveaux tokens (access + refresh)
    Front->>Front: 9. Mise à jour tokens

    Front->>Kong: 10. Retry GET /api/users<br/>Authorization: Bearer {new_token}
    Kong->>NestJS: 11. Proxy
    NestJS-->>Kong: 12. Response
    Kong-->>Front: 13. Response
```

## Flux de déconnexion

```mermaid
sequenceDiagram
    participant User as Utilisateur
    participant Front as Front Angular
    participant Keycloak as Keycloak

    User->>Front: 1. Clic sur "Se déconnecter"
    Front->>Keycloak: 2. POST /realms/slhub/protocol/openid-connect/logout<br/>refresh_token={refresh_token}
    Keycloak->>Keycloak: 3. Invalider tokens
    Keycloak-->>Front: 4. Confirmation
    Front->>Front: 5. Supprimer tokens locaux
    Front-->>User: 6. Redirection vers login
```

## Configuration Keycloak requise

### 1. Créer un Realm

```bash
Realm: slhub
```

### 2. Créer les clients

#### Client pour Kong (backend)
```yaml
Client ID: kong
Client Protocol: openid-connect
Access Type: confidential
Valid Redirect URIs: http://localhost:8000/*
```

#### Client pour Front Angular (frontend)
```yaml
Client ID: front-angular
Client Protocol: openid-connect
Access Type: public
Valid Redirect URIs:
  - http://localhost:4200/*
  - http://localhost:4200/callback
Web Origins: http://localhost:4200
```

### 3. Créer des utilisateurs de test

```yaml
Username: testuser
Email: test@slhub.local
Password: password123
Email Verified: Yes
```

## Validation du token par Kong

Kong utilise le plugin `openid-connect` pour valider automatiquement les tokens :

```mermaid
graph LR
    A[Requête avec Bearer Token] --> B{Kong: Valider token}
    B -->|Token valide| C[Proxy vers Backend]
    B -->|Token invalide| D[HTTP 401]
    B -->|Token expiré| D
    B -->|Token manquant| D
    C --> E[Backend traite la requête]
    E --> F[Response]
    D --> G[Client doit se ré-authentifier]
```

## Structure du JWT

Exemple de payload JWT retourné par Keycloak :

```json
{
  "exp": 1672531200,
  "iat": 1672527600,
  "jti": "abc123...",
  "iss": "http://localhost:8080/realms/slhub",
  "aud": "front-angular",
  "sub": "user-uuid-123",
  "typ": "Bearer",
  "azp": "front-angular",
  "session_state": "session-uuid",
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "preferred_username": "johndoe",
  "email": "john@slhub.local",
  "email_verified": true,
  "realm_access": {
    "roles": ["user", "admin"]
  },
  "resource_access": {
    "front-angular": {
      "roles": ["view-profile"]
    }
  }
}
```

## Gestion des rôles

```mermaid
graph TB
    subgraph "Keycloak"
        Realm[Realm: slhub]
        Realm --> Role1[Role: admin]
        Realm --> Role2[Role: user]
        Realm --> Role3[Role: moderator]
    end

    subgraph "Kong"
        Kong[Kong Gateway]
        Kong --> Check{Vérifier rôle<br/>dans JWT}
    end

    subgraph "Backend NestJS"
        Guard[Auth Guard]
        Guard --> AdminRoute[Route /admin/*]
        Guard --> UserRoute[Route /api/*]
    end

    Check -->|admin| AdminRoute
    Check -->|user| UserRoute
    Check -->|unauthorized| Reject[HTTP 403]
```

## Sécurité

### Bonnes pratiques implémentées

- ✅ **Access tokens courts** : Durée de vie 5-15 minutes
- ✅ **Refresh tokens longs** : Durée de vie 30 jours
- ✅ **HTTPS en production** : Obligatoire pour les tokens
- ✅ **Token validation côté serveur** : Kong vérifie chaque requête
- ✅ **Pas de stockage sensible** : Tokens en memory ou httpOnly cookies

### Points d'attention

- ⚠️ Ne jamais exposer le `client_secret` côté frontend
- ⚠️ Utiliser PKCE pour les clients publics (front Angular)
- ⚠️ Implémenter une liste noire de tokens (optionnel)
- ⚠️ Surveiller les tentatives de connexion échouées
