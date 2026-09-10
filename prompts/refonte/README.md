# Prompts de refonte de Disciplan

Ce dossier contient 14 lots d'implémentation, à exécuter dans l'ordre. Les documents de référence sont [l'audit](../../docs/refonte/01-audit-disciplan.md) et [le plan de migration](../../docs/refonte/02-plan-de-migration.md).

## Mode d'emploi

Donner à l'agent le contenu du [contrat commun](00-contrat-agent.md), puis un seul prompt numéroté. Un agent avec accès au dépôt peut recevoir cette instruction :

> Lis prompts/refonte/00-contrat-agent.md puis prompts/refonte/01-baseline.md et exécute ce lot. Produis les changements et preuves demandés, puis son compte rendu. Ne passe pas au lot suivant avant validation de ses critères.

Pour les lots suivants, remplacer le chemin par celui de la ligne correspondante. Une nouvelle session doit relire les documents et comptes rendus des prérequis. Les chemins de code abrégés dans les prompts désignent des fichiers voisins du premier chemin explicite ; les retrouver dans le dépôt si nécessaire.

## Ordre des lots

| Lot | Prompt | Résultat |
|---|---|---|
| 01 | [Établir la référence et le cadre de recette](01-baseline.md) | Aucun lot préalable ; lire les deux documents de refonte. |
| 02 | [Corriger les droits et l'intégrité du cœur](02-droits-integrite.md) | Lot 01 terminé. |
| 03 | [Ajouter le modèle canonique et les contrats compatibles](03-modele-canonique.md) | Lot 02 terminé. |
| 04 | [Construire et répéter la conversion des tableaux](04-conversion.md) | Lot 03 terminé. |
| 05 | [Refondre le système de composants et la navigation](05-design-navigation.md) | Lots 03 et 04 terminés. |
| 06 | [Créer la recherche et les vues de tickets cohérentes](06-recherche-vues.md) | Lot 05 terminé. |
| 07 | [Unifier la fiche et la création de tickets](07-fiche-creation.md) | Lot 06 terminé. |
| 08 | [Livrer un backlog priorisable et un tableau unifié](08-backlog-kanban.md) | Lot 07 terminé. |
| 09 | [Renforcer les workflows et les relations métier](09-workflows-relations.md) | Lot 08 terminé. |
| 10 | [Achever la planification et la clôture des sprints](10-sprints.md) | Lot 09 terminé. |
| 11 | [Ajouter mentions et notifications utiles](11-collaboration.md) | Lot 10 terminé. |
| 12 | [Ajouter jalons et rapports fiables](12-pilotage.md) | Lot 11 terminé. |
| 13 | [Permettre import/export et automatisations limitées](13-echanges-automatisations.md) | Lot 12 terminé. |
| 14 | [Valider la version et préparer la bascule](14-recette-bascule.md) | Lots 01–13 terminés ; pour une version cœur après 10, déclarer 11–13 hors version. |

Pour une première version limitée au cœur après le lot 10, exécuter le lot 14 en déclarant 11–13 hors version. Les lots différés restent à réaliser avant de revendiquer leur disponibilité.

## Traçabilité audit → prompts

| Constats | Lots de traitement |
|---|---|
| A01–A04 : accès et relations invalides | 02, vérification transversale 06/11/14 |
| A05 : effacement/historique | 02, 07 |
| A06 : double modèle | 03, 04, 07, 08 |
| A07 : backlog/rang | 03, 08 |
| A08 : sprint | 02, 10 |
| A09 : transitions | 09 |
| A10 : volume/requêtes | 06, 12, 14 |
| A11 : numérotation concurrente | 02, 03 |
| A12–A13 : composants et parcours | 05, 07, 14 |
| A14 : migration/exploitation | 01, 04, 14 |
| A15 : fonctionnalités avancées | 09, 11, 12, 13 |

Les comptes rendus seront créés par l'agent pendant l'implémentation ; leur absence aujourd'hui signifie que les lots ne sont pas encore exécutés. Aucun changement de l'application n'a été réalisé par la préparation de ce dossier.
