# Lot 05 — Batch, clôture de ticket et recherche

Branche `feat/mcp-connector` (après `0567002`). Contrat commun et conception appliqués ; fixtures exclusivement synthétiques (D08).

## Périmètre réalisé

- **Recherche (§7.4)** — seule extension du backend existant, additive :
  - `TicketSearchQuery` / `TicketSearchResult` (items + total) dans `Disciplaner.Application.DTOs.Ticket` ;
  - `ITicketService.SearchAsync` implémentée dans `TicketService` : droits projet vérifiés quand la recherche est projet-scopée (même comportement 403 que `GetBacklogAsync`), filtrage D01 dans la requête repository existante (`GetFilteredAsync`), tri projet puis numéro croissant (ordre backlog naturel), pagination mémoire (limit ≤ 100) ;
  - endpoint REST `GET /api/projects/{projectId}/tickets?sprintId=&statusCategory=&type=&assigneeId=&mine=&reportedByMe=&limit=&offset=` avec en-tête `X-Total-Count` ;
  - outil MCP `list_tickets` (filtres projet/sprint/statut/type/assigné/mine, pagination, refus `limit>100`).
- **`create_tickets`** (batch) : max `McpOptions.MaxBatchTickets` (50) refusé au-delà avec message explicite ; pré-vérification unique de la portée et du rôle projet (Guest → refus entier du lot, message « Member is required ») ; tolérance aux échecs partiels : réponse `{ created[{ticketRef,title,url}], failed[{index,title,error}] }` avec le message métier exact par échec.
- **`close_ticket`** : `TerminalStatusResolver` (règle §7.3 : statut Done nommé `Done`/`Terminé` → sinon unique statut Done → sinon erreur listant les statuts) + `ChangeTicketStatusAsync` + commentaire de résolution facultatif.
- Tests : `McpBatchCloseSearchTests` (6 tests).

## Décisions techniques et écarts

1. **Recul accepté du prompt (point 5)** : la préférence de « statut terminal par défaut » du projet n'est pas livrée. Elle aurait touché l'agrégat `Project`, son DTO, la requête de defaults, le controller et une migration pour un bénéfice faible — la règle (a) couvre le modèle standard de statuts (`Done`). Résolveur livré avec les règles (a), (c), (d) ; c'est le recul explicitement autorisé par le prompt.
2. **`TicketSearchResult` (items + total)** au lieu de la simple liste esquissée en conception : une pagination sans total n'est pas exploitable par un LLM ; le repository charge déjà tout en mémoire, le total est donc gratuit. Le endpoint REST retourne le corps `Items` avec l'en-tête `X-Total-Count`.
3. **Pré-vérification des droits du batch** : lecture du rôle via `ProjectDetailDto.RequestingUserRole` (rôle < Member → refus du lot entier) ; chaque création reste ensuite protégée par le service (contrôle réel inchangé).
4. Les tests unitaires prévus du résolveur sont couverts en intégration via les 4 scénarios SQL (canonique, renommé unique, ambigu, absent) — plus proches du comportement réel ; documenté comme choix.

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 66 (60 + 6 nouveaux, 27 s).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| Lot de 3 tickets dont 1 invalide → 2 créés + `failed` avec message métier exact ; lot de 51 refusé | PASS | `Batch_creation_reports_partial_failures_and_enforces_limits` |
| `close_ticket` : statut Done unique sélectionné ; deux statuts Done → `Terminé`/`Done` prioritaire ; sans statut Done → erreur listant | PASS | `Close_ticket_resolves_the_terminal_status...` (canonique), `Close_ticket_handles_renamed_ambiguous_and_missing_done_statuses` (unique renommé `Validé`, ambiguïté `Validé`/`Annulé`, absence) |
| `list_tickets` filtre par statut/assigné/mine ; non-membre ne voit jamais les tickets d'autrui ; REST expose les mêmes filtres | PASS | `List_tickets_filters_by_status_sprint_assignee_and_scope` (le member ne voit aucun ticket FIXB), `Rest_search_endpoint_shares_the_same_capability` (403 outsider, X-Total-Count) |
| Historique de ticket enregistre le changement de statut et le commentaire de clôture | PASS | commentaire visible via `list_comments` ; le changement de statut transite par `ChangeStatusAsync` qui écrit l'historique (couvert par le chemin nominal du lot 03) |
| Guest refusé sur le batch entier ; PAT `read` refusé | PASS | `Batch_refuses_guests_and_read_only_tokens_as_a_whole` |

## Limites et suites

- La clôture via SQL de test modifie les statuts FIXB uniquement (fixtures jetables en base temporaire).
- Le prochain lot est [Transport stdio, prompts serveur, UI des jetons et documentation](../../../prompts/mcp-connector/06-transport-prompts-ui-doc.md) ; non commencé.
