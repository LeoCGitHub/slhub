# Documentation Architecture - SLHub

Cette documentation contient l'ensemble des schémas d'architecture de la solution SLHub.

## 📚 Schémas disponibles

### [01 - Architecture Globale](01-architecture-globale.md)
Vue d'ensemble de l'architecture microservices complète avec tous les composants (Kong, Keycloak, services, bases de données, monitoring).

**Contenu :**
- Schéma d'architecture complète
- Liste des composants principaux
- Tableau des ports exposés
- Flux de requête standard
- Principes de sécurité

### [02 - Flux d'Authentification](02-flux-authentification.md)
Détails des flux OAuth2/OpenID Connect avec Keycloak et Kong.

**Contenu :**
- Flux de connexion utilisateur
- Flux de rafraîchissement de token
- Flux de déconnexion
- Configuration Keycloak
- Structure des JWT
- Gestion des rôles

### [03 - Réseau Docker](03-reseau-docker.md)
Topologie du réseau Docker et communication inter-services.

**Contenu :**
- Topologie du réseau `lcg-solutions`
- Communication inter-services
- Exposition des ports
- Isolation et sécurité
- Troubleshooting réseau

## 🛠️ Outils utilisés

Les schémas sont créés avec **Mermaid**, un outil de diagramming basé sur du texte qui est :
- ✅ Intégré nativement dans GitHub/GitLab
- ✅ Versionnable avec Git
- ✅ Facile à maintenir
- ✅ Pas de dépendances externes

## 📖 Comment lire les schémas

Les schémas Mermaid s'affichent automatiquement dans GitHub/GitLab. Si vous lisez cette documentation dans un éditeur local, vous pouvez :

1. **VSCode** : Installer l'extension "Markdown Preview Mermaid Support"
2. **En ligne** : Utiliser [Mermaid Live Editor](https://mermaid.live/)
3. **GitHub/GitLab** : Les schémas s'affichent automatiquement

## 🎨 Légende des couleurs

Dans les schémas :
- **Bleu clair** : Infrastructure (Kong, Keycloak, Monitoring)
- **Violet clair** : Services applicatifs (Backend NestJS)
- **Orange clair** : Bases de données
- **Vert clair** : Clients (Front Angular, apps mobiles)
- **Rose** : Load balancers / Réseau externe

## 📝 Maintenir la documentation

Lors de l'ajout de nouveaux services ou modifications architecturales :

1. Mettre à jour les schémas Mermaid correspondants
2. Mettre à jour les tableaux de ports
3. Ajouter les nouvelles configurations nécessaires
4. Tester que les schémas s'affichent correctement

## 🔗 Liens utiles

- [Mermaid Documentation](https://mermaid.js.org/)
- [Mermaid Live Editor](https://mermaid.live/)
- [Kong Documentation](https://docs.konghq.com/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
