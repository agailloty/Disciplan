# Lot 06 — Gestion des Sprints / Cycles, En-tête de Métriques & Planification

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 05 terminé et commité (`docs/flutter-migration/suivi/05-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `src/Disciplaner.Web/Server/Controllers/SprintsController.cs`
- `src/Disciplaner.Application/DTOs/Sprint/`
- `ux/disciplan_web_cr_ation_de_sprint/code.html`
- `ux/disciplan_web_vue_kanban_du_sprint/code.html` (section En-tête Sprint & Métriques)
- `ux/disciplan_mobile_projets_cycles/code.html`

## Travail à réaliser

1. **Repository & Providers des Sprints (`lib/features/sprints/`)** :
   - Implémente `SprintRepository` couvrant toutes les routes de `SprintsController` :
     - `GET /api/sprints/active`, `GET /api/sprints/with-dates`, `GET /api/sprints/{id}`, `GET /api/projects/{projectId}/sprints`
     - `POST /api/projects/{projectId}/sprints`, `PUT /api/sprints/{id}`
     - `POST /api/sprints/{id}/start`, `POST /api/sprints/{id}/close`, `DELETE /api/sprints/{id}`
   - Crée les providers Riverpod : `projectSprintsProvider`, `activeSprintsProvider`, `selectedSprintProvider`, `sprintMetricsProvider` (calculant le nombre de tickets terminés/totaux, le pourcentage d'avancement, les story points complétés/totaux, les jours restants et les membres impliqués).

2. **Bandeau d'En-tête Sprint & Tapis de Métriques (`SprintMetricsHeader`)** :
   - Reproduis fidèlement le header de `ux/disciplan_web_vue_kanban_du_sprint/code.html` :
     - Badges : `Cycle Actif` (ou `Planifié` / `Clôturé`), numéro de semaine, plage de dates (`10 Févr. – 24 Févr.`), badge `J-X restants`.
     - Titre du sprint en `headlineXl` et objectif (`goal`).
     - Boutons d'actions : Filtrer, Trier par priorité, Démarrer le sprint (si `Planned`), Terminer le sprint (si `Active` -> appelle `/api/sprints/{id}/close`), `+ Nouvelle tâche`.
     - **Tapis de métriques douces** :
       - Tâches terminées (`X/Y terminées (Z%)`)
       - Vélocité / Story points complétés
       - Équipiers actifs sur le sprint (avec pile d'avatars chevauchés)
       - **Jauge Burn-down d'équipe** (barre de progression ambre/primaire fluide).

3. **Vue Cycles & Roadmap (`CyclesOverviewScreen`)** :
   - Affiche la chronologie des sprints du projet (Sprint actif mis en avant, Sprints planifiés avec possibilité d'affecter des tickets du backlog, Sprints clôturés avec historique de vélocité).

4. **Modale / Écran de Création & Planification de Sprint (`CreateSprintModal`)** :
   - Reproduis `ux/disciplan_web_cr_ation_de_sprint/code.html` :
     - Nom du sprint, objectif du cycle (`goal`), sélecteur de date de début et date de fin (raccourcis durée : 1 semaine, 2 semaines, 3 semaines, 4 semaines).
     - Sélection interactive de tickets issus du Backlog du projet pour les inclure dès la création du sprint (avec calcul en temps réel de la charge totale en Story Points).
     - Option pour démarrer immédiatement le cycle après création.

5. **Tests unitaires et de widgets** :
   - Tests unitaires du calcul des métriques de sprint (`sprintMetricsProvider`) et du `SprintRepository`.
   - Tests de widgets de `SprintMetricsHeader` et de `CreateSprintModal`.

## Critères d'acceptation

- L'utilisateur peut créer un sprint, y rattacher des tickets du backlog, démarrer un sprint planifié et clôturer un sprint actif.
- Le bandeau de métriques et la modale de création de sprint reproduisent fidèlement les maquettes `ux/`.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/06-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): implement sprint lifecycle, metrics header and sprint creation`
