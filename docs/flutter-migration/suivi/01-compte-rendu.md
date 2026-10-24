# Compte Rendu — Lot 01 : Socle Flutter Multiplateforme & Design System Neo-Linear

## 1. Périmètre Réalisé & Fichiers Créés

- **Création du projet Flutter multiplateforme** :
  - Emplacement : `src/Disciplaner.Flutter/`
  - Package : `disciplaner_flutter` (organisation `com.disciplan`)
  - Cibles : Web, Android, iOS, Windows, macOS, Linux
  - Dépendances ajoutées : `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `google_fonts`, `intl`, `equatable`.
  - `.gitignore` mis à jour à la racine du dépôt pour ignorer les artefacts de build Flutter.

- **Tokens & Thème Neo-Linear (`lib/app/theme/`)** :
  - `neo_colors.dart` : Tokens exacts de `DESIGN.md` (`#FBF9F4`, `#FFFFFF`, `#1A1917`, `#E5A800`, `#10B981`, `#F59E0B`, `#9CA3AF`, `#BA1A1A`, `#181715`, `#E4E0D7`, etc.).
  - `neo_typography.dart` : Échelle typographique basée sur `Plus Jakarta Sans` et `JetBrains Mono` avec hauteurs de ligne et espacements exacts.
  - `neo_spacing.dart` : Grille 4px, marges et rayons de courbure (`roundedSm: 4`, `roundedMd: 6`, `roundedLg: 8`, `roundedXl: 12`, `roundedFull: 9999`).
  - `neo_theme.dart` : `ThemeData` complet (zéro ombre lourde, bordures 1px whisper, focus `#1A1917`).

- **Composants Atomiques (`lib/core/widgets/`)** :
  - `KbdChip` (`kbd_chip.dart`) : Touche de raccourci clavier tactile avec relief 1px.
  - `StatusBadge` (`status_badge.dart`) : Pillule 22px avec teintes sémantiques (`ToDo`, `InProgress`, `Done`).
  - `PriorityIcon` & `TicketTypeIcon` (`priority_icon.dart`) : Icônes des 4 priorités et 5 types de tickets.
  - `UserAvatar` (`user_avatar.dart`) : Avatar circulaire compact avec initiales monospace et pastille de présence.
  - `NeoButton` (`neo_button.dart`) : Boutons Primary, Secondary, Ghost, Destructive, Kinetic.
  - `NeoTextField` (`neo_text_field.dart`) : Champs structurés et inline.
  - `NeoCard` (`neo_card.dart`) : Cartes surfaces `#FFFFFF` avec bordure whisper et micro-ombres d'overlay.

- **Tests unitaires et de widgets (`test/theme_and_widgets_test.dart`)** :
  - Validation des tokens de `NeoTheme`.
  - Rendu et interactions des composants atomiques.
  - Rendu de l'écran vitrine `DisciplanApp`.

---

## 2. Décisions Techniques

1. **Uniformité des bordures et arrondis** : Remplacement des bordures asymétriques par une bordure 1px uniforme combinée à une ombre portée plate 1px (`BoxShadow(offset: Offset(0, 1), blurRadius: 0)`) pour garantir la compatibilité absolue avec le moteur de rendu Flutter sur les widgets arrondis (`KbdChip`).
2. **Gestion offline des polices dans les tests** : Configuration `GoogleFonts.config.allowRuntimeFetching = false` dans `setUpAll` afin d'éviter les requêtes réseau superflues en environnement de test unitaire.

---

## 3. Résultats de Validation

- `flutter analyze` : **0 erreur, 0 warning**
- `flutter test` : **3 tests passés avec succès**

---

## 4. Statut des Critères d'Acceptation

| Critère | Statut |
|---|---|
| Création de `src/Disciplaner.Flutter` multiplateforme | **PASS** |
| Dépendances nécessaires installées | **PASS** |
| Définition complète des tokens Neo-Linear (`neo_colors`, `neo_typography`, `neo_spacing`, `neo_theme`) | **PASS** |
| Implémentation des 7 composants atomiques du Design System | **PASS** |
| Tests de widgets et du thème validés | **PASS** |
| `flutter analyze` sans erreur | **PASS** |
