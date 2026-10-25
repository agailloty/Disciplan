# Lot 02 — Outils de lecture et résolution de références

Branche `feat/mcp-connector` (après `3533023`). Contrat commun et conception appliqués ; fixtures exclusivement synthétiques (D08).

## Périmètre réalisé

- `McpReferenceResolver` (`src/Disciplaner.Mcp/Resolution/`) : résolution `projectKey` (insensible à la casse, restreinte aux projets accessibles), `DISC-42` → ticket (via `GetByRefAsync`, avec repli `ticket_id` GUID), nom de sprint dans un projet, nom de membre. Les ambiguïtés listent les candidats (`sprint_id`, statuts) ; les absences listent les valeurs connues.
- `McpToolContext` : utilisateur du principal PAT (même claim que le JWT), contrôle de portée (`read` / `read+write` pour les lots suivants), pagination normalisée (`limit` ≤ 100 refusé avec message explicite, défaut 50).
- `McpToolErrors` : traduction des exceptions applicatives (§7.2) en `McpException` actionnable — `NotFoundException` (avec pointeur vers `list_projects`/`list_sprints`), `ForbiddenException` (rôle Guest ou portée), `DomainException`/`ArgumentException` (message métier conservé).
- `Projections` : sorties compactes pour LLM — `ticketRef`/`projectKey` toujours présents, énumérations en chaînes, dates ISO, pages `{ items, totalCount, offset, limit }`.
- 9 outils de lecture dans `ProjectsTools` / `TicketsTools` / `SprintsTools` : `list_projects`, `get_project`, `list_members`, `list_ticket_statuses`, `list_labels`, `list_sprints`, `get_sprint`, `get_ticket`, `list_comments`. Tous annotés `[McpServerTool(ReadOnly = true)]` (readOnlyHint), descriptions en anglais documentant le format `DISC-42`, `UseStructuredContent = true`.
- Enregistrement DI : `McpToolContext`, `McpReferenceResolver`, `AddHttpContextAccessor()`.
- Tests : `McpReadToolsTests` (11 tests), via JSON-RPC réel sur `/mcp`.

## Décisions techniques et écarts par rapport à la conception

1. **`list_labels` sans `project_key`** : les labels sont un catalogue global dans Disciplaner (le REST existant `GET /api/labels` les liste tous) ; la conception (§5.1) imaginait une portée projet qui n'existe pas dans le modèle. L'outil liste le catalogue et sa description précise que les tickets portent les labels qui s'y appliquent. Écart documenté ; aucun changement du backend n'a été fait pour cela.
2. **`list_sprints` sans `project_key`** : `GetWithDatesForUserAsync` ne renvoie que les sprints **datés** (les sprints Planned du fixture en étaient exclus). L'outil itère les projets accessibles (`GetAllByUserAsync` → `GetByProjectAsync`), ce qui couvre tous les statuts avec les mêmes vérifications de droits. `GetByProjectAsync` ne remplit pas `ProjectKey` sur les DTO : la clé est passée explicitement à la projection.
3. **Erreurs d'outil** : levées comme `McpException` (SDK) ; constaté en test : le serveur renvoie un `tools/call` avec `isError: true` et le message dans le contenu — exploitable directement par un LLM.
4. **Structured content** : `UseStructuredContent = true` sur tous les outils de lecture ; les tests lisent `structuredContent` (avec repli sur le texte JSON) — camelCase vérifié (`ticketRef`, `projectKey`).

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 52 (41 précédents + 11 nouveaux, 26 s).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| `tools/list` décrit les 9 outils, `readOnlyHint: true`, descriptions anglaises + format `DISC-42` | PASS | `Tools_list_exposes_the_nine_read_tools_with_readOnly_hint`, `Tool_descriptions_are_in_english_and_document_the_ticket_reference_format` |
| Guest lit tickets et commentaires de son projet | PASS | `Guest_reads_project_tickets_and_comments` |
| Non-membre → erreur actionnable (permission) ; clé hors périmètre → clés alternatives listées | PASS | `Non_member_gets_actionable_errors` |
| `DISC-42` / `disc-42` identiques ; ref inconnue et ref mal formée → messages §7.2 | PASS | `Ticket_references_resolve_case_insensitively_and_unknown_refs_are_actionable` |
| Deux sprints homonymes → candidats + `sprint_id` listés | PASS | `Ambiguous_sprint_name_lists_candidates` |
| Pagination : `limit=200` refusé (« at most 100 ») ; pages `limit/offset` correctes | PASS | `Pagination_refuses_limits_above_100_and_pages_members` |
| `get_sprint` renvoie tickets ; `list_sprints` borné aux projets accessibles | PASS | `Get_sprint_returns_its_tickets_and_list_sprints_scopes_to_accessible_projects` |
| `get_project` : statuts avec catégories, membres avec rôles | PASS | `Get_project_returns_statuses_members_and_defaults`, `List_ticket_statuses_returns_categories` |

## Limites et suites

- Le sprint dupliqué du test d'ambiguïté est inséré par SQL brut (le constructeur `Sprint` est `internal` au Domain et `Project.AddSprint` heurte le token de concurrence `NextTicketNumber` figé par le fixture) — impact limité au test.
- Le prochain lot est [Écriture de tickets et commentaires](../../../prompts/mcp-connector/03-ecriture-tickets.md) ; non commencé.
