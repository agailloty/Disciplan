# Lot 02 — Outils de lecture et résolution de références

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 5.1, 5.4, 7.1 et 7.2 (M03, M04, M07). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 01 terminé. Vérifie `docs/mcp-connector/suivi/01-compte-rendu.md` avant de poursuivre.

## Fichiers de départ

`src/Disciplaner.Mcp/` ( fondation du lot 01 ) ; `src/Disciplaner.Application/Interfaces/` ( IProjectService, IProjectMemberService, ITicketService, ISprintService, ICommentService, ILabelService ) ; `src/Disciplaner.Application/Services/ResourceAccess.cs` ; `src/Disciplaner.Application/DTOs/`. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Implémente `McpReferenceResolver` dans `src/Disciplaner.Mcp/Resolution/` :
   - `projectKey` → projet, insensible à la casse ;
   - `ticketRef` au format `KEY-42` → découpage puis résolution via `ITicketService.GetByRefAsync` ;
   - nom de sprint ( dans un projet donné ) → sprint ; nom d'assigné → membre du projet, insensible à la casse ;
   - en cas d'ambiguïté ( deux membres homonymes, deux sprints de même nom dans le même projet ), lever une erreur d'outil **listant les candidats** avec leurs identifiants et textes, pour que le LLM puisse redemander à l'utilisateur ;
   - en cas d'absence, message actionnable du style §7.2 ( ex. `Ticket DISC-99 not found in project DISC.` ).
2. Crée les classes d'outils `ProjectsTools` et `TicketsTools` ( et `SprintsTools` si plus lisible ) dans `src/Disciplaner.Mcp/Tools/`, en adaptateurs fins des services. Chaque outil reçoit l'utilisateur du `ClaimsPrincipal` courant et appelle le service applicatif — aucun accès direct aux données.
3. Outils à livrer :
   - `list_projects` ( `IProjectService.GetAllByUserAsync` ) ;
   - `get_project` ( par `projectKey` ou `projectId` : détail, statuts avec catégorie, membres ) ;
   - `list_members` ( `projectKey`, pagination ) ;
   - `list_ticket_statuses` ( `projectKey` ) ;
   - `list_labels` ( `projectKey` ) ;
   - `list_sprints` ( `projectKey?` : sprints du projet, ou de tous les projets accessibles si absent ) ;
   - `get_sprint` ( `sprintName` + `projectKey`, ou `sprintId` : détail + tickets ) ;
   - `get_ticket` ( `ticketRef` ou `ticketId` ) ;
   - `list_comments` ( `ticketRef`, pagination ).
4. Conformes à §5.4 : descriptions d'outils en anglais documentant les formats ( `DISC-42` ), énumérations et catégories ; projections réduites incluant toujours `ticketRef`/`projectKey` ( jamais un GUID seul ) ; pagination `limit` ≤ 100 et `offset` sur tous les outils de liste ; annotation `readOnlyHint: true`.
5. Implémente la table de traduction d'erreurs §7.2 ( `NotFoundException`, `ForbiddenException`, `DomainException` ) dans un composant commun réutilisé par tous les outils.
6. Ajoute la validation de portée : tout outil exige au minimum `read` ( le lot 03 ajoutera le contrôle `read+write` pour les écritures ).

## Critères d'acceptation

- `tools/list` décrit exactement les 9 outils avec `readOnlyHint: true` ; les descriptions sont en anglais et citent les formats d'identifiants.
- Un Guest membre d'un projet lit ses tickets via `get_ticket` ; un utilisateur non-membre reçoit un message d'erreur actionnable mentionnant le périmètre, pas une exception brute.
- `DISC-42` et `disc-42` résolvent le même ticket ; `DISC-99` inexistant renvoie le message §7.2 ; deux sprints homonymes dans un projet renvoient la liste des candidats.
- Les listes sont paginées : `limit=200` est refusé ou tronqué à 100 avec avertissement explicite dans la réponse.
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent ; tests d'intégration couvrant au minimum : lecture Guest autorisée, non-membre refusé, résolution insensible à la casse, ambiguïté de sprint, pagination.

## Livrables et transmission

`McpReferenceResolver`, traduction d'erreurs commune, 9 outils de lecture, tests.

Crée `docs/mcp-connector/suivi/02-compte-rendu.md` selon le contrat commun, avec résultats réels de build et de tests. Committe avec :

```
feat(mcp): add read tools and reference resolution
```

Le prochain lot est [Écriture de tickets et commentaires](03-ecriture-tickets.md) ; ne le commence pas dans cette tâche.
