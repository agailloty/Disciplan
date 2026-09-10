# Lot 08 — Livrer un backlog priorisable et un tableau unifié

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 07 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Web/Client/Pages/ProjectView.razor ; Components/Shared/SprintBoard.razor ; Components/Kanban ; Services/KanbanDragState.cs ; wwwroot/js/kanban.js. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Implémente la liste backlog classée par rang serveur ; exclue par défaut les catégories terminées et l'archivage, avec filtres visibles pour les inclure.
2. Ajoute réordonnancement à la souris et au clavier, sélection multiple et affectation au sprint ; batch atomique limité à un projet.
3. Affiche BoardViewDefinition sur les mêmes tickets, avec mappings de statuts, compteurs et limite WIP d'avertissement par défaut.
4. Lorsqu'une colonne contient plusieurs statuts, fais choisir le statut cible ; une colonne visuelle ne remplace pas le workflow.
5. Persiste l'ordre dans une transaction ; traite classement concurrent, pagination et rééquilibrage des rangs.
6. Reconnecte les anciennes routes converties à cette vue et affiche l'état lecture seule des anciens objets.

## Critères d'acceptation

- Un déplacement persiste après rechargement et dans les autres vues.
- L'option clavier produit le même résultat que le drag-and-drop.
- Un ticket terminé sans sprint n'encombre pas le backlog par défaut.
- Deux utilisateurs classant simultanément ne perdent aucun ticket.
- Un batch contenant un ticket interdit échoue intégralement ; WIP dépassement visible et accessible.

## Livrables et transmission

Backlog/tableau commun, commandes de classement/batch, tests de concurrence et recette souris/clavier.

Crée `docs/refonte/suivi/08-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Renforcer les workflows et les relations métier](09-workflows-relations.md) ; ne le commence pas dans cette tâche.
