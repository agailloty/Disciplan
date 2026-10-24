# Architecture & Plan de Migration Flutter Multiplateforme (Disciplan)

Ce document constitue la référence technique pour l'agent de codage chargé de réaliser la migration du front-end Disciplan vers **Flutter** (Mobile iOS/Android, Web, Desktop Windows/macOS/Linux), tout en conservant le backend **ASP.NET Core 10** existant strictement inchangé.

---

## 1. Principes Directeurs & Contraintes

1. **Backend .NET 10 Immuable** :
   - Aucun fichier sous `src/Disciplaner.Domain`, `src/Disciplaner.Application`, `src/Disciplaner.Infrastructure` ou `src/Disciplaner.Web/Server` ne doit être altéré dans sa logique métier ou ses contrats d'API.
   - L'application Flutter consomme exclusivement les endpoints REST existants dans `src/Disciplaner.Web/Server/Controllers/`.
2. **Emplacement du Projet Flutter** :
   - Le code Flutter réside dans `src/Disciplaner.Flutter/` (package Dart nommé `disciplaner_flutter`).
3. **Design System "Neo-Linear"** :
   - Toutes les interfaces respectent scrupuleusement `ux/disciplan_neo_linear/DESIGN.md` et les maquettes HTML/PNG présentes dans `ux/`.
4. **Expérience Adaptative Multiplateforme** :
   - **Desktop & Web ($\ge 840\text{px}$)** : Ergonomie inspirée de VS Code et Linear (Activity Bar 52px sombre `#181715`, Primary Sidebar repliable 240px, Top Command Bar avec fil d'Ariane et recherche `⌘K` / `Ctrl+K`, vues liste haute densité, tableau Kanban multi-colonnes, panneau d'inspection en Split View).
   - **Mobile ($< 840\text{px}$)** : Ergonomie tactile à une main (Header compact avec `SafeArea`, onglets horizontaux glissants par statut de sprint, cartes épurées, Bottom Sheets modales pour la création et le détail des tickets).
5. **Contexte Homelab** :
   - L'application permet de configurer dynamiquement l'URL du serveur backend (ex. `http://192.168.1.50:8080` ou `https://disciplan.example.com`) dès l'écran d'accueil, avec vérification de disponibilité via `GET /api/setup/status`.

---

## 2. Arborescence Cible (`src/Disciplaner.Flutter`)

```text
src/Disciplaner.Flutter/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                  # MaterialApp.router + raccourcis clavier globaux
│   │   ├── router.dart               # GoRouter + StatefulShellRoute adaptatif
│   │   └── theme/
│   │       ├── neo_colors.dart       # Palette exacte DESIGN.md
│   │       ├── neo_typography.dart   # Plus Jakarta Sans + JetBrains Mono
│   │       ├── neo_spacing.dart      # Rythme 4px, rayons (sm, md, lg, xl, full)
│   │       └── neo_theme.dart        # ThemeData complet
│   ├── core/
│   │   ├── errors/                   # Exceptions réseau & messages utilisateur
│   │   ├── network/                  # Dio, AuthInterceptor, BaseUrlInterceptor
│   │   ├── storage/                  # ServerConfigStorage & TokenStorage
│   │   ├── shortcuts/                # Intents & Actions clavier (⌘K, C, E, S)
│   │   └── widgets/                  # KbdChip, StatusBadge, PriorityIcon, UserAvatar, NeoButton, NeoTextField
│   └── features/
│       ├── auth/                     # Server setup, first-run setup, login, invitations
│       ├── shell/                    # DesktopAppShell (VS Code), MobileAppShell
│       ├── projects/                 # Explorateur projet, création projet, statuts, membres
│       ├── my_tasks/                 # Vue "Mes Tâches" & Vue Liste haute densité + actions par lot
│       ├── sprints/                  # Cycles, métriques burn-down, création/clôture de sprint
│       ├── kanban/                   # Kanban Desktop (Drag & Drop) + Kanban Mobile (Tabs)
│       ├── tickets/                  # Modales création, Split Inspector Desktop, Detail Sheet Mobile, commentaires, pièces jointes, historique
│       ├── search/                   # Command Palette ⌘K
│       ├── calendar/                 # Calendrier des sprints & flux iCal
│       └── settings/                 # Profil, apparence, administration utilisateurs
└── test/                             # Tests unitaires et tests de widgets
```

---

## 3. Référentiel des Endpoints API .NET 10

| Domaine | Contrôleur Serveur | Routes Principales |
|---|---|---|
| **Setup initial** | `SetupController` | `GET /api/setup/status`, `POST /api/setup` |
| **Authentification** | `AuthController` | `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/invitation/{token}`, `POST /api/auth/register-invited` |
| **Projets** | `ProjectsController` | `GET /api/projects`, `GET /api/projects/{id}`, `POST /api/projects`, `PUT /api/projects/{id}`, `PUT /api/projects/{id}/defaults`, `DELETE /api/projects/{id}`, `POST /api/projects/{id}/statuses`, `PUT /api/projects/{id}/statuses/{statusId}`, `PUT /api/projects/{id}/statuses/{statusId}/move`, `DELETE /api/projects/{id}/statuses/{statusId}` |
| **Membres Projet** | `ProjectMembersController` | `GET /api/projects/{projectId}/members`, `POST /api/projects/{projectId}/members`, `PUT /api/projects/{projectId}/members/{userId}`, `DELETE /api/projects/{projectId}/members/{userId}` |
| **Sprints / Cycles** | `SprintsController` | `GET /api/sprints/active`, `GET /api/sprints/with-dates`, `GET /api/sprints/{id}`, `GET /api/projects/{projectId}/sprints`, `POST /api/projects/{projectId}/sprints`, `PUT /api/sprints/{id}`, `POST /api/sprints/{id}/start`, `POST /api/sprints/{id}/close`, `DELETE /api/sprints/{id}` |
| **Tickets** | `TicketsController` | `GET /api/projects/{projectId}/tickets/backlog`, `POST /api/projects/{projectId}/tickets`, `GET /api/sprints/{sprintId}/tickets`, `GET /api/tickets/mine`, `GET /api/tickets/{ticketId}`, `GET /api/tickets/by-ref/{projectKey}/{ticketNumber}`, `PUT /api/tickets/{ticketId}`, `PUT /api/tickets/{ticketId}/status`, `PUT /api/tickets/{ticketId}/sprint`, `DELETE /api/tickets/{ticketId}` |
| **Commentaires** | `CommentsController` | `GET /api/tickets/{ticketId}/comments`, `POST /api/tickets/{ticketId}/comments`, `GET /api/cards/{cardId}/comments`, `POST /api/cards/{cardId}/comments`, `PUT /api/comments/{commentId}`, `DELETE /api/comments/{commentId}` |
| **Historique & Activité** | `TicketHistoryController`, `ActivityController` | `GET /api/tickets/{ticketId}/history`, `GET /api/activity/recent` |
| **Pièces jointes** | `AttachmentsController` | `GET /api/attachments/ticket/{ticketId}`, `POST /api/attachments/ticket/{ticketId}`, `GET /api/attachments/{id}/download`, `DELETE /api/attachments/{id}` |
| **Labels** | `LabelsController` | `GET /api/boards/{boardId}/labels`, `POST /api/boards/{boardId}/labels`, `POST /api/tickets/{ticketId}/labels/{labelId}`, `DELETE /api/tickets/{ticketId}/labels/{labelId}` |
| **Vues sauvegardées** | `SavedViewsController` | `GET /api/saved-views`, `POST /api/saved-views`, `DELETE /api/saved-views/{id}` |
| **Calendrier & iCal** | `CalendarController`, `ICalController` | `GET /api/calendar/token`, `POST /api/calendar/token/regenerate`, `GET /api/ical/{token}/feed.ics` |
| **Utilisateurs & Admin** | `UsersController`, `AdminUsersController` | `GET /api/users/me`, `PUT /api/users/me/display-name`, `GET /api/admin/users`, `POST /api/admin/users`, `POST /api/admin/users/invite`, `PUT /api/admin/users/{id}/activate`, `PUT /api/admin/users/{id}/deactivate`, `PUT /api/admin/users/{id}/role` |

---

## 4. Correspondance Maquettes `ux/` $\leftrightarrow$ Lots d'Implémentation

| Lot | Maquettes de Référence | Périmètre |
|---|---|---|
| **Lot 01** | `ux/disciplan_neo_linear/DESIGN.md` | Socle Flutter, thème Neo-Linear, typographie et composants atomiques |
| **Lot 02** | Contrat API C# (`src/Disciplaner.Application/DTOs`) | Réseau Dio, configuration serveur Homelab, DTOs Dart et Authentification |
| **Lot 03** | `ux/disciplan_web_vue_projet_style_vs_code`, `ux/disciplan_mobile_tableau_de_sprint` | Navigation GoRouter, Shell Desktop style VS Code, Shell Mobile et raccourcis clavier |
| **Lot 04** | `ux/disciplan_web_cr_ation_de_projet`, `ux/disciplan_mobile_projets_cycles` | Projets, explorateur d'arborescence, création de projet et vue mobile Projets & Cycles |
| **Lot 05** | `ux/disciplan_web_mes_t_ches_style_vs_code`, `ux/disciplan_web_vue_projet_style_vs_code` | Vue Liste haute densité, vue "Mes Tâches", filtres, vues sauvegardées et actions groupées |
| **Lot 06** | `ux/disciplan_web_cr_ation_de_sprint` | Gestion des Sprints/Cycles, en-tête de métriques burn-down et planification de sprint |
| **Lot 07** | `ux/disciplan_web_vue_kanban_du_sprint`, `ux/disciplan_mobile_tableau_de_sprint` | Tableau Kanban Desktop avec Drag & Drop et Tableau de Sprint Mobile par onglets |
| **Lot 08** | `ux/disciplan_web_cr_ation_de_ticket`, `ux/disciplan_mobile_cr_ation_de_ticket`, `ux/disciplan_mobile_d_tail_du_ticket` | Création de ticket (Web/Mobile), Split Inspector Desktop, Bottom Sheet détail Mobile, commentaires, fichiers et historique |
| **Lot 09** | `ux/disciplan_neo_linear/DESIGN.md` (Command Palette) | Command Palette `⌘K`, Calendrier/iCal, Paramètres et Administration |
| **Lot 10** | Ensemble du projet `src/Disciplaner.Flutter` | Suite de tests automatisés, configuration multiplateforme et documentation finale |
