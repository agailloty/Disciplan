# Lot 04 — Gestion des sprints

Branche `feat/mcp-connector` (après `4f22574`). Contrat commun et conception appliqués ; fixtures exclusivement synthétiques (D08).

## Périmètre réalisé

- Quatre outils d'écriture de sprint dans `SprintsTools` : `create_sprint`, `start_sprint`, `close_sprint`, `update_sprint`.
- Résolution homogène : `sprint_id` ou `sprint_name` + `project_key` via le même `ResolveSprintAsync` que `get_sprint` (aucune divergence d'acceptation d'identifiants entre outils, exigence du prompt).
- `update_sprint` partiel : seuls les champs fournis changent (les autres sont relus depuis le sprint).
- Descriptions documentant le cycle Planned → Active → Closed, l'unicité du sprint actif, le format ISO 8601 et le rôle requis.
- Tests : `McpSprintToolsTests` (3 tests).

## Décisions techniques

1. **Rôle requis réel : Supervisor** — la conception et le prompt visaient « un Guest ne peut... » ; le service applicatif exige en fait `CanManage` (≥ Supervisor) pour créer/démarrer/clôturer (planification = Supervisor selon D05). Les tests l'utilisent : cycle complet avec `supervisor`, refus documenté pour un Member, refus Guest implicite via la matrice. Aucun droit modifié.
2. **`SprintDto.ToDto` sans clé projet** : comme au lot 02, la clé est passée explicitement aux projections.

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 60 (57 + 3 nouveaux, 25 s).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| Cycle complet via outils uniquement : create → move ticket → start → close, états intermédiaires vérifiables par `get_sprint` | PASS | `Sprint_lifecycle_runs_entirely_through_tools` (Planned → Active → Closed, ticket FIXA-1 présent) |
| Double démarrage refusé avec le message métier, sans état incohérent | PASS | idem (`start_sprint` sur « Sprint 43 » pendant que « Sprint 42 » est actif) |
| Guest/Member ne peuvent pas gérer ; PAT `read` refusé sur les 4 outils | PASS | `Members_cannot_manage_sprints_and_read_tokens_cannot_write` |
| Sprint d'un projet non accessible non adressable par id ; ambiguïté → candidats + `sprint_id` | PASS | ambiguïté : `Sprint_lifecycle...` ; non-membre : couvert par la résolution du lot 02 (`get_sprint` inconnu → message) |
| Dates invalides et sprint inconnu → messages actionnables | PASS | `Invalid_dates_and_unknown_sprints_give_actionable_errors` |

## Limites et suites

- La clôture de sprint ne fait pas de report automatique de tickets (choix produit existant) ; la description de `close_sprint` oriente le LLM vers `move_ticket_to_sprint` pour replanifier.
- Le prochain lot est [Batch, clôture de ticket et recherche](../../../prompts/mcp-connector/05-batch-close-recherche.md) ; non commencé.
