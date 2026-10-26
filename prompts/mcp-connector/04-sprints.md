# Lot 04 — Gestion des sprints

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 5.3 et 7.1 (M03, M04, M07). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 03 terminé. Vérifie `docs/mcp-connector/suivi/03-compte-rendu.md` avant de poursuivre.

## Fichiers de départ

`src/Disciplaner.Mcp/Tools/` et `src/Disciplaner.Mcp/Resolution/McpReferenceResolver.cs` ; `src/Disciplaner.Application/DTOs/Sprint/SprintRequests.cs` ; `src/Disciplaner.Application/Services/SprintService.cs` ; `src/Disciplaner.Domain/Entities/Sprint.cs`. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Implémente dans `SprintsTools` les outils d'écriture de sprint, tous protégés par la portée `read+write` du lot 03 :
   - `create_sprint` : `projectKey`, `name` ( ≤ `DomainConstraints.Sprint.NameMaxLength` ), `goal?` ( ≤ `GoalMaxLength` ), via `ISprintService.CreateAsync` ;
   - `start_sprint` : `sprintName` + `projectKey` ou `sprintId`, `startDate`, `endDate`, via `StartSprintRequest` ;
   - `close_sprint` : `sprintName` + `projectKey` ou `sprintId`, via `ISprintService.CloseAsync` ;
   - `update_sprint` : `sprintId` + `name?`, `goal?`, `startDate?`, `endDate?`, via `UpdateSprintRequest`.
2. La résolution par nom passe par `McpReferenceResolver` ; `get_sprint` ( lot 02 ) et `move_ticket_to_sprint` ( lot 03 ) doivent réutiliser les mêmes conventions de résolution — aucune divergence d'acceptation d'identifiants entre outils.
3. Complète les descriptions : le cycle Planned → Active → Closed, l'unicité du sprint actif par projet ( règle déjà portée par le Domain ), et le format des dates ISO 8601 UTC.
4. Réutilise la traduction d'erreurs commune : en particulier, démarrer alors qu'un sprint est déjà actif, ou démarrer un sprint déjà Closed, doit remonter le message métier exact du Domain tel quel au LLM — ces messages sont déjà actionnables.
5. Vérifie qu'aucun outil destructif ( `delete_sprint` ) n'est exposé (M06).

## Critères d'acceptation

- Un cycle complet est réalisable avec les seuls outils MCP : `create_sprint` → `move_ticket_to_sprint` → `start_sprint` → `close_sprint`, chaque état intermédiaire vérifiable par `get_sprint`.
- Démarrer un second sprint actif dans le même projet échoue avec le message métier du Domain, sans état incohérent.
- Un Guest ne peut créer ni démarrer ni clôturer ; un PAT `read` est refusé sur les quatre outils.
- Un sprint d'un projet où l'utilisateur n'est pas membre n'est pas adressable par `sprintId` ( la résolution vérifie l'accès projet ).
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent ; tests d'intégration couvrant : cycle complet nominal, double démarrage refusé, refus Guest, refus de portée, résolution de sprint par nom ambigu.

## Livrables et transmission

4 outils de sprint, tests.

Crée `docs/mcp-connector/suivi/04-compte-rendu.md` selon le contrat commun, avec résultats réels de build et de tests. Committe avec :

```
feat(mcp): add sprint lifecycle tools
```

Le prochain lot est [Batch, clôture de ticket et recherche](05-batch-close-recherche.md) ; ne le commence pas dans cette tâche.
