# Lot 08 — Création de Ticket & Fiche Détail (Split Inspector Desktop & Bottom Sheet Mobile)

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 07 terminé et commité (`docs/flutter-migration/suivi/07-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `ux/disciplan_web_cr_ation_de_ticket/code.html`
- `ux/disciplan_mobile_cr_ation_de_ticket/code.html`
- `ux/disciplan_mobile_d_tail_du_ticket/code.html`
- `ux/disciplan_web_vue_projet_style_vs_code/code.html` (panneau d'inspection latéral)
- `src/Disciplaner.Web/Server/Controllers/TicketsController.cs`, `CommentsController.cs`, `AttachmentsController.cs`, `TicketHistoryController.cs`, `LabelsController.cs`

## Travail à réaliser

1. **Repositories Complémentaires du Ticket (`lib/features/tickets/`)** :
   - Implémente les appels complets pour :
     - Détail du ticket par ID (`GET /api/tickets/{ticketId}`) ou par référence (`GET /api/tickets/by-ref/{projectKey}/{ticketNumber}`).
     - Mise à jour complète (`PUT /api/tickets/{ticketId}`).
     - Commentaires (`GET /api/tickets/{ticketId}/comments`, `POST /api/tickets/{ticketId}/comments`, `PUT /api/comments/{commentId}`, `DELETE /api/comments/{commentId}`).
     - Pièces jointes (`GET /api/attachments/ticket/{ticketId}`, `POST /api/attachments/ticket/{ticketId}` en `MultipartFile` Dio, `GET /api/attachments/{id}/download`, `DELETE /api/attachments/{id}`).
     - Historique d'audit (`GET /api/tickets/{ticketId}/history`).
     - Labels (`POST /api/tickets/{ticketId}/labels/{labelId}`, `DELETE /api/tickets/{ticketId}/labels/{labelId}`).

2. **Création de Ticket Web/Desktop & Mobile** :
   - **Desktop / Web (`DesktopCreateTicketDialog`)** : Reproduis `ux/disciplan_web_cr_ation_de_ticket/code.html` (déclenchable par le bouton `+ Nouvelle tâche` ou la touche `C`) :
     - Fil d'Ariane du projet cible, saisie du titre sans bordure lourde, zone de description riche/markdown, barre de propriétés compacte en bas (Statut, Priorité, Assigné, Sprint/Cycle, Story Points, Date d'échéance, Type de ticket, Ticket parent optionnel).
     - Toggle "Créer une autre tâche à la suite".
   - **Mobile (`MobileCreateTicketSheet`)** : Reproduis `ux/disciplan_mobile_cr_ation_de_ticket/code.html` :
     - Feuille modale orientée saisie au pouce avec sélecteurs en pills horizontales pour le statut, la priorité, le cycle et l'assigné.

3. **Fiche Détail du Ticket : Split Inspector (Desktop) & Détail Complet (Mobile)** :
   - **Sur Desktop/Web** : Lorsqu'on clique sur un ticket dans la Vue Liste ou le Kanban, ouvre le **Split Inspector Panel** à droite de l'écran (comme dans `ux/disciplan_web_vue_projet_style_vs_code/code.html`) ou en plein écran via `/tickets/DISC-XX`.
   - **Sur Mobile** : Reproduis fidèlement `ux/disciplan_mobile_d_tail_du_ticket/code.html` :
     - En-tête avec clé `DISC-14`, badge de statut interactif, priorité et menu d'actions.
     - Édition directe (inline) du titre, de la description, du statut, de la priorité, de l'assigné, du sprint, des story points et de la date d'échéance.
     - **Section Sous-tâches** : Jauge d'avancement (ex. `3/4 complétées`), liste des sous-tâches cochables et ajout rapide d'une sous-tâche (`parentTicketId`).
     - **Section Pièces jointes** : Liste des fichiers attachés avec taille, ajout de fichier et suppression.
     - **Onglets Activité : Commentaires & Historique** :
       - Fil de commentaires chronologique avec saisie d'un nouveau commentaire, édition et suppression.
       - Journal d'audit (`TicketHistoryEntryDto`) listant chaque changement de champ avec auteur et horodatage.

4. **Tests unitaires et de widgets** :
   - Teste la création d'un ticket via `DesktopCreateTicketDialog` et `MobileCreateTicketSheet`.
   - Teste l'affichage du détail d'un ticket, de ses sous-tâches, de ses commentaires et de son historique.

## Critères d'acceptation

- La création et l'édition complète d'un ticket (propriétés, sous-tâches, commentaires, pièces jointes, historique) fonctionnent sur Desktop et Mobile.
- Les maquettes `disciplan_web_cr_ation_de_ticket`, `disciplan_mobile_cr_ation_de_ticket` et `disciplan_mobile_d_tail_du_ticket` sont fidèlement respectées.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/08-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): implement ticket creation modals, split inspector and mobile detail sheet`
