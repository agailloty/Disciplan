# Prompts d'implémentation du connecteur MCP Disciplaner

Ce dossier contient 6 lots d'implémentation, à exécuter dans l'ordre. Le document de référence est la [conception architecturale](../../docs/mcp-connector/01-conception-architecture.md), notamment ses décisions M01–M07.

## Mode d'emploi

Donner à l'agent le contenu du [contrat commun](00-contrat-agent.md), puis un seul prompt numéroté. Un agent avec accès au dépôt peut recevoir cette instruction :

> Lis `prompts/mcp-connector/00-contrat-agent.md` puis `prompts/mcp-connector/01-fondation.md` et exécute ce lot. Produis les changements et preuves demandés, puis son compte rendu. Ne passe pas au lot suivant avant validation de ses critères.

Une nouvelle session doit relire le contrat, la conception et les comptes rendus des lots préalables dans `docs/mcp-connector/suivi/`.

## Ordre des lots

| Lot | Prompt | Résultat |
|---|---|---|
| 01 | [Fondation : projet MCP, jetons PAT et endpoint /mcp](01-fondation.md) | Aucun lot préalable ; lire la conception. |
| 02 | [Outils de lecture et résolution de références](02-outils-lecture.md) | Lot 01 terminé. |
| 03 | [Écriture de tickets et commentaires](03-ecriture-tickets.md) | Lot 02 terminé. |
| 04 | [Gestion des sprints](04-sprints.md) | Lot 03 terminé. |
| 05 | [Batch, clôture de ticket et recherche](05-batch-close-recherche.md) | Lot 04 terminé. |
| 06 | [Transport stdio, prompts serveur, UI des jetons et documentation](06-transport-prompts-ui-doc.md) | Lot 05 terminé. |

## Traçabilité conception → lots

| Décision / section | Lots |
|---|---|
| M01 (serveur embarqué, projet `Disciplaner.Mcp`) | 01 |
| M02 (PAT, portées, ClaimsPrincipal identique au JWT) | 01, 03 |
| M03 (outils = adaptateurs des services) | 02–05 |
| M04 (références lisibles, `McpReferenceResolver`) | 02, 04 |
| M05 (Streamable HTTP + stdio) | 01, 06 |
| M06 (aucun outil destructif) | vérification transversale 02–05 |
| M07 (erreurs actionnables) | 02, 03, 05 |
| §7.3 (`TerminalStatusResolver`, `close_ticket`) | 05 |
| §7.4 (`SearchAsync`, `list_tickets`) | 05 |
| §6 (configuration, clients distants et locaux) | 01, 06 |

Aucun changement de l'application n'a été réalisé par la préparation de ce dossier. Les comptes rendus seront créés par l'agent dans `docs/mcp-connector/suivi/`.
