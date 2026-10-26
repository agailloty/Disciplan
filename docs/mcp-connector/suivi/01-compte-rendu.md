# Lot 01 — Fondation : projet MCP, jetons PAT et endpoint /mcp

Branche `feat/mcp-connector` (créée depuis `master` à `07b6e7d`). Contrat commun et conception appliqués ; fixtures exclusivement synthétiques (D08).

## Périmètre réalisé

- Nouveau projet `src/Disciplaner.Mcp` (référence `Disciplaner.Application` + package `ModelContextProtocol.AspNetCore` 2.3.0 ; `FrameworkReference Microsoft.AspNetCore.App`), ajouté à `Disciplaner.slnx` et au `Dockerfile` (étape de copie des csproj avant restore).
- Entité `McpToken` (Domain), hachage salé `McpTokenSecurity` (Domain.Common), interface `IMcpTokenRepository` + exposition dans `IUnitOfWork`, configuration EF + migration additive `20261025224229_AddMcpTokens` (table `McpTokens`, index unique sur `TokenHash`, index sur `UserId`).
- `McpOptions` (section `Mcp` : `Enabled`, `MaxBatchTickets`, `RateLimitPerMinute`) + `AddDisciplanerMcp` / `MapDisciplanerMcp`.
- Authentification PAT : schéma « DisciplanerMcpToken » via `McpTokenAuthenticationHandler` (Bearer `dcp_...` → `ClaimsPrincipal` avec `ClaimTypes.NameIdentifier`, claims de portée `mcp_scopes` et de nom `mcp_token_name` ; mise à jour de `LastUsedAt`).
- Gestion des jetons : `McpTokenService` + contrôleur REST JWT `api/me/mcp-tokens` (liste, création — valeur brute retournée une seule fois, révocation).
- Endpoint MCP Streamable HTTP sur `/mcp` (mode stateless du SDK), instructions serveur, outil `ping`, autorisation limitée au schéma PAT, rate limiting (fenêtre fixe 1 min, partition par propriétaire du jeton, code 429).
- `Mcp:Enabled=false` → `/mcp` répond 404 explicite sur tout verbe (endpoint minimal dédié).
- Tests d'intégration `McpConnectorTests` (10 tests).

## Fichiers créés / modifiés

- Domain : `Entities/McpToken.cs` (nouveau), `Common/McpTokenSecurity.cs` (nouveau), `Common/DomainConstraints.cs`, `Interfaces/IMcpTokenRepository.cs` (nouveau), `Interfaces/IUnitOfWork.cs`
- Infrastructure : `Data/Configurations/McpTokenConfiguration.cs` (nouveau), `Repositories/McpTokenRepository.cs` (nouveau), `Data/ApplicationDbContext.cs`, `Repositories/UnitOfWork.cs`, `InfrastructureServiceExtensions.cs`, `Data/Migrations/20261025224229_AddMcpTokens{.cs,.Designer.cs}` + snapshot
- MCP : `Disciplaner.Mcp.csproj`, `McpOptions.cs`, `DependencyInjection.cs`, `McpAuth/{McpTokenAuthenticationOptions,McpTokenAuthenticationHandler,McpTokenService}.cs`, `McpTokensController.cs`, `Tools/PingTools.cs`
- Web : `Program.cs`, `appsettings.json`, `Dockerfile`, `Disciplaner.slnx`
- Tests : `tests/Disciplaner.Tests/McpConnectorTests.cs`

## Décisions techniques et écarts par rapport à la conception

1. **Transport stateless** : `WithHttpTransport(o => o.Stateless = true)` — recommandation du SDK pour un serveur sans requêtes serveur→client (sampling/elicitation hors périmètre). Aucune session persistée.
2. **Sel du hachage embarqué dans le jeton brut** : format `dcp_<base64url(salt 16o)>.<base64url(secret 32o)>`, `TokenHash = SHA256(salt || secret)`. La conception (§3.2) disait « hachage SHA-256 salé » sans préciser la stratégie de recherche ; embarquer le sel dans le jeton permet un lookup indexé unique tout en restant salé. Le brut n'est jamais persisté ni loggué.
3. **Rate limiting par propriétaire, pas par jeton** : la partition utilise le claim `NameIdentifier`. Un utilisateur avec plusieurs jetons partage un seul seau — plus simple et suffisant v1 ; clé par jeton possible en lot 06 sans changement d'API.
4. **Contrôleur renommé `McpTokensController`** (pluriel), conforme à la convention des contrôleurs existants ; la conception écrivait `McpTokenController`.
5. **`FrameworkReference Microsoft.AspNetCore.App`** dans le projet MCP : class library ASP.NET Core standard ; le projet ne référence toujours ni Infrastructure ni EF.
6. **404 explicite si désactivé** : sans endpoint dédié, un POST `/mcp` tombait dans le fallback SPA et renvoyait 405. Un endpoint minimal `Results.NotFound()` garantit le comportement attendu par la conception (§6).

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 41, ignorés : 0 (31 tests préexistants + 10 nouveaux, 26 s).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| Handshake `initialize` + `tools/list` avec PAT valide ; `ping` → `pong` | PASS | `Initialize_with_a_valid_pat_returns_server_info_and_lists_ping`, `Initialize_calls_the_ping_tool` |
| PAT révoqué / expiré / inconnu → 401 | PASS | `Mcp_endpoint_rejects_anonymous_unknown_and_revoked_tokens`, `Mcp_endpoint_rejects_expired_tokens` |
| JWT refusé sur `/mcp` (mais accepté sur l'API) | PASS | `Mcp_endpoint_rejects_the_application_jwt` |
| `Mcp:Enabled=false` → 404 | PASS | `Mcp_endpoint_returns_404_when_disabled` |
| Base : hachage seul stocké, jeton jamais listé après création | PASS | `Token_management_roundtrips_without_exposing_raw_values`, `Token_hashing_is_salted_stable_and_only_accepts_wellformed_values` |
| Endpoints de gestion fonctionnels avec JWT, inaccessibles anonyme, cloisonnés par utilisateur | PASS | `Token_management_roundtrips...`, `Token_management_is_scoped_to_the_owning_user`, `Token_creation_rejects_invalid_scopes_and_names` |
| Rate limiting (60 req/min) | Non exécuté | Implémenté (politique `mcp` sur `/mcp`), non testé — exigrait 61 requêtes par test ; à couvrir en recette manuelle (lot 06). |

## Limites et suites

- La revendication `expiresAt` n'est pas exposée par l'API de création (toujours null en v1) ; le test d'expiration insère directement un jeton périmé en base.
- Écran Flutter « Jetons MCP » et documentation utilisateur : lot 06.
- Le prochain lot est [Outils de lecture et résolution de références](../../../prompts/mcp-connector/02-outils-lecture.md) ; non commencé.
