# Prompts de Migration Flutter Multiplateforme — Disciplan

Ce dossier contient le **Prompt Maître** ainsi que **10 lots séquentiels** permettant à un agent de codage d'implémenter de bout en bout le nouveau front-end multiplateforme **Flutter** (Mobile, Web, Desktop) de Disciplan dans `src/Disciplaner.Flutter/`, sans modifier l'API backend .NET 10 existante.

Chaque lot correspond à **une unité de travail autonome, vérifiable et suivie d'un commit Git automatique** sur la branche `feat/flutter-migration`.

---

## Mode d'Emploi

### Option A — Exécution lot par lot (Recommandé pour contrôle granulaire)

Fournissez cette instruction à votre agent de codage pour lancer un lot précis (en remplaçant le numéro du lot) :

```text
Lis prompts/flutter-migration/00-prompt-maitre.md puis exécute intégralement le lot décrit dans prompts/flutter-migration/01-socle-et-design-system.md. Vérifie flutter analyze et flutter test, rédige le compte rendu de suivi et réalise le commit Git en autonomie à la fin du lot.
```

### Option B — Exécution séquentielle autonome complète (Mode `/goal`)

Si vous souhaitez que l'agent enchaîne tous les lots en autonomie avec un commit propre à chaque étape :

```text
Lis prompts/flutter-migration/00-prompt-maitre.md et prompts/flutter-migration/README.md. Exécute dans l'ordre les lots 01 à 10 du dossier prompts/flutter-migration/. Pour chaque lot : implémente l'intégralité des fonctionnalités demandées, valide avec flutter analyze et flutter test, crée le compte rendu dans docs/flutter-migration/suivi/, et effectue immédiatement le commit Git autonome prescrit avant de passer au lot suivant.
```

---

## Séquence des Lots & Commits Attendus

| Lot | Fichier Prompt | Objectif Principal | Message de Commit Attendu |
|---|---|---|---|
| **00** | [`00-prompt-maitre.md`](00-prompt-maitre.md) | Contrat d'exécution, règles de qualité, suivi et commit Git autonome | *(Prompt de cadrage)* |
| **01** | [`01-socle-et-design-system.md`](01-socle-et-design-system.md) | Création du projet `src/Disciplaner.Flutter`, thème **Neo-Linear** (`DESIGN.md`) et composants atomiques | `feat(flutter): initialize multiplatform project and Neo-Linear design system` |
| **02** | [`02-reseau-modeles-et-auth.md`](02-reseau-modeles-et-auth.md) | Client Dio, configuration dynamique de l'URL Homelab, DTOs C# $\rightarrow$ Dart, Setup initial et Authentification JWT | `feat(flutter): implement network layer, API models, homelab config and authentication` |
| **03** | [`03-shell-adaptatif-et-navigation.md`](03-shell-adaptatif-et-navigation.md) | Routage `GoRouter`, Shell Desktop style VS Code (Activity Bar 52px + Sidebar + Top Bar), Shell Mobile et raccourcis clavier | `feat(flutter): build responsive VS Code desktop shell, mobile shell and router` |
| **04** | [`04-projets-et-explorateur.md`](04-projets-et-explorateur.md) | Explorateur de projets latéral, vue mobile *Projets & Cycles*, création de projet et workflow de statuts | `feat(flutter): add project explorer, mobile projects view and project creation` |
| **05** | [`05-mes-taches-et-vue-liste.md`](05-mes-taches-et-vue-liste.md) | Vue *Mes Tâches* et Vue Liste haute densité style VS Code, création inline, vues sauvegardées et actions groupées | `feat(flutter): implement VS Code dense task list, my tasks view and batch actions` |
| **06** | [`06-sprints-et-cycle-planning.md`](06-sprints-et-cycle-planning.md) | Gestion des Sprints/Cycles, bandeau de métriques burn-down/vélocité et modale de planification de sprint | `feat(flutter): implement sprint lifecycle, metrics header and sprint creation` |
| **07** | [`07-tableau-kanban-multiplateforme.md`](07-tableau-kanban-multiplateforme.md) | Tableau Kanban Desktop (Drag & Drop optimiste) et Tableau de Sprint Mobile par onglets horizontaux | `feat(flutter): build desktop drag-and-drop kanban board and mobile tabbed sprint board` |
| **08** | [`08-creation-et-detail-ticket.md`](08-creation-et-detail-ticket.md) | Modales de création de ticket (Web/Mobile), Split Inspector Desktop, Bottom Sheet détail Mobile, sous-tâches, commentaires, fichiers et historique | `feat(flutter): implement ticket creation modals, split inspector and mobile detail sheet` |
| **09** | [`09-command-palette-calendrier-et-parametres.md`](09-command-palette-calendrier-et-parametres.md) | Command Palette globale (`⌘K` / `Ctrl+K`), Calendrier & flux iCal, Paramètres et Administration des utilisateurs | `feat(flutter): add command palette, calendar view, settings and admin management` |
| **10** | [`10-tests-packaging-et-documentation.md`](10-tests-packaging-et-documentation.md) | Suite complète de tests unitaires/widgets, validation du build Web/Multiplateforme et documentation Homelab | `test(flutter): add integration widget tests and finalize multiplatform build documentation` |

---

## Documents de Référence Associés

- **Architecture & Plan de Migration** : [`docs/flutter-migration/01-architecture-et-plan.md`](../../docs/flutter-migration/01-architecture-et-plan.md)
- **Design System Neo-Linear** : [`ux/disciplan_neo_linear/DESIGN.md`](../../ux/disciplan_neo_linear/DESIGN.md)
- **Maquettes HTML & Captures d'écran** : [`ux/`](../../ux/)
- **Rapports d'exécution de l'agent** : `docs/flutter-migration/suivi/01-compte-rendu.md` à `10-compte-rendu.md`
