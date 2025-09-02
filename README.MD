Pour une architecture de microservices avec un hub centralisé Keycloak, APIs REST et messaging, voici des technologies recommandées :

Gestion d'identité et sécuritéchekc
[x] Keycloak : solution open-source de gestion d'identité et d'accès, compatible OAuth2/OpenID Connect, facile à intégrer comme serveur d'authentification centralisé.

API Gateway
Spring Cloud Gateway (Java/Spring) : flexible, performant, intégration native avec Keycloak via OAuth2

Kong ou Traefik : gateways cloud-native, supportent l’authentification Keycloak

Microservices REST
Spring Boot (Java) : framework mature pour créer des microservices robustes et sécurisés

Quarkus ou Micronaut (Java) : frameworks modernes et légers, adaptés au cloud

Node.js + Express/Koa : si besoin de JavaScript/TypeScript

.NET Core : pour environnement Microsoft

Messaging asynchrone
RabbitMQ : système de queues fiable, facile à intégrer

Apache Kafka : plateforme de streaming distribuée très scalable, idéale pour gros volumes

ActiveMQ : autre système de gestion de message éprouvé

Découverte et monitoring
Consul ou Eureka : service discovery et configuration centralisée

Prometheus + Grafana : monitoring métriques et visualisation

Autres
Docker + Kubernetes : pour containerisation, orchestration et scalabilité

PostgreSQL / MongoDB : bases de données relationnelles ou NoSQL selon besoins métier

En résumé, une stack typique Java/Spring avec Keycloak, Spring Cloud Gateway, RabbitMQ/Kafka, containers Docker/K8s offre un socle solide, flexible, et maintenable pour un hub microservices sécurisé.

TODO faire un système de récupération des sources des autres projets gitlab avec les docker-compose qui vont bien
