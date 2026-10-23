# Compte Rendu — Lot 07 : Tableau Kanban Multiplateforme (Desktop Drag & Drop & Mobile par Onglets)

## Résumé du travail réalisé

Dans le cadre du Lot 07, le module de tableau Kanban multiplateforme pour le sprint actif a été développé en respectant fidèlement le design system Neo-Linear et les maquettes `ux/disciplan_web_vue_kanban_du_sprint/code.html` et `ux/disciplan_mobile_tableau_de_sprint/code.html`.

### 1. Logique d'État Kanban & Mise à Jour Optimiste (`lib/features/kanban/`)
- **`KanbanState`** :
  - Structure immuable contenant les colonnes de statut ordonnées (`statuses`), le dictionnaire des tickets regroupés par statut (`ticketsByStatus: Map<String, List<TicketDto>>`), la chaîne de recherche textuelle, les filtres d'assignation ("Mes tâches") et de niveau de priorité.
  - Méthode utilitaire `getFilteredTicketsForStatus()` appliquant instantanément les filtres combinés.
- **`KanbanNotifier` (Riverpod 3.x)** :
  - Chargement asynchrone des statuts du projet actif et des tickets du sprint.
  - Déplacement optimiste `moveTicket(ticketId, targetStatusId)` :
    - Mutation immédiate dans la mémoire locale de l'UI pour une réactivité instantanée à 60/120 fps.
    - Appel réseau en tâche de fond vers `PUT /api/tickets/{id}/status`.
    - Rollback automatique vers l'état initial avec notification d'erreur en cas d'échec réseau.
    - Invalidation réactive du `sprintMetricsProvider` pour recalculer instantanément le burn-down.

### 2. Cartes de Tickets Kanban (`KanbanTicketCard`)
- Implémentation selon les spécifications `DESIGN.md` :
  - Fond `#FFFFFF` (`surfaceContainerLowest`), bordure 1px `borderWhisper`, coins `rounded-lg` (8px).
  - Identifiant unique `ticketRef` en typographie monospace `GoogleFonts.jetBrainsMono`.
  - Indicateur de priorité graphique `PriorityIcon`.
  - Titre principal en `headlineSm` / `bodyMd` et extrait de description Markdown.
  - Indicateur d'échéance temporelle avec icône calendrier.
  - Badge d'effort en Story Points (`X pts`).
  - Avatar circulaire du collaborateur assigné (22px `UserAvatar`).
  - Menu contextuel rapide (`PopupMenuButton`) permettant de déplacer la carte vers n'importe quelle autre colonne en un clic sans drag and drop.

### 3. Vue Kanban Desktop & Web (`DesktopSprintKanbanView`)
- Intégration du bandeau de métriques `SprintMetricsHeader` (Lot 06) en en-tête.
- Barre d'outils et de filtres contextuels inline (recherche textuelle dynamique, filtre "Mes tâches", filtre "Priorité Haute").
- Colonnes de statut horizontales scrollables (largeur 300px) avec pastille colorée de workflow et compteur de tickets en police monospace.
- **Drag & Drop fluide et ergonomique** :
  - Les cartes sont enveloppées dans `LongPressDraggable<TicketDto>` avec retour visuel d'opacité semi-transparente pendant le drag.
  - Chaque colonne est configurée comme `DragTarget<TicketDto>`.
  - Surbrillance visuelle immédiate de la colonne cible lors du survol (bordure ambre `NeoColors.kineticAmber` 2px et fond teinté).
  - Déplacement exécuté à l'atterrissage via `moveTicket`.

### 4. Vue Tableau de Sprint Mobile (`MobileSprintKanbanView`)
- Conforme à `ux/disciplan_mobile_tableau_de_sprint/code.html` :
  - Carte d'en-tête compacte : nom du sprint, badge d'échéance `J-X restants`, et jauge linéaire fine de progression burn-down.
  - **Onglets pills horizontaux glissants** :
    - Navigation par onglet pour chaque statut (`À faire [4]`, `En cours [3]`, `En revue [2]`, `Terminé [5]`).
    - L'onglet actif se pare d'un fond d'encre sombre `#1A1917` avec un badge numérique doré `#FFBF28`.
  - Flux vertical des cartes correspondant à la colonne active avec action de déplacement direct au tap.

### 5. Écran Adaptatif & Router (`KanbanAdaptiveScreen`)
- Détection adaptative du breakpoint mobile (800px) :
  - Sur écrans larges (Desktop / Web / Tablette paysage) : bascule sur `DesktopSprintKanbanView`.
  - Sur smartphones (Mobile) : bascule sur `MobileSprintKanbanView`.
- Gestion des cas sans sprint actif : affichage d'un état propre avec bouton pour démarrer un sprint planifié ou créer un nouveau sprint via `CreateSprintModal`.
- Intégration dans la route `/kanban` du `GoRouter`.

### 6. Tests et Validation
- **`test/kanban_and_board_test.dart`** :
  - Tests unitaires du filtrage de `KanbanState` (recherche textuelle, tickets assignés à moi, filtrage par priorité).
  - Test de widget de `DesktopSprintKanbanView` vérifiant le rendu des colonnes de statuts, des cartes et des drag targets.
  - Test de widget de `MobileSprintKanbanView` validant la navigation entre colonnes via les onglets pills horizontaux.
- **Résultats de validation** :
  - `flutter analyze` : 0 issue.
  - `flutter test` : 30/30 tests passés avec succès.

---

## Statut des Critères d'acceptation
- [x] Sur Desktop/Web, le Kanban affiche les colonnes côte à côte avec Drag & Drop fonctionnel et mise à jour optimiste.
- [x] Sur Mobile, le tableau de sprint utilise la navigation par onglets pills horizontaux conformément à la maquette mobile.
- [x] `flutter analyze` et `flutter test` passent sans erreur.
