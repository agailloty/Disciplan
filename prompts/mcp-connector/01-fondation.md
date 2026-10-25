# Lot 01 — Fondation : projet MCP, jetons PAT et endpoint /mcp

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 2 (M01, M02, M05), 3 et 4. Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Aucun lot préalable. Vérifie que `docs/mcp-connector/suivi/` est vide ou absent.

## Fichiers de départ

`Disciplaner.slnx` ; `src/Disciplaner.Web/Server/Program.cs` ; `src/Disciplaner.Web/Server/Identity/` ( JwtTokenService, gestion des claims ) ; `src/Disciplaner.Infrastructure` ( modèle EF, configuration des entités, migrations ) ; `src/Disciplaner.Web/Server/appsettings.json`. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Crée le projet `src/Disciplaner.Mcp` ( `net10.0` ) référençant `Disciplaner.Application` et le package NuGet officiel `ModelContextProtocol` ( intégration ASP.NET Core ). Ajoute-le à `Disciplaner.slnx`. Vérifie la version et la syntaxe courantes du SDK dans sa documentation officielle avant de coder.
2. Crée `McpOptions` ( `Enabled`, `MaxBatchTickets` = 50, `RateLimitPerMinute` = 60 ) liées à la section `Mcp` d'`appsettings.json`, et les méthodes d'extension `AddDisciplanerMcp()` / `MapDisciplanerMcp("/mcp")` dans `DependencyInjection.cs`. Quand `Mcp:Enabled` vaut `false`, l'endpoint `/mcp` répond 404.
3. Ajoute l'entité `McpToken` ( `Id`, `UserId`, `Name`, `TokenHash`, `Scopes` `"read"` | `"read+write"`, `CreatedAt`, `LastUsedAt`, `RevokedAt?`, `ExpiresAt?` ), sa configuration EF ( index sur `TokenHash` ) et une migration EF **additive** qui ne touche aucune table existante.
4. Implémente `McpTokenService` : génération du PAT ( `dcp_` + 32 octets aléatoires en base64url ), hachage SHA-256 salé pour le stockage, création avec nom obligatoire, révocation, liste, mise à jour de `LastUsedAt`. Le jeton brut n'apparaît que dans la réponse de création.
5. Implémente `McpTokenAuthenticationHandler` : lit `Authorization: Bearer dcp_...` sur `/mcp`, valide le jeton ( trouvé / non révoqué / non expiré ), et construit un `ClaimsPrincipal` portant `ClaimTypes.NameIdentifier` de l'utilisateur propriétaire — identique au JWT. Un JWT n'est **pas** accepté sur `/mcp`.
6. Expose la gestion des jetons côté REST pour l'utilisateur connecté ( JWT ) : `GET /api/me/mcp-tokens`, `POST /api/me/mcp-tokens` ( nom, portée ), `DELETE /api/me/mcp-tokens/{id}` ( révocation ). Ces endpoints ne renvoient jamais le jeton brut après création.
7. Monte l'endpoint MCP Streamable HTTP sur `/mcp` avec un unique outil de fumée `ping` ( retourne `pong` ), et le server instructions de base ( une phrase décrivant Disciplan et le format `KEY-42` des références ).
8. Applique le rate limiting par jeton ( `RateLimitPerMinute` ) sur `/mcp` via le mécanisme ASP.NET Core.

## Critères d'acceptation

- Une session MCP ( `initialize` ) sur `/mcp` avec un PAT valide négocie le protocole et `tools/list` renvoie `ping` ; `tools/call ping` renvoie `pong`.
- PAT révoqué, expiré ou inconnu → 401 ; JWT présenté sur `/mcp` → 401 ; `Mcp:Enabled=false` → 404.
- La base ne stocke que le hachage : une lecture directe de la table ne permet pas d'authentifier une requête ; aucun jeton brut dans les logs.
- Les endpoints `/api/me/mcp-tokens` fonctionnent avec le JWT d'un utilisateur standard et sont inaccessibles sans authentification.
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent, avec des tests d'intégration (`WebApplicationFactory`) couvrant : PAT valide, PAT révoqué, JWT refusé, création/révocation via les endpoints de gestion.

## Livrables et transmission

Projet `Disciplaner.Mcp`, entité + migration `McpToken`, handler d'auth PAT, endpoints de gestion, `/mcp` avec `ping`, tests.

Crée `docs/mcp-connector/suivi/01-compte-rendu.md` selon le contrat commun, avec résultats réels de build et de tests. Committe avec :

```
feat(mcp): add Disciplaner.Mcp foundation with PAT authentication and /mcp endpoint
```

Le prochain lot est [Outils de lecture et résolution de références](02-outils-lecture.md) ; ne le commence pas dans cette tâche.
