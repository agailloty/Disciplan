# Lot 03 — Ajouter le modèle canonique et les contrats compatibles

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 02 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Domain/Entities ; src/Disciplaner.Domain/Enums ; src/Disciplaner.Application/DTOs ; src/Disciplaner.Infrastructure/Data/Configurations ; ApplicationDbContext.cs. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Étends Ticket avec rang, version de concurrence et archivage, en conservant les identifiants et références actuels. Spécifie une stratégie de rang stable, transactionnelle et rééquilibrable.
2. Ajoute BoardViewDefinition et mapping des colonnes vers les statuts d'un projet. L'ancien Board reste lisible pendant la conversion.
3. Ajoute MigrationRun/MigrationMap avec unicité source/cible et checkpoints. Ajoute le rattachement des fichiers et labels au projet pour préserver ceux des anciens tableaux.
4. Versionne le contrat des SavedViews et prépare visibilité privée/projet, tri/groupement/colonnes sans ouvrir les vues actuelles à d'autres utilisateurs.
5. Écris les configurations EF explicites, indexes utiles et migrations additives ; ne modifie pas les migrations historiques. Respecte les valeurs d'enums persistées.
6. Définis les contrats des commandes de transition, classement et recherche paginée, et les erreurs de concurrence.
7. Ne crée pas Workspace/Team ni une nouvelle frontière d'autorisation. Documente les invariants et un schéma du modèle.

## Critères d'acceptation

- Une base neuve et une copie de schéma existant migrent.
- Les anciens tickets gardent leurs GUID/références et les vues restent privées.
- Les anciens parcours restent utilisables avant activation des nouvelles fonctions.
- Les contraintes empêchent mapping dupliqué et références invalides ; version obsolète détectée côté serveur.

## Livrables et transmission

Modèle, configurations, migrations additives, DTO et décision d'architecture sur le rang/concurrence.

Crée `docs/refonte/suivi/03-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Construire et répéter la conversion des tableaux](04-conversion.md) ; ne le commence pas dans cette tâche.
