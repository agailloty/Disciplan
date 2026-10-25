# Lot 05 — Batch, clôture de ticket et recherche

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 5.2, 5.4, 7.3 et 7.4 (M03, M07). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 04 terminé. Vérifie `docs/mcp-connector/suivi/04-compte-rendu.md` avant de poursuivre.

## Fichiers de départ

`src/Disciplaner.Mcp/Tools/TicketsTools.cs` ; `src/Disciplaner.Application/Services/TicketService.cs` et `Interfaces/ITicketService.cs` ; `src/Disciplaner.Application/Services/ResourceAccess.cs` ; `src/Disciplaner.Application/DTOs/Ticket/` ; `src/Disciplaner.Web/Server/Controllers/TicketsController.cs` ; `src/Disciplaner.Application/DTOs/Project/UpdateProjectDefaultsRequest.cs`. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. **Recherche applicative (§7.4)** — la seule extension autorisée du backend existatif :
   - ajoute `TicketSearchQuery` ( `ProjectId?`, `SprintId?`, `StatusCategory?`, `Type?`, `AssigneeId?`, `AssignedToMe?`, `ReportedByMe?`, `Limit` ≤ 100, `Offset` ) et `Task<IReadOnlyList<TicketDto>> SearchAsync(...)` dans `ITicketService` / `TicketService` ;
   - le filtrage des droits par projet est identique aux autres requêtes du service ( décision D01 : filtrer les projets autorisés avant projection et comptage ) ;
   - expose-la aussi en REST : `GET /api/projects/{projectId}/tickets` avec les mêmes paramètres de filtre, pour que le client Flutter et le connecteur partagent la capacité ;
   - note au compte rendu toute autre retouche du backend, avec justification.
2. **`list_tickets`** : outil MCP de lecture adossé à `SearchAsync` — `projectKey?`, `sprintName?`, `statusCategory?` ( Backlog|InProgress|Done ), `type?`, `assigneeDisplayName?`, `mine?`, pagination. Sans `projectKey`, la recherche couvre tous les projets accessibles à l'utilisateur.
3. **`create_tickets`** ( batch ) : `projectKey` + `tickets[]` reprenant les champs de `create_ticket`. Plafonné à `McpOptions.MaxBatchTickets` ( message explicite invitant à découper au-delà ). **Tolérant aux échecs partiels** : un ticket invalide n'interrompt pas le lot ; la réponse contient `created[{ticketRef, title, link}]` et `failed[{index, title, error}]` avec le message métier de chaque échec, pour que le LLM corrige et rejoue uniquement les échecs. Le lot s'arrête et est refusé en entier si la portée ou les droits projet sont insuffisants ( vérifiés une fois avant la boucle ).
4. **`close_ticket`** :
   - implémente `TerminalStatusResolver` ( §7.3 ) avec la règle déterministe : ( a ) statut de catégorie `Done` nommé `Done` ou `Terminé`, insensible à la casse ; ( b ) sinon statut terminal par défaut du projet s'il est défini ( point 5 ) ; ( c ) sinon l'unique statut de catégorie `Done` ; ( d ) sinon erreur listant les statuts disponibles du projet et invitant le LLM à demander le statut à l'utilisateur ;
   - `close_ticket` = résolution du statut terminal + `ChangeTicketStatusAsync` + commentaire de résolution facultatif ( `resolutionComment?` ) via `CreateForTicketAsync` ;
   - la description documente que « closing » est résolu vers le statut Done du projet et que le LLM doit demander à l'utilisateur en cas d'ambiguïté.
5. **Préférence de statut terminal** : étends `UpdateProjectDefaultsRequest` et le modèle projet d'un statut Done par défaut **optionnel** ( nullable, migration additive, aucun impact si non défini ). Fais-en usage uniquement dans la règle ( b ) du résolveur. Si cette extension s'avère plus invasive que prévu, livre le résolveur avec les règles ( a ), ( c ), ( d ) et documente l'écart au compte rendu — c'est le seul recul accepté du lot.
6. Toute erreur du batch et de `close_ticket` passe par la traduction commune (M07).

## Critères d'acceptation

- Un lot de 3 tickets dont 1 invalide ( titre trop long ) crée 2 tickets et renvoie `failed` avec le message métier exact ; un lot de 51 tickets est refusé avec le message de plafond.
- `close_ticket` sur un projet avec un unique statut Done le sélectionne ; sur un projet avec deux statuts Done (`Validation` et `Terminé`), il choisit `Terminé` sans interaction ; sur un projet sans statut Done, il échoue en listant les statuts.
- `list_tickets` filtre par `statusCategory`, `assignee` et `mine` ; un utilisateur non-membre d'un projet ne voit jamais ses tickets via `SearchAsync` ; le endpoint REST expose les mêmes filtres.
- L'historique de ticket enregistre le changement de statut et le commentaire de clôture.
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent ; tests unitaires pour `TerminalStatusResolver` ( les 4 cas ) et l'échec partiel du batch, tests d'intégration pour `SearchAsync` ( droits et filtres ) et le cycle `create_tickets` → `close_ticket`.

## Livrables et transmission

`SearchAsync` + endpoint REST, `list_tickets`, `create_tickets`, `TerminalStatusResolver` + `close_ticket`, préférence de statut terminal, tests.

Crée `docs/mcp-connector/suivi/05-compte-rendu.md` selon le contrat commun, avec résultats réels de build et de tests. Committe avec :

```
feat(mcp): add batch creation, ticket closing and ticket search
```

Le prochain lot est [Transport stdio, prompts serveur, UI des jetons et documentation](06-transport-prompts-ui-doc.md) ; ne le commence pas dans cette tâche.
