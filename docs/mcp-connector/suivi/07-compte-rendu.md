# Revue du connecteur — Correctifs A à D

Branche `feat/mcp-connector`, à la suite des six lots de la conception. Quatre correctifs issus de la revue de l'implémentation MCP, un commit chacun, préfixe « MCP review fix A/B/C/D » (`40c0560`, `615cd58`, `19445d2`, `475bdd9`). Interdits respectés : aucune modification de `Disciplaner.Application` / `Disciplaner.Domain`, aucun endpoint REST existant modifié, aucun nouveau package (l'`IMemoryCache` du framework, déjà inclus via `FrameworkReference Microsoft.AspNetCore.App`, enregistré par `AddMemoryCache()` — TryAdd, donc idempotent).

## Correctif A — Écriture de `LastUsedAt` au plus toutes les 5 minutes

Problème : chaque requête MCP (`tools/list`, `tools/call` en lecture comprise) faisait un SELECT puis un UPDATE de `McpTokens.LastUsedAt`.

Correction : le SELECT (`GetByHashAsync`) reste à chaque requête (révocation immédiate). L'UPDATE n'est exécuté que si le token n'a pas d'entrée `mcp-lastuse-<id>` dans l'`IMemoryCache` — entrée glissante de 5 minutes, écrite après un flush réussi. Si aucun `IMemoryCache` n'est enregistré, on écrit comme avant : la télémétrie prime sur l'économie d'écritures.

| Fichier | Modif |
|---|---|
| `src/Disciplaner.Mcp/McpAuth/McpTokenAuthenticationHandler.cs` | +22 −1 (gate + constante `LastUsedFlushInterval`, `LastUsedCacheKeyPrefix`) |
| `src/Disciplaner.Mcp/DependencyInjection.cs` | +3 (`AddMemoryCache()`) |
| `tests/Disciplaner.Tests/McpConnectorTests.cs` | +53 |

Tests ajoutés : `Mcp_requests_close_together_flush_last_used_at_only_once` (deux appels rapprochés → un seul UPDATE, `LastUsedAt` identique) ; `Mcp_requests_flush_last_used_at_again_after_the_five_minute_window` (retrait de l'entrée cache simulant 5 min d'inactivité → second UPDATE, `LastUsedAt` postérieur). Commit `40c0560`.

## Correctif B — Filtrage de `tools/list` par portée du jeton

Problème : un jeton `read` voyait les 22 outils dans `tools/list` et échouait à l'appel des outils d'écriture.

Correction : filtre sur le pipeline `McpServerOptions.Filters.Request.ListToolsFilters` du SDK 2.3.0 (décorréle `WithToolsFromAssembly`, inchangé). Un jeton `read` ne voit que les outils `ReadOnly = true` (10) plus `ping` (aucun effet de bord) ; `read+write` voit tout ; requête sans claim de portée (anonyme, défensif — `/mcp` exige l'auth) : liste inchangée. `EnsureReadScope`/`EnsureWriteScope` restent dans chaque outil (défense en profondeur).

| Fichier | Modif |
|---|---|
| `src/Disciplaner.Mcp/McpAuth/McpScopeToolFilter.cs` | +50 (nouveau fichier) |
| `src/Disciplaner.Mcp/DependencyInjection.cs` | +2 (enregistrement du filtre) |
| `tests/Disciplaner.Tests/McpConnectorTests.cs` | +48 |

Tests ajoutés : `Tools_list_hides_write_tools_from_read_only_tokens` (11 outils, aucun outil d'écriture, `ping` présent) ; `Tools_list_shows_all_tools_to_read_write_tokens` (22 outils). Commit `615cd58`.

## Correctif C — Découverte d'authentification (RFC 9728)

Problème : un client conforme lançant la découverte OAuth recevait un 404 sur `/.well-known/oauth-protected-resource` puis un 401 nu sur `/mcp`, sans piste d'authentification.

Correction : `GET /.well-known/oauth-protected-resource` répond 200 avec le document RFC 9728 (`resource` = URL de base du serveur, champ `documentation` pointant vers le guide des jetons — configurable via `Mcp:PatDocumentationUrl`, pas de serveur d'autorisation). Le 401 de `/mcp` porte `WWW-Authenticate: Bearer resource_metadata="..."` via `HandleChallengeAsync` du handler d'authentification. Garde-fou de diagnostic uniquement : le PAT reste le choix assumé, aucun flux OAuth implémenté. Les deux endpoints répondent 404 quand `Mcp:Enabled=false`.

| Fichier | Modif |
|---|---|
| `src/Disciplaner.Mcp/McpAuth/ProtectedResource.cs` | +23 (nouveau fichier) |
| `src/Disciplaner.Mcp/McpAuth/McpTokenAuthenticationHandler.cs` | +13 (`HandleChallengeAsync`) |
| `src/Disciplaner.Mcp/McpOptions.cs` | +7 (`PatDocumentationUrl`) |
| `src/Disciplaner.Mcp/DependencyInjection.cs` | +7 (mapping, 404 si désactivé) |
| `tests/Disciplaner.Tests/McpConnectorTests.cs` | +57 |

Tests ajoutés : `Protected_resource_metadata_follows_rfc9728` ; `Mcp_unauthorized_responses_point_to_the_protected_resource_metadata` (401 + `WWW-Authenticate`) ; `Protected_resource_metadata_returns_404_when_mcp_is_disabled`. Commit `19445d2`.

## Correctif D — Hygiène

Suppression du `PropertyGroup` dupliqué de `Disciplaner.Mcp.csproj` (`TargetFramework`/`Nullable`/`ImplicitUsings` déclarés deux fois). Correction au passage d'un avertissement de nullabilité dans le filtre du correctif B. Choix maintenus exprès : `PingTools` conservé, `Mcp:Enabled` toujours évalué au démarrage, proxy stdio inchangé.

| Fichier | Modif |
|---|---|
| `src/Disciplaner.Mcp/Disciplaner.Mcp.csproj` | −6 |
| `src/Disciplaner.Mcp/McpAuth/McpScopeToolFilter.cs` | +1 −1 |

Tests ajoutés : aucun (modification de build). Commit `475bdd9`.

## Documentation

`docs/mcp-connector/02-guide-utilisateur.md` : mention du filtrage par portée dans `tools/list` (§1 et §4), nouvelle section « Erreurs d'authentification » au dépannage (§6 : document RFC 9728, header `WWW-Authenticate`, PAT sans OAuth), précision sur `LastUsedAt` indicatif (§5, flush au plus toutes les 5 min).

## Résultats de validation (réels)

- `dotnet test` (solution complète) : Réussi — échec : 0, réussite : **74** (67 existants + 7 nouveaux), ~26 s.
- Build `Disciplaner.Mcp` : 0 erreur ; plus aucun avertissement de nullabilité introduit par ce lot (les deux avertissements CS8714/CS8621 préexistants dans `McpServerPromptsTests.cs` sont inchangés).

## Limites connues

- Le fallback « sans cache » (écrire à chaque requête) n'a pas de test dédié : l'application enregistre désormais toujours un `IMemoryCache` ; le chemin est couvert par relecture de code uniquement.
- L'URL du document RFC 9728 est dérivée de `Request.Scheme`/`Request.Host` : derrière un reverse proxy sans forwarded headers, elle reflète l'URL interne (paramétrable côté proxy, hors périmètre).
- La recette avec un client réel (Claude Desktop/Cursor) reste à faire, comme identifié lors de la revue ; les tests du lot restent des tests d'intégration HTTP sur le même endpoint.
