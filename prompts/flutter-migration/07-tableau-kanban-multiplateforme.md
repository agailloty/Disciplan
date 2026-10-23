# Lot 07 — Tableau Kanban Multiplateforme (Desktop Drag & Drop & Mobile par Onglets)

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 06 terminé et commité (`docs/flutter-migration/suivi/06-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `ux/disciplan_web_vue_kanban_du_sprint/code.html`
- `ux/disciplan_mobile_tableau_de_sprint/code.html`
- `src/Disciplaner.Web/Server/Controllers/TicketsController.cs` (`PUT /api/tickets/{ticketId}/status`)
- `src/Disciplaner.Web/Server/Controllers/BoardsController.cs`, `ColumnsController.cs`, `CardsController.cs`

## Travail à réaliser

1. **Logique d'État Kanban & Mise à jour Optimiste (`lib/features/kanban/`)** :
   - Construis le contrôleur Riverpod regroupant les tickets du sprint actif (ou du projet) dans les colonnes correspondant aux `TicketStatusDto` du projet (triés par `order`).
   - Implémente le déplacement d'un ticket d'une colonne de statut à une autre avec **mise à jour optimiste immédiate** de l'interface, suivie de l'appel `PUT /api/tickets/{ticketId}/status` (et restauration de l'état précédent + notification d'erreur en cas d'échec réseau).
   - Ajoute les filtres contextuels inline : Tout afficher, Assigné à moi, Par priorité, Par label, Recherche textuelle instantanée.

2. **Vue Kanban Desktop & Web (`DesktopSprintKanbanView`)** :
   - Reproduis fidèlement `ux/disciplan_web_vue_kanban_du_sprint/code.html` :
     - Intègre `SprintMetricsHeader` (réalisé au Lot 06) en haut de la vue.
     - Barre de filtres contextuels inline discrets (`Afficher : Tous | Mes tâches | Bloqués...`).
     - Colonnes Kanban horizontales avec en-tête de colonne (pastille de couleur de catégorie, nom du statut, compteur en `JetBrains Mono`, bouton `+` pour ajouter un ticket directement dans ce statut).
     - **Cartes Kanban (`KanbanTicketCard`)** :
       - Fond `#FFFFFF`, bordure 1px `#E4E0D7`, rayon `rounded-lg`, padding 12px.
       - Clé `DISC-XX` en `JetBrains Mono`, badge de priorité, titre en `headlineSm`, jauge de sous-tâches si présentes, tags/labels, date d'échéance, points d'effort et avatar de l'assigné.
     - **Drag & Drop fluide** : Utilise `Draggable<TicketDto>` et `DragTarget<TicketDto>` avec surbrillance de la colonne cible (bordure ambre `#E5A800` / fond teinté) lors du survol.

3. **Vue Tableau de Sprint Mobile (`MobileSprintKanbanView`)** :
   - Reproduis fidèlement `ux/disciplan_mobile_tableau_de_sprint/code.html` :
     - Carte d'en-tête compacte du sprint (`Sprint 04`, nom, badge `J-X restants`, barre de progression fine 69%, avatars de l'équipe et badge `Cadence fluide`).
     - **Onglets horizontaux glissants (Pills)** pour chaque colonne de statut (`À faire [4]`, `En cours [3]`, `En revue [2]`, `Terminé [5]`). L'onglet actif est en fond `#1A1917` avec compteur ambre `#FFBF28`.
     - Flux vertical des cartes de la colonne active avec action rapide (menu ou glissement) pour faire passer un ticket au statut suivant ou précédent d'un seul geste.

4. **Support des Tableaux Personnels (`BoardsController`)** :
   - Permets également de basculer sur les tableaux Kanban personnels (`GET /api/boards`, colonnes et cartes `ColumnsController` / `CardsController`) depuis l'explorateur si l'utilisateur utilise des boards hors-projet.

5. **Tests de widgets** :
   - Teste l'affichage des colonnes Kanban Desktop et le déplacement d'une carte d'un statut à un autre.
   - Teste la navigation par onglets de statut sur `MobileSprintKanbanView`.

## Critères d'acceptation

- Sur Desktop/Web, le Kanban affiche les colonnes côte à côte avec Drag & Drop fonctionnel et mise à jour optimiste.
- Sur Mobile, le tableau de sprint utilise la navigation par onglets pills horizontaux conformément à la maquette mobile.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/07-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): build desktop drag-and-drop kanban board and mobile tabbed sprint board`
