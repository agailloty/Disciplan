# Base de Données Multi-Provider (PostgreSQL & SQLite) et Intégration Cloud

Étude comparative des bases de données managées dans le Cloud (Relationnel vs NoSQL, PaaS vs Serverless PostgreSQL), audit technique du modèle de persistance actuel de Disciplan (EF Core 10) et plan d'évolution pour rendre le choix de la base de données flexible (**PostgreSQL prioritaire**, avec **fallback automatique sur SQLite** si rien n'est spécifié).

1. [Étude Cloud & Plan d'évolution de la solution](01-etude-cloud-et-plan-evolution.md)

Document d'étude et de conception architecturale — aucune modification du code source n'est exécutée à ce stade.

