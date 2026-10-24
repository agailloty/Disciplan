# Lot 05 — Vue "Mes Tâches", Vue Liste Haute Densité Style VS Code & Actions par Lot

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 04 terminé et commité (`docs/flutter-migration/suivi/04-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `src/Disciplaner.Web/Server/Controllers/TicketsController.cs`
- `src/Disciplaner.Web/Server/Controllers/SavedViewsController.cs`
- `ux/disciplan_web_mes_t_ches_style_vs_code/code.html`
- `ux/disciplan_web_vue_projet_style_vs_code/code.html`
- `ux/disciplan_neo_linear/DESIGN.md` (sections *Cards & List Rows* et *Checkboxes & Selection Affordances*)

## Travail à réaliser

1. **Repository & Providers de Liste de Tickets & Vues Sauvegardées** :
   - Implémente `TicketRepository` pour les lectures et mutations rapides :
     - `GET /api/tickets/mine` (tickets assignés à l'utilisateur courant)
     - `GET /api/projects/{projectId}/tickets/backlog`
     - `GET /api/sprints/{sprintId}/tickets`
     - `PUT /api/tickets/{ticketId}/status`, `PUT /api/tickets/{ticketId}/sprint`, `DELETE /api/tickets/{ticketId}`
   - Implémente `SavedViewRepository` (`GET /api/saved-views`, `POST /api/saved-views`, `DELETE /api/saved-views/{id}`).

2. **Composant Ligne de Ticket Haute Densité (`DenseTicketRow`)** :
   - Conformément à `DESIGN.md` et aux maquettes `ux/disciplan_web_mes_t_ches_style_vs_code/code.html` et `ux/disciplan_web_vue_projet_style_vs_code/code.html` :
     - Case à cocher fine 14x14px (`rounded-sm`, bordure `#E4E0D7`, remplissage `#1A1917` une fois cochée).
     - Icône de priorité (`PriorityIcon`) et icône de type de ticket.
     - Identifiant de ticket en `JetBrains Mono` (`labelSm`, ex. `DISC-14`).
     - Titre du ticket (`bodyMd`) avec troncature propre.
     - Badges de labels colorés, jauge compacte de sous-tâches (ex. `2/4`), points d'effort (`storyPoints`), date d'échéance (`dueDate`), avatar de l'assigné (20px) et badge de statut cliquable (`StatusBadge`).
     - Au survol (Desktop/Web) : révélation discrète d'actions rapides inline (changer statut, assigner).

3. **Vue Projet Liste & Backlog (`ProjectListView`)** :
   - Regroupement des tickets par catégorie de statut (`En cours`, `À faire`, `Terminé`) ou par Sprint / Backlog avec en-têtes de section repliables et compteurs.
   - Champ de saisie rapide inline en bas de chaque section (`+ Ajouter une tâche rapide...`) créant immédiatement un ticket via `POST /api/projects/{projectId}/tickets`.

4. **Vue "Mes Tâches" Style VS Code (`MyTasksView`)** :
   - Reproduis `ux/disciplan_web_mes_t_ches_style_vs_code/code.html` :
     - En-tête avec compteurs synthétiques (En cours, Urgentes, Terminées cette semaine).
     - Barre de filtres rapides (Tous, En cours, À faire, Par priorité, Par projet) + possibilité d'enregistrer le filtre courant comme **Vue Sauvegardée** (`POST /api/saved-views`) et de charger une vue sauvegardée en un clic.
     - Adaptation responsive pour Mobile (liste épurée avec balayage ou tap pour ouvrir ou changer le statut).

5. **Barre Flottante de Multi-Sélection (`MultiSelectActionBar`)** :
   - Lorsqu'un ou plusieurs tickets sont cochés, affiche en bas au centre la barre flottante décrite dans `DESIGN.md` :
     - Compteur de tickets sélectionnés.
     - Actions groupées : Changer le statut (`S`), Déplacer vers un sprint, Supprimer, Tout désélectionner (`Esc`).

## Critères d'acceptation

- La vue "Mes Tâches" et la vue Liste du projet affichent les tickets groupés avec le rendu haute densité VS Code / Neo-Linear.
- La création inline, le filtrage, les vues sauvegardées et les opérations groupées via la barre de multi-sélection fonctionnent de bout en bout.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/05-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): implement VS Code dense task list, my tasks view and batch actions`
