# Lot 06 — Transport stdio, prompts serveur, UI des jetons et documentation

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md) et la [conception](../../docs/mcp-connector/01-conception-architecture.md), sections 5.5, 6 et 10 (M05). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan. Ce lot est le seul autorisé à toucher `src/Disciplaner.Flutter`.

## Prérequis

Lots 01–05 terminés. Vérifie les comptes rendus dans `docs/mcp-connector/suivi/` avant de poursuivre.

## Fichiers de départ

`src/Disciplaner.Mcp/` ( outils et fondation ) ; `src/Disciplaner.Web/Server/Controllers/UsersController.cs` et les écrans de paramètres du client Flutter ( `src/Disciplaner.Flutter/lib/` — profil/paramètres, couche réseau, providers Riverpod ) ; `docs/mcp-connector/` ; `README.md` à la racine. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. **Mode stdio (M05)** : ajoute une façade de transport stdio au même projet `Disciplaner.Mcp` ( point d'entrée `--stdio` ), qui exécute les mêmes outils en relayant vers l'API REST via un client HTTP embarqué configurable par `DISCIPLAN_URL` et `DISCIPLAN_PAT`. Aucune duplication d'outils : les définitions d'outils sont partagées entre les deux transports, seuls les adaptateurs d'appel diffèrent. Vise un binaire publiable en `disciplaner-mcp`.
2. **Prompts serveur (§5.5)** : expose deux prompts MCP — `enrich-backlog` ( transformer un objectif produit brut en tickets structurés à faire **valider par l'utilisateur avant** d'appeler `create_tickets` ) et `sprint-review` ( résumer le sprint actif d'un projet : ouvert, en cours, fait, points ). Les prompts ne contiennent que des instructions et des appels d'outils existants ; aucune logique serveur.
3. **UI Flutter de gestion des jetons** : dans l'espace paramètres/profil du client, un écran « Jetons MCP » branché de bout en bout ( UI → provider Riverpod → repository → API `/api/me/mcp-tokens` ) : liste des jetons ( nom, portée, création, dernière utilisation, statut révoqué ), création ( nom + portée ) avec affichage unique du jeton brut et copie, révocation avec confirmation. Respecte le Design System Neo-Linear du client ( densité, thèmes, états vide/erreur/chargement ). Aucune fonctionnalité factice.
4. **Documentation utilisateur** : complète `docs/mcp-connector/` avec un guide d'utilisation couvrant : création d'un jeton dans l'application, configuration du connecteur distant dans ChatGPT ( URL `https://.../mcp` + clé API Bearer, prérequis HTTPS public ) et dans Mistral, configuration du mode local stdio ( bloc `mcpServers` JSON pour Claude Desktop/Cursor ), limites connues ( pas d'outils destructifs, portées, batch max ), dépannage de base ( 401, 404, jeton révoqué ).
5. **Recette manuelle documentée** : rédige la procédure de recette manuelle trois clients ( un distant, un stdio ) et execute-la au minimum contre le mode stdio local avec des fixtures synthétiques ; consigne les résultats au compte rendu. La recette distante réelle ( URL publique ) peut rester `Non exécuté` si l'environnement ne le permet pas — dis-le explicitement.
6. Mets à jour le `README.md` racine : une section « Connecteur MCP » courte avec le lien vers la documentation.

## Critères d'acceptation

- `disciplaner-mcp --stdio` répond au handshake et à `tools/list` avec la même liste d'outils que le mode HTTP ; une recette manuelle locale ( stdio ) est documentée avec résultats réels.
- Les prompts `enrich-backlog` et `sprint-review` apparaissent dans `prompts/list` et produisent des instructions conformes ( aucune création de ticket sans validation utilisateur pour `enrich-backlog` ).
- L'écran Flutter « Jetons MCP » fonctionne de bout en bout : `flutter analyze` sans erreur ni warning bloquant, `flutter test` passe ; le jeton brut n'apparaît qu'au moment de la création.
- La documentation utilisateur couvre les trois clients et les limites ; le compte rendu distingue `PASS` / `FAIL` / `Non exécuté` pour chaque partie de la recette.
- `dotnet build Disciplaner.slnx` et `dotnet test tests/Disciplaner.Tests` passent toujours.

## Livrables et transmission

Façade stdio, prompts serveur, écran Flutter « Jetons MCP », guide d'utilisation, recette manuelle, mise à jour du README racine.

Crée `docs/mcp-connector/suivi/06-compte-rendu.md` selon le contrat commun, avec résultats réels de build, de tests et de recette. Committe avec :

```
feat(mcp): add stdio transport, server prompts, token management UI and user guide
```

Ce lot est le dernier de la série. Le connecteur est alors complet au sens de la conception ; toute extension ( OAuth, outils destructifs avec confirmation, portées par projet ) relève d'une nouvelle série de prompts et de la section 10 de la conception.
