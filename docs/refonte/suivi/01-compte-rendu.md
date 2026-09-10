# Lot 01 — Référence, tests et recette initiale

Date : 11 septembre 2026. Référence de départ : 3cff211. Lot terminé pour son périmètre de baseline, sans certification de la refonte.

## Livré

- Audit et série de prompts conservés dans Git avec les décisions et l'inventaire de référence.
- Projet xUnit dans la solution ; host API authentifié, migrations EF sur SQLite temporaire et fichiers factices.
- Fixtures reproductibles avec propriétaire, Supervisor, Member, Guest, membre retiré et tiers ; projets isolés, cartes, tickets, commentaires et fichiers.
- Fixture volume distincte : 10 000 tickets, 20 projets, 50 comptes.
- Playwright/Chromium : setup via UI, recherche de projet, lecture ticket, commentaire via UI, lecture sprint/calendrier et captures 1440/390 px. Les créations projet/ticket/sprint sont préparées par API, pas revendiquées comme recette UI.
- CI pull requests : build, tests domaine/API et navigateur, conservation des rapports ; aucune publication.
- Entrée Program rendue accessible au host de test.

## Correction minimale révélée par la baseline

Les tests membre retiré/non-membre ont reproduit un défaut HTTP : ForbiddenException héritait directement d'Exception, tandis que plusieurs contrôleurs interceptaient UnauthorizedAccessException. La classe hérite désormais d'UnauthorizedAccessException : le refus métier existant devient une réponse 403. Cette correction nécessaire à la référence testable est anticipée du lot 02 ; elle ne corrige pas les requêtes qui omettent elles-mêmes les permissions.

## Exécution

| Commande / contrôle | Résultat |
|---|---|
| dotnet restore Disciplaner.slnx --force --nologo | Réussi avec accès NuGet autorisé après erreur réseau du bac à sable |
| dotnet build Disciplaner.slnx --no-restore --nologo | Réussi, zéro erreur |
| dotnet test tests/Disciplaner.Tests/Disciplaner.Tests.csproj --no-restore --nologo | 10 réussites, 0 échec ; environ 27 secondes de tests |
| npm ci / installation initiale npm install | Dépendances Playwright installées, lockfile conservé |
| npx playwright install chromium | Réussi |
| npm test (Chromium) | Réussi : 1 parcours, 27,9 secondes, code de sortie 0 |
| git diff --check | Sans erreur de whitespace |

Deux dépendances existantes signalées par NuGet : SQLitePCLRaw.lib.e_sqlite3 2.1.11 et Microsoft.OpenApi 2.4.1. À traiter au lot 02, sans masquer les avertissements. Références : [avis SQLite](https://github.com/advisories/GHSA-2m69-gcr7-jv3q), [avis OpenAPI](https://github.com/advisories/GHSA-v5pm-xwqc-g5wc).

## Critères

| Critère du lot | État / preuve |
|---|---|
| Solution compilable | Pass |
| Fixtures isolées/recréables | Pass — bases temporaires migrées pour chaque test |
| API membre/non-membre | Pass — Ticket_detail_enforces_membership, sept identités/cas |
| Distinction inspection/exécution | Pass — inventaire statique séparé des tests |
| Jeu volume | Pass — compteurs exacts et dates déterministes vérifiés |

## Observations et limites

La capture mobile ticket montre la barre de commentaire fixe superposée à une partie des propriétés. À corriger avec le lot 07. Les cinq parcours disposent d'un protocole dans recette-baseline ; cette exécution est un smoke test, pas une recette exhaustive de priorisation, clôture, partage, accessibilité ou performance.

Le SDK local est 10.0.400-preview.0.26322.102 ; CI utilise .NET 10 stable. Le premier lancement Playwright dans le bac à sable a réussi ses assertions, mais l'arrêt de processus Windows a nécessité une interruption ; relance hors bac à sable pour contrôler le code de sortie. Aucun environnement utilisateur ni déploiement n'a été modifié.

Prochain lot : 02, droits et intégrité. Les agents ont aidé à produire l'inventaire et les squelettes de tests ; une limite d'utilisation a interrompu leurs tours, et l'intégration a été reprise localement.
