# Lot 03 — Shell Adaptatif Multiplateforme (VS Code Desktop & Mobile) & Navigation

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 02 terminé et commité (`docs/flutter-migration/suivi/02-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `ux/disciplan_web_vue_projet_style_vs_code/code.html`
- `ux/disciplan_web_vue_kanban_du_sprint/code.html`
- `ux/disciplan_mobile_tableau_de_sprint/code.html`
- `ux/disciplan_mobile_projets_cycles/code.html`

## Travail à réaliser

1. **Architecture de Routage (`lib/app/router.dart`)** :
   - Configure `GoRouter` réagissant à l'état d'authentification (`AuthStateNotifier`) :
     - Redirection automatique vers `/login` ou `/setup` si non authentifié.
     - Routes principales encapsulées dans un `ShellRoute` / `StatefulShellRoute` :
       - `/projects` (Explorateur & vue projet)
       - `/my-tasks` (Mes Tâches)
       - `/kanban` (Tableau Kanban du sprint actif ou sélectionné)
       - `/cycles` (Cycles, Sprints & Feuille de route)
       - `/calendar` (Calendrier d'équipe)
       - `/settings` (Paramètres & Administration)

2. **Shell Desktop & Web Style VS Code (`lib/features/shell/presentation/desktop_app_shell.dart`)** :
   - Activé dès que la largeur de fenêtre est $\ge 840\text{px}$.
   - Reproduis fidèlement la structure de `ux/disciplan_web_vue_projet_style_vs_code/code.html` :
     - **Top Title / Command Bar (hauteur 44px)** :
       - À gauche : Fil d'Ariane dynamique façon VS Code (`Disciplan > Projets > [Projet Actif] > [Cycle Actif]`) avec pastille dorée `#E5A912`.
       - Au centre : Bouton déclencheur de recherche rapide (`Rechercher une tâche, commande ou fichier...`) avec badge `KbdChip` (`⌘K`).
       - À droite : Boutons d'actions rapides (Filtres, Split View toggle, bouton primaire `+ Nouvelle tâche` avec `KbdChip` `C`, et avatar de l'utilisateur connecté).
     - **Activity Bar verticale gauche (largeur 52px, fond `#181715`)** :
       - Logo `D` en haut dans un carré `#2C2A26` avec texte `#FFD21E`.
       - Icônes de navigation avec indicateur actif vertical 3px `#FFD21E` à gauche : Explorateur de projets, Mes Tâches (avec badge compteur), Tableau Kanban, Cycles & Roadmap, Recherche globale (`⌘K`).
       - En bas : Notifications, Paramètres (`⌘,`), Avatar utilisateur avec pastille verte en ligne et bouton de déconnexion.
     - **Primary Sidebar repliable (largeur 240px, fond `#F4F1EA`)** :
       - Bouton pour replier/déplier la barre latérale (`dock_to_left`).
       - Contenu contextuel prêt à accueillir l'explorateur de projet (Lot 04).

3. **Shell Mobile (`lib/features/shell/presentation/mobile_app_shell.dart`)** :
   - Activé lorsque la largeur d'écran est $< 840\text{px}$.
   - Reproduis la structure de `ux/disciplan_mobile_tableau_de_sprint/code.html` et `ux/disciplan_mobile_projets_cycles/code.html` :
     - En-tête fixe `SafeArea` avec logo `D`, titre de la section courante, bouton recherche et avatar utilisateur.
     - Barre de navigation inférieure (`NavigationBar` / Bottom Bar épurée Neo-Linear) permettant de basculer entre : **Sprint**, **Projets**, **Mes Tâches**, **Paramètres**, ainsi qu'un bouton d'action rapide pour créer un ticket.

4. **Système de Raccourcis Clavier Globaux (`lib/core/shortcuts/`)** :
   - Configure les `Shortcuts` et `Actions` Flutter au niveau du shell pour intercepter :
     - `Ctrl+K` / `Meta+K` : Ouverture de la Command Palette (préparée par un état Riverpod).
     - `Ctrl+B` / `Meta+B` : Replier / Déplier la Primary Sidebar sur Desktop.
     - Touche `C` (hors champ de texte actif) : Déclenchement de la modale de création rapide de tâche.

5. **Tests de widgets** :
   - Teste le basculement automatique entre `DesktopAppShell` (taille `1440x900`) et `MobileAppShell` (taille `390x844`).
   - Teste le repliement de la Primary Sidebar et la navigation entre les sections.

## Critères d'acceptation

- Sur grand écran ($\ge 840\text{px}$), le layout VS Code (Top Bar + Activity Bar 52px + Sidebar repliable + Zone centrale) s'affiche fidèlement aux maquettes.
- Sur petit écran ($< 840\text{px}$), le layout mobile prend le relais sans débordement (`RenderFlex overflow`).
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/03-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): build responsive VS Code desktop shell, mobile shell and router`
