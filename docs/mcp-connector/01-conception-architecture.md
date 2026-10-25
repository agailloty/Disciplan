# Connecteur MCP — Conception architecturale

Date : 25 octobre 2026. Base : branche `feat/flutter-migration` (commit `5444b0a`). Document de conception ; aucune implémentation ni recette exécutée à ce stade.

## 1. Objectif et périmètre

Permettre à un LLM hébergé chez un client MCP (Mistral, ChatGPT, Claude Desktop, Cursor, VS Code...) d'effectuer pour le compte d'un utilisateur Disciplaner **toutes les opérations de gestion de projet disponibles dans l'application** :

- créer un ou plusieurs tickets (enrichissement de backlog),
- mettre à jour un ticket, l'assigner, le déplacer dans un sprint, le clôturer,
- ajouter et lister des commentaires,
- créer, démarrer et clôturer des sprints,
- explorer projets, membres, statuts, sprints et tickets.

Hors périmètre v1 : suppression de tickets/sprints/projets (destructif, voir §8), gestion des boards/cards historiques, administration des comptes, pièces jointes, vues sauvegardées.

## 2. Choix structurants

| ID | Décision | Justification / conséquence vérifiable |
|---|---|---|
| M01 | Le serveur MCP est **embarqué dans l'application existante**, exposé via un endpoint HTTP Streamable à `/mcp`, dans un projet dédié `src/Disciplaner.Mcp`. | Une seule chose à déployer (conteneur Docker existant, base SQLite partagée). Le projet MCP ne référence que `Disciplaner.Application` ; il ne court-circuite jamais la couche services. |
| M02 | Authentification par **jetons d'accès personnels (PAT) MCP**, révocables, avec portée `read` ou `read+write`. | Le JWT interactif a une durée de vie courte et est lié au login ; inadapté à un connecteur configuré une fois. Le PAT est échangé, à chaque requête, contre un `ClaimsPrincipal` identique à celui du JWT (mêmes claims `sub`/`NameIdentifier`) : **tout le contrôle d'accès existant (matrice D05) s'applique sans modification**. |
| M03 | Les outils MCP sont **des adaptateurs fins** au-dessus de `IProjectService`, `ITicketService`, `ISprintService`, `ICommentService`, `IProjectMemberService`. | Aucune règle métier dupliquée. Toute évolution des services profite automatiquement au connecteur et inversement. Aucun appel HTTP interne : les outils appellent les services en processus. |
| M04 | Les outils adressent les ressources par **identifiants lisibles** : `projectKey` (ex. `DISC`), `ticketRef` (ex. `DISC-42`), nom de sprint ; les GUID restent acceptés en entrée facultative. | Les LLM manipulent mal les GUID. La résolution `ticketRef → ticket` réutilise le endpoint existant `GET /api/tickets/by-ref/{projectKey}/{ticketNumber}` (logique déplacée dans un `McpReferenceResolver` partagé). |
| M05 | Transport principal : **Streamable HTTP** (spec MCP 2025-03-26+) sur `/mcp`. Mode local **stdio** optionnel fourni par le même projet, pour les clients desktop sans serveur public. | ChatGPT (connecteurs) et Mistral parlent MCP distant sur HTTPS ; Claude Desktop/Cursor préfèrent stdio. Un seul code d'outils, deux façades de transport fournies par le SDK C# officiel. |
| M06 | Aucune opération destructive en v1. Les outils de suppression existants de l'API ne sont pas exposés. | Un LLM ne doit pas pouvoir supprimer des données sur une hallucination. La suppression reste possible via l'UI/API. À réévaluer en v2 avec portée `write` dédiée + confirmation (elicitation, non supportée par tous les clients). |
| M07 | Les erreurs applicatives (`NotFoundException`, `ForbiddenException`, `DomainException`) sont **traduites en messages d'erreur d'outil actionnables** pour le LLM. | Le LLM doit pouvoir s'auto-corriger : « Ticket DISC-99 introuvable dans le projet DISC » est exploitable ; un stack trace ne l'est pas. |

## 3. Architecture générale

```
 Client LLM (Mistral / ChatGPT / Claude Desktop / Cursor)
     │  HTTPS + Bearer PAT (ou stdio en local)
     ▼
┌─────────────────────────────────────────────────────────────┐
│ Disciplaner.Web.Server (conteneur unique)                   │
│                                                             │
│  /api/*   ── REST (JWT) ──► Controllers ──┐                 │
│                                           │                 │
│  /mcp    ── MCP (PAT)  ──► Disciplaner.Mcp│                 │
│              │                             │                 │
│              │  Tools: ProjectsTools,      │                 │
│              │  TicketsTools, SprintsTools,│                 │
│              │  CommentsTools              ▼                 │
│              └────────────► Application Services            │
│                              (ITicketService, ISprintService,│
│                               ICommentService, ...)          │
│                                      │                      │
│                              Infrastructure (EF + SQLite)   │
└─────────────────────────────────────────────────────────────┘
```

### 3.1 Nouveau projet : `src/Disciplaner.Mcp`

```
src/Disciplaner.Mcp/
  DependencyInjection.cs        // AddDisciplanerMcp() : options + tools + auth PAT
  McpOptions.cs                  // activé/désactivé, tailles de lot, rate limit
  McpAuth/
    McpTokenService.cs           // création/révocation PAT, hachage SHA-256 + sel
    McpTokenAuthenticationHandler.cs  // PAT → ClaimsPrincipal (claims identiques au JWT)
    McpTokenController.cs        // REST /api/me/mcp-tokens (list, create, revoke)
  Resolution/
    McpReferenceResolver.cs      // projectKey/ticketRef/nom de sprint → entités
    TerminalStatusResolver.cs    // « clôturer » → statut Done du projet (§7.3)
  Tools/
    ProjectsTools.cs             // list_projects, get_project, list_members...
    TicketsTools.cs              // create_ticket(s), update, close, comments...
    SprintsTools.cs             // list/get/create/start/close
  Transport/
    Stdio/Program.cs             // mode stdio optionnel (même assembly d'outils)
```

Dépendances : `Disciplaner.Application` + package `ModelContextProtocol` (SDK C# officiel, ASP.NET Core integration). **Le projet ne référence ni `Disciplaner.Infrastructure` directement, ni EF.** Montage dans `Program.cs` du serveur web :

```csharp
builder.Services.AddDisciplanerMcp();   // options, résolveurs, tools
app.MapDisciplanerMcp("/mcp");          // endpoint Streamable HTTP (si Mcp:Enabled)
```

Le SDK fournit l'attribut `[McpServerToolType]` / `[McpServerTool]` : chaque méthode publique devient un outil MCP avec son schéma JSON généré depuis les types C#. Sérialisation : camelCase, énumérations en chaînes (`"Story"`, `"High"`), dates ISO 8601 UTC.

### 3.2 Extension de données minimale (Infrastructure)

Une seule nouvelle entité :

```
McpToken { Id, UserId, Name, TokenHash, Scopes ("read"|"read+write"),
           CreatedAt, LastUsedAt, RevokedAt?, ExpiresAt? }
```

Migration EF additive (conforme D04). Le PAT brut (`dcp_` + 32 octets base64url) n'est affiché qu'une fois à la création ; seul son hachage est persisté. Endpoints de gestion exposés dans l'UI d'administration de compte (coté Flutter : écran « Jetons MCP » — hors périmètre de ce document).

## 4. Authentification et autorisation

1. Le client MCP envoie chaque requête avec `Authorization: Bearer dcp_...` (ChatGPT : connecteur « API key » ; Mistral : header custom).
2. `McpTokenAuthenticationHandler` hache le jeton, charge le `McpToken`, vérifie révocation/expiration, puis construit un `ClaimsPrincipal` avec le **même claim user ID que le JWT** (`ClaimTypes.NameIdentifier`).
3. Chaque appel d'outil injecte ce principal dans les services applicatifs, exactement comme le fait `TicketsController` avec `UserId`. `ResourceAccess` applique la matrice Guest/Member/Supervisor/propriétaire sans changement : un Guest obtient la lecture, un Member peut créer, etc.
4. La portée du jeton est vérifiée avant l'exécution : un outil d'écriture appelé avec un PAT `read` échoue avec un message explicite.

Points ouverts (v2) : OAuth 2.1 serveur-à-serveur conforme à la spec MCP pour les connecteurs hébergés ; jetons restreints à un projet (`ProjectIds` sur `McpToken`).

## 5. Catalogue d'outils v1

Conventions : identifiants d'entrée en minuscules_snake, sorties JSON compactes contenant toujours `ticketRef`/`projectKey` et un lien profond (`{baseUrl}/projects/{id}` — utile pour que le LLM cite une URL cliquable). Toutes les listes sont paginées (`limit` ≤ 100, `offset`) et triées du plus récent au plus ancien pour les écritures, du plus ancien au plus récent pour les tickets (ordre de backlog naturel).

### 5.1 Découverte (lecture)

| Outil | Entrées | Source applicative |
|---|---|---|
| `list_projects` | — | `IProjectService.GetAllByUserAsync(user)` |
| `get_project` | `projectKey` ou `projectId` | `GetByIdAsync` + statuts + membres |
| `list_members` | `projectKey` | `IProjectMemberService` |
| `list_labels` | `projectKey` | `ILabelService` (par board/projet) |
| `list_ticket_statuses` | `projectKey` | statuts du projet avec catégorie |

### 5.2 Tickets (écriture + lecture)

| Outil | Entrées (résumé) | Source applicative |
|---|---|---|
| `create_ticket` | `projectKey`, `title` (≤200), `description?` (≤2000), `type` (Story\|Bug\|Task\|Epic\|Subtask), `priority` (Low\|Medium\|High\|Critical, défaut Medium), `storyPoints?`, `dueDate?`, `sprintName?` ou `sprintId?`, `parentTicketRef?`, `assigneeDisplayName?` | `ITicketService.CreateAsync` |
| `create_tickets` | `projectKey`, `tickets[]` (mêmes champs, max 50 par appel) | boucle sur `CreateAsync` |
| `update_ticket` | `ticketRef`, champs modifiables (title, description, type, priority, storyPoints, dueDate, assignee) | `UpdateTicketRequest` |
| `close_ticket` | `ticketRef`, `resolutionComment?` | résolution du statut terminal (§7.3) + `ChangeTicketStatusRequest` + `ICommentService` |
| `assign_ticket` | `ticketRef`, `assigneeDisplayName?` (null = désassigner) | `UpdateTicketRequest` |
| `move_ticket_to_sprint` | `ticketRef`, `sprintName?`/`sprintId?` (null = backlog) | `MoveTicketToSprintRequest` |
| `add_comment` | `ticketRef`, `body` | `ICommentService.CreateForTicketAsync` |
| `list_comments` | `ticketRef`, pagination | `ICommentService.GetByTicketAsync` |
| `get_ticket` | `ticketRef` (ou `ticketId`) | `GetByRefAsync` / `GetByIdAsync` |
| `list_tickets` | `projectKey?`, `sprintName?`, `statusCategory?`, `type?`, `assignee?`, `mine?`, pagination | **nouvelle méthode** `ITicketService.SearchAsync` (voir §7.4) |

### 5.3 Sprints

| Outil | Entrées | Source applicative |
|---|---|---|
| `list_sprints` | `projectKey?` (tous projets accessibles si absent) | `ISprintService` |
| `get_sprint` | `sprintName` + `projectKey` ou `sprintId` | détail + tickets |
| `create_sprint` | `projectKey`, `name` (≤100), `goal?` | `CreateSprintRequest` |
| `start_sprint` | `sprintId`, `startDate`, `endDate` | `StartSprintRequest` |
| `close_sprint` | `sprintId` | `ISprintService.CloseAsync` |
| `update_sprint` | `sprintId`, `name?`, `goal?`, dates | `UpdateSprintRequest` |

### 5.4 Présentation des résultats (spécifique LLM)

- `create_ticket(s)` retourne les `ticketRef` créés et leurs liens — c'est la donnée que le LLM doit relayer à l'utilisateur.
- `create_tickets` est **partiellement tolérant aux erreurs** : un ticket invalide n'interrompt pas le lot ; la réponse contient `created[]` et `failed[{index, title, error}]` pour que le LLM puisse corriger et rejouer uniquement les échecs.
- Chaque outil de lecture renvoie des projections réduites (`ticketRef`, titre, statut, type, priorité, assigné, sprint) — jamais les GUID seuls, jamais les champs techniques.
- Les descriptions d'outils (en anglais, standard MCP) documentent les valeurs d'énumération, les longueurs max et le format `DISC-42` ; elles précisent les implications (« moving a ticket to the backlog removes it from its sprint »).
- Annotations MCP : `readOnlyHint: true` sur tous les outils de lecture ; aucun `destructiveHint` (aucun outil destructif).

### 5.5 Prompts serveur (facultatif, même lot que le batch)

Le serveur MCP peut exposer des **prompts** guidant des usages courants : `enrich-backlog` (prendre un objectif produit brut et proposer des tickets structurés à valider avant création), `sprint-review` (résumer un sprint actif, tickets ouverts/bloqués). Les prompts ne contiennent que des instructions et des appels d'outils — aucune logique serveur.

## 6. Configuration et déploiement

```jsonc
// appsettings.json
"Mcp": {
  "Enabled": true,          // désactive /mcp entièrement si false
  "MaxBatchTickets": 50,
  "RateLimitPerMinute": 60  // par jeton, via le rate limiting ASP.NET Core
}
```

- **Client distant (ChatGPT/Mistral)** : URL `https://disciplan.example.com/mcp`, auth « API key/Bearer » avec le PAT. Le serveur étant auto-hébergé (homelab), l'exposition passe par le reverse-proxy HTTPS existant (cf. guides homelab de `docs/flutter-migration`).
- **Client local (Claude Desktop/Cursor)** : mode stdio. Le même binaire `Disciplaner.Mcp` (publish single-file, ou `docker exec`) démarre en stdio avec `DISCIPLAN_URL` + `DISCIPLAN_PAT` dans l'environnement et relaie vers l'API — utile quand le serveur n'est pas exposé publiquement. Dans ce mode, les outils passent par le client HTTP REST embarqué plutôt qu'en processus.

Configuration client type :

```json
{
  "mcpServers": {
    "disciplaner": {
      "command": "disciplaner-mcp",
      "args": ["--stdio"],
      "env": { "DISCIPLAN_URL": "https://disciplan.example.com", "DISCIPLAN_PAT": "dcp_..." }
    }
  }
}
```

## 7. Points de conception détaillés

### 7.1 Résolution des références

`McpReferenceResolver` centralise : `projectKey` → projet (insensible à la casse), `DISC-42` → `{projectKey, ticketNumber}` → ticket (via la même logique que `GET /api/tickets/by-ref`), nom de sprint (dans un projet) → sprint, nom d'assigné (insensible à la casse) → membre. Les ambiguïtés (deux membres homonymes, deux sprints de même nom) produisent une erreur listant les candidats avec leurs identifiants — le LLM peut redemander à l'utilisateur.

### 7.2 Erreurs et guidage du LLM

| Exception applicative | Message d'outil (exemple) |
|---|---|
| `NotFoundException` | `Ticket DISC-99 not found in project DISC. Known projects can be listed with list_projects.` |
| `ForbiddenException` | `You don't have permission for this operation in project DISC (token scope or your project role).` |
| `DomainException` / validation | Message métier brut (`Project key must be unique`, `Status ... is not in this project`) — auto-correction possible. |
| Lot > `MaxBatchTickets` | `Batch of 120 tickets exceeds the 50-ticket limit; split into multiple calls.` |

### 7.3 Sémantique de `close_ticket`

Les statuts étant personnalisés par projet, « clôturer » n'est pas un statut fixe. `TerminalStatusResolver` applique la règle déterministe suivante :

1. statut du projet de catégorie `Done` nommé `Done` ou `Terminé` (insensible à la casse) ;
2. sinon, si le projet définit un statut terminal par défaut (préférence de projet à ajouter, voir lot 5) ;
3. sinon, l'unique statut de catégorie `Done` ;
4. sinon, erreur listant les statuts disponibles et invitant le LLM à demander à l'utilisateur lequel utiliser.

`close_ticket` = changement de statut + commentaire de résolution facultatif (même appel, deux services). L'historique de ticket existant enregistre les deux événements — piste d'audit déjà garantie par le produit.

### 7.4 Prérequis côté backend : recherche de tickets

L'API actuelle ne couvre que `backlog`, `by-sprint`, `mine`, `by-ref` et `get`. L'outil `list_tickets` (et donc « enrichir le backlog » en connaissance du contexte) nécessite une méthode applicative additive :

```csharp
Task<IReadOnlyList<TicketDto>> SearchAsync(
    TicketSearchQuery query, string userId, CancellationToken ct);
// TicketSearchQuery : ProjectId?, SprintId?, StatusCategory?, Type?, AssigneeId?,
//                     AssignedToMe?, ReportedByMe?, Limit, Offset
```

Implémentée dans `TicketService` (filtre de droits par projet identique aux autres requêtes, conforme D01), exposée aussi en REST (`GET /api/projects/{id}/tickets?...`) pour que le connecteur et le client Flutter partagent la même capacité — pas un chemin réservé MCP.

## 8. Garde-fous

- Pas d'outils destructifs (M06). La création de projet/statuts n'est pas non plus exposée en v1 (effet structurel élevé) ; `create_project` pourra être ajouté avec la portée `admin` si demandé.
- Portée PAT minimale : `read` par défaut, `read+write` explicite.
- Rate limiting par jeton + limitation de taille de lot, pour contenir une boucle d'agent défaillante.
- Journalisation : `LastUsedAt` sur le jeton ; les écritures transitent par les services existants, donc l'historique de ticket et l'activité existants servent de piste d'audit. Option v1.1 : suffixer les libellés d'activité de `via MCP {tokenName}` pour distinguer l'origine.

## 9. Plan d'implémentation en lots

Un commit par lot, dans l'esprit de D06. Chaque lot doit compiler, passer les tests existants et les siens.

| Lot | Contenu | Vérification |
|---|---|---|
| 1 | Fondation : projet `Disciplaner.Mcp`, entité `McpToken` + migration, handler d'auth PAT, `AddDisciplanerMcp`/`MapDisciplanerMcp`, `/mcp` répond au handshake (initialize) avec un outil `ping`. | Requête MCP `initialize` + `tools/list` renvoie `ping` ; jeton révoqué refusé ; JWT inaccepté sur `/mcp`. |
| 2 | Outils lecture : `list_projects`, `get_project`, `list_members`, `list_ticket_statuses`, `list_sprints`, `get_sprint`, `get_ticket`, `list_comments` + résolveurs de référence. | Guest lit ; non-membre → erreur actionnable ; refs `DISC-42` résolues. |
| 3 | Écriture tickets : `create_ticket`, `update_ticket`, `assign_ticket`, `add_comment`, `move_ticket_to_sprint`. | PAT `read` refusé en écriture ; messages d'erreur de §7.2 ; historique de ticket renseigné. |
| 4 | Sprints : `create_sprint`, `start_sprint`, `close_sprint`, `update_sprint`. | Cycle Planned → Active → Closed via outils uniquement. |
| 5 | `create_tickets` (batch + échecs partiels), `close_ticket` (résolveur terminal), `SearchAsync` + `list_tickets` (REST + MCP). | Lot de 50 tickets créé avec échecs partiels ; `close_ticket` sur projet multi-statuts Done ; `list_tickets` filtre par statut/assigné. |
| 6 | Mode stdio, prompts serveur, écran UI de gestion des jetons (Flutter), documentation utilisateur (configuration ChatGPT/Mistral/Claude). | Recette manuelle des trois clients documentée. |

Tests (conformes D08 — fixtures synthétiques uniquement) :

- **Unitaires** : `McpReferenceResolver` (casse, ambiguïtés), `TerminalStatusResolver` (les 4 cas), hachage/révocation PAT, tolérance aux échecs du batch.
- **Intégration** : `WebApplicationFactory` sur `/mcp` avec client MCP du SDK C# ; par outil : chemin nominal, rôle insuffisant, ressource absente, portée insuffisante.

## 10. Risques et points ouverts

- **Exposition publique** : ChatGPT exige une URL HTTPS publique ; en homelab, reverse-proxy ou tunnel requis — documenté mais non résolu par ce connecteur. Le mode stdio couvre le cas strictement local.
- **Elicitation/confirmation** : non supportée uniformément par les clients MCP ; c'est la raison de M06 en v1.
- **Hallucination d'identifiants** : atténuée par M04 (refs lisibles) et les erreurs listant les candidats, mais un `dcp_` PAT compromis reste un risque standard de jeton — révocation immédiate dans l'UI.
- **Version de spec MCP** : le SDK C# suit la spec Streamable HTTP actuelle ; l'upgrade vers une révision future (OAuth serveur, elicitation généralisée) est encapsulée dans `Disciplaner.Mcp` et n'affecte pas les services.
