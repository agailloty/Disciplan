# Lot 03 — Écriture de tickets et commentaires

Branche `feat/mcp-connector` (après `a423a42`). Contrat commun et conception appliqués ; fixtures exclusivement synthétiques (D08).

## Périmètre réalisé

- `TicketsWriteTools` : `create_ticket`, `update_ticket`, `assign_ticket`, `move_ticket_to_sprint`, `add_comment` — tous en `read+write` (via `McpToolContext.EnsureWriteScope`), adaptateurs fins de `ITicketService`/`ICommentService`.
- `McpInputParsing` : énumérations (`Story|Bug|Task|Epic|Subtask`, `Low|Medium|High|Critical`) et dates ISO 8601 avec messages d'erreur listant les valeurs valides.
- Résolutions préalables dans les outils : sprint du projet (nom ou id, rejet inter-projet explicite), ticket parent (rejet inter-projet explicite), assigné par nom de membre.
- Lien profond (`{base}/tickets/{ticketRef}`) retourné par chaque outil d'écriture de ticket.
- Amélioration du résolveur (effet sur le lot 02, test mis à jour) : un ticket dont le projet n'est pas accessible renvoie « Ticket FIXB-1 was not found in your accessible projects... » au lieu d'un message générique sur le GUID du projet.
- Aucune constante de longueur recopiée : les limites (`DomainConstraints`) sont appliquées par les services, dont les `DomainException`/`ArgumentException` remontent traduites.
- Aucun outil destructif exposé (M06 vérifié) ; `tools/list` ne contient aucun `delete_*`.

## Décisions techniques

1. **Sémantique nulle des champs d'`update_ticket`** : seuls les champs fournis changent ; l'assigné n'est pas modifié s'il est omis (la désassignation passe par `assign_ticket` sans arguments). La description de l'outil le documente.
2. **`story_points`/`due_date`** : pas de remise à zéro en v1 (non demandé par le prompt du lot).
3. **Réponses** : `{ ticketRef, url, ticket: {...} }` — la valeur brute sérialisée omet les propriétés null (comportement du SDK), vérifié en test.
4. **Préfixe d'erreur SDK** : le SDK préfixe les messages d'exception (« An error occurred invoking 'create_ticket': ... ») ; les messages métier restent intégraux et actionnables — constat documenté, aucun contournement tenté.

## Résultats de validation (réels)

- `dotnet build Disciplaner.slnx` : Réussite, 0 erreur, 0 avertissement.
- `dotnet test Disciplaner.slnx` : Réussi — échec : 0, réussite : 57 (52 + 5 nouveaux, 25 s).

## Statut des critères d'acceptation

| Critère | Statut | Preuve |
|---|---|---|
| PAT `read+write` d'un Member : création, modification, assignation, commentaire, déplacement sprint→backlog ; historique renseigné | PASS | `Member_creates_updates_assigns_moves_and_comments_a_ticket` (histoire « created » lue en REST par le propriétaire) |
| PAT `read` refusé sur les 5 outils avec message de portée, sans effet de bord | PASS | `Read_scope_tokens_are_refused_on_every_write_tool` |
| Guest refusé en écriture par la matrice de rôles existante | PASS | `Guests_are_refused_by_the_role_matrix` |
| `assign_ticket` : inconnu → membres connus listés ; désassignation | PASS | `Member_creates...` (désassignation), `Invalid_enums_members_...` (membres listés) |
| `create_ticket` avec parent d'un autre projet → message explicite | PASS | `Invalid_enums_members_and_cross_project_relations_give_actionable_errors` |
| `tools/list` sans outil de suppression ni d'administration | PASS | vérifié dans le test lot 02 + tri des outils |

## Limites et suites

- L'historique de ticket n'est lisible en REST que par le propriétaire du projet — l'assertion d'audit utilise donc le compte `owner`.
- Le prochain lot est [Gestion des sprints](../../../prompts/mcp-connector/04-sprints.md) ; non commencé.
