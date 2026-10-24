# Compte Rendu — Lot 03 : Shell Adaptatif Multiplateforme (VS Code Desktop & Mobile) & Navigation

## 1. Périmètre Réalisé & Fichiers Créés

- **Architecture de Routage (`lib/app/router.dart`)** :
  - `GoRouter` dynamique réagissant aux transitions de session d'`AuthNotifier`.
  - Redirections automatisées vers `/setup` (si premier démarrage), `/login` (si non authentifié), et `/projects` (si authentifié).
  - Routes métier sous `ShellRoute` : `/projects`, `/my-tasks`, `/kanban`, `/cycles`, `/calendar`, `/settings`.

- **Shell Desktop & Web Style VS Code (`lib/features/shell/presentation/desktop_app_shell.dart`)** :
  - Déclenché sur les résolutions larges ($\ge 840\text{px}$).
  - **Top Title / Command Bar (44px)** :
    - Fil d'Ariane à gauche : `Disciplan > [Section] > Cycle 1` avec pastille or `#E5A912`.
    - Recherche centrale rapide avec raccourci `⌘K` intégré (`KbdChip`).
    - Actions rapides à droite : filtres, split view toggle, bouton primaire `+ Nouvelle tâche` avec `KbdChip('C')`, avatar utilisateur avec statut en ligne et déconnexion.
  - **Activity Bar (52px, fond sombre `#181715`)** :
    - Logo `D` en `JetBrains Mono` dans un carré `#2C2A26` avec texte `#FFD21E`.
    - Icônes de navigation avec barre active verticale 3px `#FFD21E` (Explorateur de projets, Mes Tâches avec compteur 4, Tableau Kanban, Cycles & Roadmap, Calendrier, Recherche ⌘K).
    - Section basse avec Paramètres (`⌘,`) et profil.
  - **Primary Sidebar repliable (240px, fond `#F4F1EA`)** :
    - En-tête avec bouton pour replier/déplier la barre latérale (`dock_to_left` / `⌘B`).
    - Liste arborescente stylisée avec compteurs numériques monospace.

- **Shell Mobile (`lib/features/shell/presentation/mobile_app_shell.dart`)** :
  - Déclenché sur les résolutions mobiles ($< 840\text{px}$).
  - En-tête fixe `SafeArea` avec logo `D`, titre de la vue active, bouton recherche et avatar utilisateur.
  - Bouton d'action flottant (FAB) pour la création rapide de ticket.
  - Barre de navigation basse responsive épurée Neo-Linear (Projets, Sprint, Tâches, Cycles, Paramètres).

- **Adaptive Shell (`lib/features/shell/presentation/adaptive_app_shell.dart`)** :
  - `LayoutBuilder` basculant en toute fluidité entre Desktop ($\ge 840\text{px}$) et Mobile ($< 840\text{px}$).

- **Système de Raccourcis Clavier Globaux (`lib/core/shortcuts/app_shortcuts.dart`)** :
  - `Ctrl+K` / `Meta+K` : Déclenchement de la Command Palette.
  - `Ctrl+B` / `Meta+B` : Basculement de la Primary Sidebar sur Desktop.
  - Touche `C` : Déclenchement de la création rapide de tâche (avec protection focus champs de saisie).

- **Vues Placeholders (`lib/features/shell/presentation/shell_placeholders.dart`)** :
  - Cartes épurées pour `/projects`, `/my-tasks`, `/kanban`, `/cycles`, `/calendar`, `/settings`.

- **Tests de widgets (`test/shell_and_navigation_test.dart`)** :
  - Basculement responsive Desktop (1440x900) vs Mobile (390x844).
  - Repliement et réouverture de la Primary Sidebar (icônes d'en-tête et Top Bar).
  - Validation du système d'Intents/Actions de raccourcis clavier.

---

## 2. Décisions Techniques

1. **Robustesse de la densité responsive** : Encapsulation flexible (`Expanded` et `Flexible` avec `TextOverflow.ellipsis`) de la barre de recherche centrale Desktop et des onglets de navigation Mobile afin de prévenir tout débordement `RenderFlex` sur les largeurs compactes.
2. **Gestion d'état réactive Riverpod 3 pour les raccourcis** : Implémentation des Notifiers `SidebarCollapsedNotifier`, `CommandPaletteOpenNotifier` et `QuickCreateTicketOpenNotifier` permettant à n'importe quel écran ou modale d'interagir avec les raccourcis système globaux sans couplage direct.

---

## 3. Résultats de Validation

- `flutter analyze` : **0 erreur, 0 warning**
- `flutter test` : **16 tests passés avec succès** (4 dans `shell_and_navigation_test.dart`, 9 dans `models_and_auth_test.dart`, 3 dans `theme_and_widgets_test.dart`)

---

## 4. Statut des Critères d'Acceptation

| Critère | Statut |
|---|---|
| Layout Desktop VS Code ($\ge 840\text{px}$) avec Activity Bar 52px, Top Bar 44px et Sidebar 240px | **PASS** |
| Layout Mobile ($< 840\text{px}$) tactile avec SafeArea et Bottom Bar | **PASS** |
| Raccourcis clavier globaux (`⌘K`, `⌘B`, `C`) branchés via Flutter Actions | **PASS** |
| Routage GoRouter avec protection d'authentification et redirections | **PASS** |
| `flutter analyze` et `flutter test` sans erreur | **PASS** |
