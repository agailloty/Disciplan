# Lot 01 — Socle Flutter Multiplateforme & Design System Neo-Linear

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Branche Git active : `feat/flutter-migration`.
- Lecture complète de [`ux/disciplan_neo_linear/DESIGN.md`](../../ux/disciplan_neo_linear/DESIGN.md).

## Fichiers de référence à inspecter

- `ux/disciplan_neo_linear/DESIGN.md`
- `ux/disciplan_web_vue_kanban_du_sprint/code.html`
- `ux/disciplan_mobile_tableau_de_sprint/code.html`

## Travail à réaliser

1. **Initialisation du projet Flutter** :
   - Crée le projet Flutter multiplateforme dans `src/Disciplaner.Flutter` (nom du package : `disciplaner_flutter`, organisation : `com.disciplan`) avec support `web`, `android`, `ios`, `windows`, `macos`, `linux`.
   - Configure `pubspec.yaml` avec les dépendances essentielles : `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `google_fonts`, `intl`, `equatable` (ou classes immuables équivalentes).
   - Mets à jour `.gitignore` à la racine du dépôt (ou dans `src/Disciplaner.Flutter/.gitignore`) pour ignorer les artefacts de build Flutter (`.dart_tool/`, `build/`, `.flutter-plugins*`, `ephemeral/`).

2. **Implémentation du Design System "Neo-Linear" (`lib/app/theme/`)** :
   - `neo_colors.dart` : Définis toutes les couleurs exactes de `DESIGN.md` :
     - `surface` / `background` (`#FBF9F4`), `surfaceContainerLowest` (`#FFFFFF`), `surfaceContainerLow` (`#F5F3EE`), `surfaceContainer` (`#F0EEE9`), `surfaceContainerHigh` (`#EAE8E3`), `surfaceContainerHighest` (`#E4E2DD`).
     - `primary` / `onSurface` (`#1A1917`), `onSurfaceVariant` (`#494740`), `outline` (`#7A776F`), `outlineVariant` / `borderWhisper` (`#E4E0D7`).
     - `secondary` (`#7B5900`), `secondaryContainer` / `kineticAmber` (`#E5A800` / `#FFBF28`).
     - `emerald` (`#10B981`), `statusAmber` (`#F59E0B`), `statusSlate` (`#9CA3AF`), `error` (`#BA1A1A`), `sidebarDark` (`#181715`).
   - `neo_typography.dart` : Configure l'échelle typographique basée sur `Plus Jakarta Sans` (`headlineXl`, `headlineXlMobile`, `headlineLg`, `headlineMd`, `headlineSm`, `bodyLg`, `bodyMd`, `bodySm`) et `JetBrains Mono` (`labelMd`, `labelSm`, `codeInline`) avec hauteurs de ligne et espacements exacts.
   - `neo_spacing.dart` : Constantes d'espacement sur grille 4px (`spaceXs: 4`, `spaceSm: 8`, `spaceMd: 12`, `spaceLg: 20`, `spaceXl: 32`) et rayons de bordure (`sm: 4`, `md: 6`, `lg: 8`, `xl: 12`, `full: 9999`).
   - `neo_theme.dart` : Construis le `ThemeData` complet exploitant ces tokens (zéro ombre lourde, bordures 1px `#E4E0D7`, focus `#1A1917`).

3. **Bibliothèque de composants atomiques (`lib/core/widgets/`)** :
   - `kbd_chip.dart` (`KbdChip`) : Touche de raccourci clavier en `JetBrains Mono` (`labelSm`), fond `#FFFFFF`, bordure 1px `#D8D4CA` et léger rebord inférieur 1px.
   - `status_badge.dart` (`StatusBadge`) : Pillule 22px (`rounded-full`) pour les catégories de statut (`ToDo` / Slate, `InProgress` / Amber, `Done` / Emerald) et statuts personnalisés.
   - `priority_icon.dart` (`PriorityIcon`) : Indicateur visuel pour les 4 priorités (`Low`, `Medium`, `High`, `Urgent`) et les 5 types de tickets (`Story`, `Bug`, `Task`, `Epic`, `Subtask`).
   - `user_avatar.dart` (`UserAvatar`) : Avatar circulaire compact avec initiales en `JetBrains Mono` et pastille de présence optionnelle.
   - `neo_button.dart` & `neo_text_field.dart` : Boutons Primary (`#1A1917`) / Secondary Ghost (`1px solid #E4E0D7`) et champs de saisie structurés ou inline.
   - `neo_card.dart` : Carte surface `#FFFFFF` avec bordure 1px `#E4E0D7` et micro-ombre optionnelle pour les overlays.

4. **Tests unitaires et de widgets** :
   - Écris un test dans `test/theme_and_widgets_test.dart` vérifiant l'instanciation du thème `NeoTheme` et le rendu de `KbdChip`, `StatusBadge`, `PriorityIcon`, `UserAvatar` et `NeoButton`.

## Critères d'acceptation

- `flutter analyze` dans `src/Disciplaner.Flutter` retourne 0 erreur.
- `flutter test` exécute et valide tous les tests de widgets du Design System.
- Tous les tokens de `ux/disciplan_neo_linear/DESIGN.md` sont fidèlement traduits en Dart.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/01-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie incluant `src/Disciplaner.Flutter`, `docs/flutter-migration/` et `.gitignore` avec le message exact :
   `feat(flutter): initialize multiplatform project and Neo-Linear design system`
