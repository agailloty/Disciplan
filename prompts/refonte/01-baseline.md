# Lot 01 — Établir la référence et le cadre de recette

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Aucun lot préalable ; lire les deux documents de refonte. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

Disciplaner.slnx ; README.md ; .github/workflows/docker.yml ; src/Disciplaner.Web/Server/Program.cs ; src/Disciplaner.Web/Client/Pages ; src/Disciplaner.Infrastructure/Data/Migrations. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Inventorie routes, modèles, fichiers de stockage et migrations, puis compare le code actuel au commit audité. Consigne les écarts qui rendent un constat obsolète.
2. Exécute la compilation avec le SDK disponible et relève les prérequis réels ; ne change pas de version de framework pour contourner un échec.
3. Ajoute une infrastructure de tests adaptée : domaine, API avec SQLite temporaire et client. Prépare des fixtures déterministes : projets publics au sens de leurs membres (jamais anonymes), projets isolés, les quatre rôles, membre retiré, cartes, tickets, sprints, commentaires et fichiers factices.
4. Prépare des données séparées pour les mesures à 10 000 tickets, 20 projets et 50 utilisateurs ; aucun compte réel.
5. Lance l'application sur une base temporaire si l'environnement le permet. Documente les cinq parcours de l'audit, captures et défauts observés. Si aucun navigateur n'est disponible, marque explicitement la recette visuelle non exécutée.
6. Écris les décisions de référence : Project frontière de droits, Ticket canonique, SQLite/Blazor conservés, périmètre de version. Ajoute une CI de compilation/tests sur PR sans publication automatique.

## Critères d'acceptation

- La solution compile ou les erreurs préexistantes sont reproduites et expliquées ; elles doivent être résolues avant les lots dépendants.
- Les fixtures sont recréables sans toucher aux données de l'utilisateur.
- Un test API prouve la distinction membre/non-membre sur une ressource de référence.
- Le dossier de baseline distingue observations statiques et exécution réelle.

## Livrables et transmission

Code de tests/CI, docs/refonte/decisions.md et docs/refonte/recette-baseline.md.

Crée `docs/refonte/suivi/01-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Corriger les droits et l'intégrité du cœur](02-droits-integrite.md) ; ne le commence pas dans cette tâche.
