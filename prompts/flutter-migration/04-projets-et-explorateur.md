# Lot 04 — Gestion des Projets, Explorateur Latéral & Création de Projet

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 03 terminé et commité (`docs/flutter-migration/suivi/03-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `src/Disciplaner.Web/Server/Controllers/ProjectsController.cs`
- `src/Disciplaner.Web/Server/Controllers/ProjectMembersController.cs`
- `ux/disciplan_web_cr_ation_de_projet/code.html`
- `ux/disciplan_web_vue_projet_style_vs_code/code.html`
- `ux/disciplan_mobile_projets_cycles/code.html`

## Travail à réaliser

1. **Repository & Providers Riverpod des Projets (`lib/features/projects/`)** :
   - Implémente `ProjectRepository` couvrant :
     - `GET /api/projects`, `GET /api/projects/{id}`, `POST /api/projects`, `PUT /api/projects/{id}`, `PUT /api/projects/{id}/defaults`, `DELETE /api/projects/{id}`
     - Gestion des statuts personnalisés du projet : `POST /api/projects/{id}/statuses`, `PUT /api/projects/{id}/statuses/{statusId}`, `PUT /api/projects/{id}/statuses/{statusId}/move`, `DELETE /api/projects/{id}/statuses/{statusId}`
     - Membres du projet : `GET /api/projects/{projectId}/members`, ajout/modification de rôle/retrait.
   - Crée les providers Riverpod : `projectsListProvider`, `selectedProjectIdProvider`, `currentProjectDetailProvider`.

2. **Explorateur de Projet dans la Primary Sidebar Desktop** :
   - En suivant `ux/disciplan_web_vue_projet_style_vs_code/code.html` :
     - Sélecteur du projet actif en haut de la barre latérale et dans le Breadcrumb de la Top Bar.
     - Sections pliables/dépliables (`PLAN DU PROJET`) :
       - **VUES DU PROJET** : Vue Liste (avec compteur de tickets), Tableau Kanban, Calendrier & Jalons.
       - **PLANNING & CYCLES** : Liste des sprints du projet (Actif avec pastille ambre animée, Planifiés, Clôturés) et accès au Backlog.
       - **WORKFLOW & ÉQUIPE** : Statuts du projet (ToDo, InProgress, Done) et membres du projet avec bouton d'accès aux réglages du projet.
     - En bas de la Sidebar : Jauge de capacité / progression du sprint actif.

3. **Vue Mobile "Projets & Cycles" (`lib/features/projects/presentation/mobile_projects_view.dart`)** :
   - Reproduis fidèlement `ux/disciplan_mobile_projets_cycles/code.html` :
     - En-tête synthétique et filtres par état.
     - Cartes de projets affichant la clé (`DISC`), le nom, la description, la progression des tickets, le sprint actif rattaché et les avatars des membres.
     - Section des cycles actifs/à venir et bouton d'action pour créer un nouveau projet.

4. **Création & Configuration de Projet (`lib/features/projects/presentation/create_project_modal.dart`)** :
   - Reproduis `ux/disciplan_web_cr_ation_de_projet/code.html` :
     - Saisie du nom du projet et génération automatique (ou édition manuelle) de la clé unique en majuscules (ex. `DISC`, 2 à 10 caractères en `JetBrains Mono`).
     - Description du projet.
     - Configuration des valeurs par défaut (`DefaultTicketType`, `DefaultAssigneePolicy`) et aperçu/personnalisation des statuts du workflow (`ToDo`, `InProgress`, `Done`).
     - Validation complète et rafraîchissement immédiat de `projectsListProvider` après création.

5. **Tests unitaires et de widgets** :
   - Tests unitaires du `ProjectRepository` et de la génération automatique de clé de projet.
   - Tests de widgets de la modale de création de projet et de la vue mobile `MobileProjectsView`.

## Critères d'acceptation

- L'utilisateur peut lister ses projets, changer de projet actif, créer un nouveau projet avec sa clé unique et configurer les statuts et membres du projet.
- L'explorateur latéral Desktop et la vue mobile `Projets & Cycles` respectent fidèlement les maquettes `ux/`.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/04-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): add project explorer, mobile projects view and project creation`
