# Compte Rendu — Lot 05 : Vue "Mes Tâches", Vue Liste Haute Densité Style VS Code & Actions par Lot

## Résumé du travail réalisé

Dans le cadre du Lot 05, le module complet de gestion des tickets en liste haute densité, la vue personnalisée "Mes Tâches", la gestion des vues sauvegardées et la barre flottante de multi-sélection ont été développés et intégrés avec une fidélité stricte au design system Neo-Linear et aux maquettes VS Code (`ux/disciplan_web_mes_t_ches_style_vs_code/code.html` et `ux/disciplan_web_vue_projet_style_vs_code/code.html`).

### 1. Repositories et State Management (`lib/features/tickets/`)
- **`TicketRepository`** :
  - `getMine()` : Récupération des tickets assignés à l'utilisateur (`GET /api/tickets/mine`).
  - `getBacklog(projectId)` : Récupération du backlog complet du projet (`GET /api/projects/{id}/tickets/backlog`).
  - `getBySprint(sprintId)` : Récupération des tickets d'un sprint (`GET /api/sprints/{id}/tickets`).
  - `getById(ticketId)` & `getByRef(projectKey, number)` : Consultation unitaire.
  - `createTicket(projectId, request)` : Création rapide de ticket (`POST /api/projects/{id}/tickets`).
  - `changeStatus(ticketId, statusId)` : Mutation de statut (`PUT /api/tickets/{id}/status`).
  - `moveToSprint(ticketId, sprintId)` : Déplacement vers sprint ou backlog (`PUT /api/tickets/{id}/sprint`).
  - `deleteTicket(ticketId)` : Suppression d'un ticket (`DELETE /api/tickets/{id}`).
- **`SavedViewRepository`** :
  - `getAll()` : Liste des vues sauvegardées (`GET /api/saved-views`).
  - `create(request)` : Enregistrement de nouveaux filtres en vue sauvegardée (`POST /api/saved-views`).
  - `update(viewId, request)` : Modification des réglages.
  - `delete(viewId)` : Suppression d'une vue (`DELETE /api/saved-views/{id}`).
  - `execute(viewId)` : Exécution dynamique du filtre (`GET /api/saved-views/{id}/tickets`).
- **Providers Riverpod (Riverpod 3.x)** :
  - `selectedTicketIdsProvider` : `Notifier<Set<String>>` réactif pour piloter la sélection multiple (toggle, selectAll, clear).
  - `myTasksProvider` : `AsyncNotifier<List<TicketDto>>` gérant les tickets personnels, les mutations de statut unitaires et les opérations par lot (`batchChangeStatus`, `batchMoveToSprint`, `batchDelete`).
  - `projectBacklogProvider` & `sprintTicketsProvider` : Providers auto-dispose pour les listes de tickets.
  - `savedViewsListProvider` & `selectedSavedViewIdProvider` : Gestion des vues sauvegardées personnalisées.

### 2. Composants UI Haute Densité Neo-Linear (`lib/features/tickets/presentation/widgets/`)
- **`DenseCheckbox`** :
  - Case fine 14x14px avec bordure `borderWhisper`, coins `rounded-sm` (3px), et remplissage noir d'encre `#1A1917` avec micro-coche blanche au clic.
- **`DenseTicketRow`** :
  - Ligne de ticket ergonomique (48px) avec survol discret (`surfaceContainerLow`).
  - Icône de priorité sémantique `PriorityIcon` (critique, haute, moyenne, basse).
  - Identifiant unique monospace `GoogleFonts.jetBrainsMono` (ex. `DISC-14`).
  - Titre principal avec texte barré automatique lorsque le ticket est terminé.
  - Pilules de tags colorés (jusqu'à 2 tags avec pastille teintée).
  - Jauge d'estimation en story points (`X pts`).
  - Indicateur d'échéance temporelle avec icône calendrier (`Aujourd'hui`, `Demain`, `d MMM`).
  - Avatar circulaire du responsable assigné (22px `UserAvatar`).
  - Badge de statut pill `StatusBadge` conforme aux catégories Neo-Linear (`À faire`, `En cours`, `Terminé`).
  - Boutons d'actions rapides révélés au survol (suppression, modification rapide).
- **`MultiSelectActionBar`** :
  - Barre flottante ancrée en bas au centre dès qu'un ou plusieurs tickets sont sélectionnés.
  - Surface sombre `#1A1917` aux bords arrondis avec ombrage flottant et séparateurs fins.
  - Compteur dynamique d'éléments sélectionnés.
  - Menu contextuel de changement de statut groupé avec raccourci `S`.
  - Bouton d'assignation au sprint et bouton de suppression groupée.
  - Bouton de désélection totale avec raccourci clavier `Esc`.
- **`SaveViewModal`** :
  - Modale épurée pour enregistrer les filtres actifs en tant que vue sauvegardée pérenne (avec description et option d'épinglage sur la page d'accueil).

### 3. Vues Principales
- **`ProjectListView`** :
  - Regroupement des tickets par catégories de statut (`En cours`, `À faire`, `Terminé`).
  - En-têtes de section repliables avec compteurs numériques monospace.
  - Champ d'ajout rapide inline en bas de chaque groupe (`+ Ajouter une tâche dans "..." [Entrée]`) permettant la création instantanée au clavier.
  - Intégration transparente de la barre flottante de sélection par lot.
- **`MyTasksView`** :
  - En-tête synthétique avec badge `ESPACE PERSONNEL`, cycle actif et description.
  - 3 cartes de métriques en temps réel (`En cours`, `Urgentes`, `Terminées`).
  - Barre d'onglets de filtrage rapide (`Toutes`, `En cours`, `À faire`, `Urgentes`, `Terminées`).
  - Menu déroulant des vues sauvegardées permettant l'activation en un clic.
  - Bouton direct pour sauvegarder le filtre courant dans une vue personnalisée.
  - Liste scrollable haute densité avec actualisation `RefreshIndicator` et sélection groupée.

### 4. Tests et Validation
- **`test/tasks_and_list_view_test.dart`** :
  - Test de widget de la case à cocher haute densité `DenseCheckbox` (14x14px, interaction au tap).
  - Test de widget de la ligne `DenseTicketRow` (rendu complet du code ticket, titre, tags, priorité et avatar).
  - Test de widget de la barre d'actions groupées `MultiSelectActionBar` (compteur, effacement `Esc`, statut).
  - Test de widget de la vue complète `MyTasksView` (rendu des cartes métriques, des filtres et de la liste).
- **Résultats de validation** :
  - `flutter analyze` : 0 issue.
  - `flutter test` : 24/24 tests passés avec succès.

---

## Statut des Critères d'acceptation
- [x] La vue "Mes Tâches" et la vue Liste du projet affichent les tickets groupés avec le rendu haute densité VS Code / Neo-Linear.
- [x] La création inline, le filtrage, les vues sauvegardées et les opérations groupées via la barre de multi-sélection fonctionnent de bout en bout.
- [x] `flutter analyze` et `flutter test` passent sans erreur.
