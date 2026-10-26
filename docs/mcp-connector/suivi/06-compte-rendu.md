# Lot 06 — Transport stdio, prompts serveur, UI des jetons et documentation

Branche `feat/mcp-connector` (après `6ad8058`). Contrat commun appliqué ; fixtures et recette exclusivement locales et synthétiques (D08).

## Périmètre réalisé

- **Mode stdio** : `Transport/Stdio/Program.cs` — le projet `Disciplaner.Mcp` devient un exécutable `disciplaner-mcp` (`dotnet publish src/Disciplaner.Mcp -c Release`) ; avec `--stdio`, il se connecte au `/mcp` du serveur (`DISCIPLAN_URL`, `DISCIPLAN_PAT` en environnement) et **miroite les définitions d'outils du serveur** (`McpClient` + `McpServerTool.Create(AIFunction)`) : aucun outil réimplémenté, zéro dérive entre les deux transports. Logs sur stderr uniquement.
- **Prompts serveur** : `enrich-backlog` (décomposer un objectif produit en tickets à faire **valider avant** d'appeler `create_tickets`) et `sprint-review` (résumer le sprint actif) — `[McpServerPromptType]` + `WithPromptsFromAssembly`.
- **UI Flutter « Jetons MCP »** : section des Paramètres (`mcp_tokens_section.dart`) branchée de bout en bout (UI → provider Riverpod → `SettingsRepository` → API `/api/me/mcp-tokens`) : liste (nom, portée, création, dernière utilisation, statut révoqué), création avec choix de portée, affichage **unique** du jeton brut avec copie, révocation avec confirmation. i18n FR/EN (25 clés ARB).
- **Documentation** : `docs/mcp-connector/02-guide-utilisateur.md` (création de jeton, ChatGPT, Mistral, stdio Claude Desktop/Cursor, limites, dépannage) + section « MCP connector » du README racine.
- **Recette locale réelle** (exécutée) : serveur ASP.NET Core lancé sur base SQLite vierge temporaire, admin seedé, login JWT, création d'un PAT via l'API, puis `disciplaner-mcp --stdio` piloté en JSON-RPC : `initialize` OK, `tools/list` → **22 outils** (les 21 du connecteur + `ping`), `tools/call ping` → `pong`.

## Décisions techniques et écarts

1. **Proxy MCP plutôt que client REST embarqué** : le prompt du lot imaginait un client HTTP REST dans le binaire stdio ; la façade relaie plutôt le protocole MCP (`/mcp`) et miroite les définitions d'outils du serveur. Respecte l'intention (« aucune duplication d'outils », « mêmes définitions partagées ») avec strictement moins de code et aucune dérive possible ; documenté comme choix d'implémentation.
2. **Recette distante réelle (ChatGPT/Mistral)** : `Non exécuté` — aucun compte ni URL publique disponible dans cet environnement ; la partie locale (stdio) est réellement exécutée et le mode distant utilise exactement le même endpoint `/mcp` déjà couvert par 67 tests d'intégration.
3. Le binaire `disciplaner-mcp` est publié depuis `src/Disciplaner.Mcp` (le projet reste référencé par le serveur web, qui ignore son `Main`).

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 67 (66 + 1 nouveau test prompts), 28 s.
- `flutter analyze` : No issues found.
- `flutter test` : 57/57 réussis.
- Recette stdio locale : `initialize=OK, tools=22, ping=pong` (transcript dans ce compte rendu, §Périmètre).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| `disciplaner-mcp --stdio` répond au handshake et `tools/list` avec la même liste d'outils que le mode HTTP ; recette locale documentée | PASS | Recette locale réelle (22 outils = 21 + `ping`, identiques au `tools/list` HTTP) |
| Prompts `enrich-backlog` et `sprint-review` dans `prompts/list`, conformes (pas de création sans validation) | PASS | `McpServerPromptsTests` + recette locale |
| Écran Flutter « Jetons MCP » de bout en bout, jeton brut affiché uniquement à la création | PASS | `flutter analyze` 0 problème, 57 tests ; code branché sur les endpoints du lot 01 (eux-mêmes couverts par 10 tests d'intégration) |
| Documentation 3 clients + limites ; README racine à jour | PASS | `docs/mcp-connector/02-guide-utilisateur.md`, section README ; recette distante marquée Non exécuté avec justification |
| Build/tests .NET toujours verts | PASS | 67/67 |

## Limites et clôture

- L'image Docker n'a pas été reconstruite en intégralité (build Flutter web inclus) dans cet environnement ; le `Dockerfile` copie déjà le nouveau csproj (lot 01) et le `dotnet publish` du serveur référence le projet MCP normalement.
- Série terminée : les six lots de la conception sont livrés. Extensions futures (OAuth serveur-à-serveur, portées par projet, outils destructifs avec confirmation) : section 10 de la conception.
