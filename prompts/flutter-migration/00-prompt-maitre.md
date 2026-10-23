# Prompt Maître — Contrat d'Exécution de l'Agent de Migration Flutter

Tu interviens dans le dépôt **Disciplan** en tant qu'agent d'ingénierie logicielle senior spécialisé en **Flutter multiplateforme** (Mobile iOS/Android, Web, Desktop) et en intégration d'API **.NET 10**.

Ton objectif est de réaliser la migration du front-end vers Flutter dans `src/Disciplaner.Flutter/`, lot par lot, en respectant scrupuleusement :
- L'architecture de référence : [`docs/flutter-migration/01-architecture-et-plan.md`](../../docs/flutter-migration/01-architecture-et-plan.md)
- Le Design System Neo-Linear : [`ux/disciplan_neo_linear/DESIGN.md`](../../ux/disciplan_neo_linear/DESIGN.md) et les maquettes HTML/PNG du dossier [`ux/`](../../ux/)
- Les contrats d'API du serveur existant : [`src/Disciplaner.Web/Server/Controllers/`](../../src/Disciplaner.Web/Server/Controllers/) et [`src/Disciplaner.Application/DTOs/`](../../src/Disciplaner.Application/DTOs/)

---

## Règles d'Exécution Impératives

1. **Vérification de la branche et de l'état Git** :
   - Au début de ton intervention, exécute `git status` et `git branch --show-current`.
   - Assure-toi d'être sur la branche dédiée `feat/flutter-migration` (si ce n'est pas le cas, bascule dessus ou crée-la avec `git checkout -b feat/flutter-migration`).
   - Consulte les comptes rendus des lots précédents dans `docs/flutter-migration/suivi/` pour connaître l'état d'avancement exact.

2. **Immuabilité du Backend .NET 10** :
   - La migration concerne **exclusivement le front-end**.
   - **Ne modifie pas** les projets C# (`Disciplaner.Domain`, `Disciplaner.Application`, `Disciplaner.Infrastructure`, `Disciplaner.Web/Server`).
   - Aligne tes modèles Dart et tes appels HTTP exactement sur les routes et DTOs existants du serveur .NET.

3. **Qualité d'Implémentation & Fidélité UX** :
   - Lis systématiquement les fichiers `code.html` des maquettes `ux/` associées au lot en cours avant de coder les écrans.
   - Respecte les couleurs (`#FBF9F4`, `#FFFFFF`, `#1A1917`, `#E5A800`, `#10B981`, `#E4E0D7`), les polices (`Plus Jakarta Sans` et `JetBrains Mono`), la densité visuelle et les comportements responsives (Desktop/Web style VS Code $\ge 840\text{px}$ vs Mobile $< 840\text{px}$).
   - Aucun écran factice, aucun bouton inerte ni donnée codée en dur dans les vues métier : chaque composant doit être branché de bout en bout (UI $\rightarrow$ Riverpod Provider $\rightarrow$ Repository $\rightarrow$ Dio API Client) avec gestion des états de chargement, d'erreur et de liste vide.

4. **Validation Technique Systématique** :
   - Avant de conclure un lot, exécute dans `src/Disciplaner.Flutter` :
     - `flutter pub get`
     - `flutter analyze` (aucune erreur ni warning bloquant)
     - `flutter test` (tous les tests existants et nouveaux doivent passer)
   - Corrige immédiatement toute erreur d'analyse ou de test avant de passer à l'étape du commit.

5. **Traçabilité & Compte Rendu** :
   - À la fin du lot `NN`, rédige un compte rendu synthétique dans `docs/flutter-migration/suivi/NN-compte-rendu.md` contenant :
     - Le périmètre réalisé et les fichiers créés/modifiés
     - Les décisions techniques prises
     - Les résultats exacts de `flutter analyze` et `flutter test`
     - Le statut des critères d'acceptation (`PASS` / `FAIL`)

6. **Commit Git Autonome (Obligatoire à chaque lot)** :
   - **Tu dois effectuer un commit Git en totale autonomie** dès que le lot et son compte rendu sont terminés et validés, sans attendre de confirmation de l'utilisateur.
   - N'ajoute au stage (`git add`) que les fichiers pertinents du lot (`src/Disciplaner.Flutter/`, `docs/flutter-migration/suivi/`, et les fichiers de configuration explicitement demandés).
   - Utilise exactement le message de commit conventionnel spécifié à la fin du prompt du lot.
   - Vérifie avec `git log -1` et `git status` que le commit est bien enregistré.
   - **Arrête-toi après le commit du lot demandé** (sauf si l'utilisateur t'ordonne explicitement d'enchaîner plusieurs lots).

---

## Comment utiliser ce Prompt Maître

Pour exécuter un lot (par exemple le Lot 01), fournis cette instruction à l'agent :

> Lis `prompts/flutter-migration/00-prompt-maitre.md` puis exécute intégralement le lot décrit dans `prompts/flutter-migration/01-socle-et-design-system.md`, jusqu'au commit Git autonome inclus.

Pour enchaîner tous les lots en mode autonome (ex. avec `/goal`), fournis cette instruction :

> Lis `prompts/flutter-migration/00-prompt-maitre.md` et `prompts/flutter-migration/README.md`. Exécute séquentiellement les lots `01` à `10` du dossier `prompts/flutter-migration/`. À la fin de chaque lot, vérifie `flutter analyze` et `flutter test`, rédige le compte rendu de suivi et réalise le commit Git autonome correspondant avant de passer au lot suivant.
