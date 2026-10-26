# Lot 03 — Écriture de tickets et commentaires

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 5.2, 5.4 et 7.2 (M02, M03, M07). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 02 terminé. Vérifie `docs/mcp-connector/suivi/02-compte-rendu.md` avant de poursuivre.

## Fichiers de départ

`src/Disciplaner.Mcp/Tools/` et `src/Disciplaner.Mcp/Resolution/McpReferenceResolver.cs` ; `src/Disciplaner.Application/DTOs/Ticket/TicketRequests.cs` ; `src/Disciplaner.Application/Services/TicketService.cs` ; `src/Disciplaner.Application/Services/CommentService.cs` ; `src/Disciplaner.Domain/Common/DomainConstraints.cs`. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Ajoute le contrôle de portée `read+write` commun à tous les outils d'écriture : un PAT de portée `read` reçoit un refus explicite invitant à utiliser un jeton d'écriture, avant tout effet de bord.
2. Implémente dans `TicketsTools` :
   - `create_ticket` : `projectKey`, `title` ( ≤ `DomainConstraints.Ticket.TitleMaxLength` ), `description?`, `type` ( Story|Bug|Task|Epic|Subtask ), `priority` ( Low|Medium|High|Critical, défaut Medium ), `storyPoints?`, `dueDate?`, `sprintName?`/`sprintId?`, `parentTicketRef?`, `assigneeDisplayName?`. Appelle `ITicketService.CreateAsync` ; la réponse contient `ticketRef` créé, son lien et un résumé compact.
   - `update_ticket` : `ticketRef` + champs modifiables ( title, description, type, priority, storyPoints, dueDate, assignee ) mappés sur `UpdateTicketRequest`. Ne modifie pas le statut ni le sprint ( outils dédiés ).
   - `assign_ticket` : `ticketRef`, `assigneeDisplayName?` ( absent = désassignation ).
   - `move_ticket_to_sprint` : `ticketRef`, `sprintName?`/`sprintId?` ( absent = retour au backlog ) via `MoveTicketToSprintRequest`. La description documente l'implication « removing from a sprint sends the ticket back to the backlog ».
   - `add_comment` : `ticketRef`, `body`, via `ICommentService.CreateForTicketAsync`.
3. Résolution préalable obligatoire via `McpReferenceResolver` : `assigneeDisplayName` → membre ( ambiguïté = erreur listant les candidats ), `sprintName` → sprint du projet, `parentTicketRef` → ticket parent du même projet.
4. Descriptions d'outils en anglais documentant : valeurs d'énumérations, longueurs max, valeurs par défaut, et le fait que les dates sont ISO 8601 UTC. Aucune constante de longueur recopiée : renvoyer les limites de `DomainConstraints` ( les erreurs applicatives de validation remontent déjà le message métier ).
5. Réutilise la traduction d'erreurs du lot 02 pour tous ces outils ; en particulier, une erreur de domaine ( ex. type invalide, assigné non membre ) doit arriver au LLM comme message auto-corrigible.
6. Aucun outil destructif : pas de delete, pas de création de projet/statut (M06). Vérifie ce point avant de conclure le lot.

## Critères d'acceptation

- Un PAT `read+write` d'un Member crée un ticket, le modifie, l'assigne, le commente et le déplace de sprint à backlog ; chaque opération est visible via l'API REST existante et l'historique de ticket enregistre les changements de champs.
- Un PAT `read` est refusé sur tous les outils d'écriture avec le message de portée, sans effet de bord.
- Un Guest est refusé en écriture par la matrice de rôles existante, avec message actionnable.
- `assign_ticket` avec un nom ambigu renvoie les candidats ; `create_ticket` avec `parentTicketRef` d'un autre projet échoue avec un message explicite.
- `tools/list` ne contient aucun outil de suppression ni d'administration.
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent ; tests d'intégration couvrant : création/assignation/commentaire avec Member, refus de portée, refus Guest, résolution d'assigné ambigu, retour au backlog.

## Livrables et transmission

Contrôle de portée `read+write`, 5 outils d'écriture tickets/commentaires, tests.

Crée `docs/mcp-connector/suivi/03-compte-rendu.md` selon le contrat commun, avec résultats réels de build et de tests. Committe avec :

```
feat(mcp): add ticket and comment write tools
```

Le prochain lot est [Gestion des sprints](04-sprints.md) ; ne le commence pas dans cette tâche.
