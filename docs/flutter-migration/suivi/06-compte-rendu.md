# Compte Rendu — Lot 06 : Gestion des Sprints / Cycles, En-tête de Métriques & Planification

## Résumé du travail réalisé

Dans le cadre du Lot 06, le cycle de vie complet des Sprints et Cycles, le bandeau de métriques douces et de burn-down d'équipe, ainsi que la modale de planification interactive de sprint avec sélection de tickets depuis le backlog ont été développés et intégrés avec une fidélité stricte au design system Neo-Linear et aux maquettes `ux/disciplan_web_vue_kanban_du_sprint/code.html` et `ux/disciplan_web_cr_ation_de_sprint/code.html`.

### 1. Données et State Management (`lib/features/sprints/`)
- **`SprintRepository`** :
  - Couverture complète des endpoints de `SprintsController.cs` :
    - `getActive()` (`GET /api/sprints/active`)
    - `getWithDates()` (`GET /api/sprints/with-dates`)
    - `getById(id)` (`GET /api/sprints/{id}`)
    - `getByProject(projectId)` (`GET /api/projects/{id}/sprints`)
    - `create(projectId, request)` (`POST /api/projects/{id}/sprints`)
    - `update(sprintId, request)` (`PUT /api/sprints/{id}`)
    - `start(sprintId, request)` (`PUT /api/sprints/{id}/start`)
    - `close(sprintId)` (`PUT /api/sprints/{id}/close`)
    - `delete(sprintId)` (`DELETE /api/sprints/{id}`)
- **Modèle `SprintMetrics` & Providers Riverpod** :
  - Classe `SprintMetrics` calculant en temps réel :
    - Nombre de tâches totales & clôturées (`totalTickets`, `closedTickets`).
    - Pourcentage d'avancement fluide (`completionPercentage`).
    - Story points totaux et complétés (`totalPoints`, `completedPoints`).
    - Jours ouvrés restants avant livraison (`daysRemaining`).
    - Liste des équipiers et contributeurs actifs sur le sprint.
  - Providers :
    - `projectSprintsProvider` : Liste des sprints d'un projet.
    - `activeSprintsProvider` : Sprints actifs de l'utilisateur.
    - `selectedSprintIdProvider` : Sprint courant en cours de consultation.
    - `sprintDetailProvider` : Détails étendus avec statuts de workflow associés.
    - `sprintMetricsProvider` : Provider auto-dispose combinant les tickets et dates de sprint pour alimenter le dashboard.

### 2. Bandeau d'En-tête Sprint & Tapis de Métriques (`SprintMetricsHeader`)
- Conforme à `ux/disciplan_web_vue_kanban_du_sprint/code.html` :
  - Pastille d'état : `Sprint Actif` avec pastille ambre animée, `Planifié` ou `Clôturé`.
  - Plage de dates formatée (`10 Févr. – 24 Févr.`) et badge d'urgence `J-X restants`.
  - Titre principal en typographie `headlineLg` et objectif du sprint (`goal`).
  - Boutons d'action contextuels :
    - Si sprint planifié : bouton d'activation immédiate "Démarrer le cycle".
    - Si sprint actif : bouton "Terminer le sprint" clôturant le cycle et appelant `PUT /api/sprints/{id}/close`.
    - Bouton d'action rapide `+ Nouvelle tâche` avec indicateur de raccourci `C`.
  - **Tapis de métriques douces** :
    - Compteur de tâches terminées (`X/Y terminées (Z%)`).
    - Indicateur de vélocité en Story Points complétés.
    - Pile d'avatars circulaires superposés des contributeurs actifs.
    - **Jauge Burn-down d'équipe** : barre de progression fine et réactive avec affichage du pourcentage en police monospace.

### 3. Vue Chronologique des Cycles (`CyclesOverviewScreen`)
- Écran réactif accessible via la route `/cycles` et la barre latérale VS Code :
  - Mise en avant héroïque du sprint actif avec son bandeau de métriques complet.
  - Section arborescente des cycles planifiés avec date, nombre de tâches et bouton de démarrage rapide.
  - Section d'historique des cycles clôturés.
  - Bouton d'action principal `Créer un cycle`.

### 4. Modale de Création & Planification de Sprint (`CreateSprintModal`)
- Conforme à `ux/disciplan_web_cr_ation_de_sprint/code.html` :
  - Saisie du nom de sprint avec puces de suggestions rapides en un clic.
  - Sélecteur de cadence agile : 1 semaine (Flash), 2 semaines (Optimal), 1 mois (Projet) recalculant automatiquement les dates de début et d'échéance.
  - Objectif principal du sprint (Sprint Goal).
  - **Plateau de sélection de tickets depuis le Backlog** :
    - Liste des tickets disponibles non assignés à un sprint.
    - Cases à cocher interactives `DenseCheckbox`.
    - Calcul et mise à jour en temps réel du total de tickets et de la charge en Story Points prévus.
  - Option "Démarrer immédiatement ce sprint" activant automatiquement le cycle dès sa validation.

### 5. Tests et Validation
- **`test/sprints_and_cycles_test.dart`** :
  - Tests unitaires complets de l'algorithme de calcul de `SprintMetrics.fromTickets` (taux de complétion, vélocité, points, jours restants, contributeurs).
  - Test de widget de `SprintMetricsHeader` (vérification de la pastille de statut, du titre, du goal, des métriques et du callback de clôture).
  - Test de widget de `CreateSprintModal` (rendu des champs, boutons de cadence et plateau de sélection backlog).
- **Résultats de validation** :
  - `flutter analyze` : 0 issue.
  - `flutter test` : 27/27 tests passés avec succès.

---

## Statut des Critères d'acceptation
- [x] L'utilisateur peut créer un sprint, y rattacher des tickets du backlog, démarrer un sprint planifié et clôturer un sprint actif.
- [x] Le bandeau de métriques et la modale de création de sprint reproduisent fidèlement les maquettes `ux/`.
- [x] `flutter analyze` et `flutter test` passent sans erreur.
