# Lot 10 — Recette Multiplateforme, Suite de Tests Complète & Documentation Finale

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lots 01 à 09 terminés et commités (`docs/flutter-migration/suivi/01-compte-rendu.md` à `09-compte-rendu.md` présents).

## Fichiers de référence à inspecter

- `src/Disciplaner.Flutter/`
- `docs/flutter-migration/01-architecture-et-plan.md`
- `README.md`

## Travail à réaliser

1. **Audit de Cohérence & Finitions Multiplateformes** :
   - Vérifie qu'aucun `TODO`, code mort, import inutilisé ou donnée fictive ne subsiste dans `src/Disciplaner.Flutter/lib/`.
   - Vérifie la gestion propre de tous les états UI sur chaque écran : chargement (squelettes/indicateurs sobres Neo-Linear), état vide explicite avec action, et erreur réseau avec bouton "Réessayer".
   - Vérifie l'absence totale d'erreurs de mise en page (`RenderFlex overflow`) aussi bien en format Mobile étroit (`360x780`) qu'en format Tablette (`768x1024`) et Desktop large (`1920x1080`).

2. **Renforcement de la Suite de Tests (`src/Disciplaner.Flutter/test/`)** :
   - Assure-toi que la suite de tests couvre de bout en bout :
     - La sérialisation de tous les DTOs et la gestion du stockage d'URL Homelab.
     - Le flux d'authentification (Configuration serveur $\rightarrow$ Login $\rightarrow$ Redirection vers le Shell).
     - Le basculement adaptatif entre `DesktopAppShell` et `MobileAppShell`.
     - La création de projet, la création de sprint et la création de ticket.
     - Le changement de statut dans le Kanban et la sélection multiple dans la vue Liste dense.
     - La recherche et navigation dans la Command Palette (`⌘K`).

3. **Validation de la Compilation Multiplateforme** :
   - Exécute `flutter analyze` et `flutter test`.
   - Exécute `flutter build web` pour valider la compilation de production Web (et teste la compilation desktop native de l'OS courant si supportée par l'environnement).
   - Nettoie les fichiers temporaires de build pour garder un arbre Git propre.

4. **Documentation d'Exploitation & de Déploiement Homelab** :
   - Crée `docs/flutter-migration/README.md` détaillant :
     - L'architecture de l'application Flutter (`src/Disciplaner.Flutter`).
     - Les commandes de développement et de build pour **Web**, **Android**, **iOS**, **Windows**, **macOS** et **Linux**.
     - Le guide de configuration CORS sur l'API .NET 10 (`Cors__Origins__0`) et de connexion depuis un réseau local Homelab ou un reverse-proxy (Traefik / Nginx).
   - Mets à jour le `README.md` à la racine du dépôt pour mentionner le nouveau client multiplateforme Flutter (`src/Disciplaner.Flutter`) aux côtés du serveur API .NET 10.

## Critères d'acceptation

- `flutter analyze` retourne `No issues found!`.
- `flutter test` exécute l'intégralité de la suite de tests avec 100% de réussite.
- `flutter build web` réussit sans erreur.
- Les 10 comptes rendus (`01` à `10`) sont complets dans `docs/flutter-migration/suivi/`.

## Livrables & Commit Autonome

1. Rédige le compte rendu final dans `docs/flutter-migration/suivi/10-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `test(flutter): add integration widget tests and finalize multiplatform build documentation`
