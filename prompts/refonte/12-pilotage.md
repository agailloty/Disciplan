# Lot 12 — Ajouter jalons et rapports fiables

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 11 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Web/Client/Pages/ProjectView.razor ; Home.razor ; src/Disciplaner.Domain/Entities/TicketHistory.cs ; snapshots sprint du lot 10. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Ajoute objectif projet, jalons datés et synthèses d'avancement ; création/modification par Supervisor selon la matrice.
2. Livre vue d'ensemble avec travail terminé/reste, blocages, jalons et dernière synthèse, toujours liée à des données réelles.
3. Définis chaque métrique avant requête : throughput = tickets achevés sur période selon événements ; cycle time = durée entrée InProgress→achèvement, avec politique de réouverture explicite ; vélocité = points achevés dans snapshot de clôture.
4. Construis un burndown à partir des événements et variations de périmètre, séparant variation d'estimation et achèvement.
5. Affiche période, fuseau, unités, traitement des tickets non estimés et date de début de disponibilité des données. N'invente pas l'historique avant la collecte.
6. Ajoute représentation tabulaire accessible des graphiques et projections agrégées paginées si nécessaires.

## Critères d'acceptation

- Un petit jeu de données calculable à la main produit les valeurs attendues.
- Changement d'estimation après clôture ne modifie pas la vélocité historique.
- Une réouverture suit la définition annoncée.
- Projet sans historique affiche données insuffisantes, jamais un graphique artificiel.
- Guest voit uniquement les rapports de ses projets ; dates/fuseaux testés.

## Livrables et transmission

Modèle jalons/synthèses, dictionnaire des métriques, vues/rapports et tests de calcul.

Crée `docs/refonte/suivi/12-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Permettre import/export et automatisations limitées](13-echanges-automatisations.md) ; ne le commence pas dans cette tâche.
