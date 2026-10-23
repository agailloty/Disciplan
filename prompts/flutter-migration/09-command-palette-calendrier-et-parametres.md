# Lot 09 — Command Palette (`⌘K`), Calendrier / iCal, Paramètres & Administration

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 08 terminé et commité (`docs/flutter-migration/suivi/08-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `ux/disciplan_neo_linear/DESIGN.md` (section *The Command Palette (`⌘K`)*)
- `src/Disciplaner.Web/Server/Controllers/CalendarController.cs`, `ICalController.cs`
- `src/Disciplaner.Web/Server/Controllers/UsersController.cs`, `AdminUsersController.cs`, `ActivityController.cs`

## Travail à réaliser

1. **Command Palette Globale (`⌘K` / `Ctrl+K`) (`lib/features/search/`)** :
   - Implémente l'overlay de la Command Palette conformément aux spécifications exactes de `DESIGN.md` :
     - Feuille flottante centrée en haut (largeur max 640px), fond `#FFFFFF`, ombre douce `0 8px 30px rgba(26, 25, 23, 0.06)`.
     - Champ de recherche sans bordure avec focus automatique (`headlineSm`).
     - Navigation intégrale au clavier (Flèche Haut, Flèche Bas, Entrée pour exécuter, Échap pour fermer) :
       - La ligne active est teintée en `#F2EFE8` et marquée d'une barre verticale gauche `#E5A800` de 3px.
     - Résultats regroupés par catégories :
       - **Tickets** : Recherche instantanée par titre ou par référence exacte (ex. `DISC-14` via `/api/tickets/by-ref/...` ou filtrage local) affichant le titre à gauche et l'ID en `JetBrains Mono` à droite.
       - **Actions rapides** : Créer une tâche (`C`), Créer un sprint, Créer un projet, Changer de projet actif.
       - **Navigation** : Aller vers Mes Tâches, Tableau Kanban, Vue Liste, Calendrier, Paramètres.

2. **Calendrier d'Équipe & Intégration iCal (`lib/features/calendar/`)** :
   - Consomme `GET /api/sprints/with-dates`, `GET /api/calendar/token` et `POST /api/calendar/token/regenerate`.
   - Affiche un calendrier mensuel / chronologique visualisant les sprints actifs et planifiés ainsi que les tickets dotés d'une date d'échéance (`dueDate`).
   - Permet de copier l'URL du flux iCal (`{serverUrl}/api/ical/{token}/feed.ics`) et de régénérer le jeton privé en un clic.

3. **Paramètres Utilisateur & Panneau d'Administration (`lib/features/settings/`)** :
   - **Profil & Préférences** :
     - Modification du nom d'affichage (`PUT /api/users/me/display-name`).
     - Configuration de l'URL du serveur Homelab et déconnexion.
     - Gestion des vues sauvegardées épinglées.
   - **Administration (visible si l'utilisateur possède le rôle `Admin`)** :
     - Consomme `AdminUsersController` (`GET /api/admin/users`, `POST /api/admin/users`, `POST /api/admin/users/invite`, `PUT /api/admin/users/{id}/activate`, `PUT /api/admin/users/{id}/deactivate`, `PUT /api/admin/users/{id}/role`).
     - Liste des comptes utilisateurs avec statut actif/inactif, rôle (`User` / `Admin`), génération de lien d'invitation à usage unique (valable 7 jours) avec copie dans le presse-papiers.

4. **Flux d'Activité Récente (`ActivityController`)** :
   - Connecte le bouton Notifications / Activité de l'Activity Bar à `GET /api/activity/recent` pour afficher un panneau latéral des dernières actions de l'équipe.

5. **Tests unitaires et de widgets** :
   - Teste l'ouverture de la Command Palette, le filtrage par texte et la sélection au clavier.
   - Teste l'écran de paramètres et la génération d'invitation admin.

## Critères d'acceptation

- La Command Palette `⌘K` / `Ctrl+K` est accessible depuis n'importe quel écran et respecte le design Neo-Linear.
- Le calendrier, le flux iCal, le profil utilisateur et l'administration des comptes fonctionnent de bout en bout.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/09-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): add command palette, calendar view, settings and admin management`
