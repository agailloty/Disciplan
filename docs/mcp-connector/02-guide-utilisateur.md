# Guide utilisateur — Connecteur MCP Disciplaner

Le connecteur MCP expose Disciplaner aux assistants IA compatibles [Model Context Protocol](https://modelcontextprotocol.io) : Mistral, ChatGPT, Claude Desktop, Cursor, VS Code, etc. L'assistant peut alors consulter vos projets et, selon la portée du jeton, créer des tickets, commenter, gérer les sprints et enrichir le backlog en votre nom — sous le contrôle des mêmes rôles que l'application (un Guest ne lit que, un Member écrit, un Supervisor gère les sprints).

## 1. Créer un jeton d'accès

1. Ouvrez l'application → **Paramètres** → section **Jetons MCP**.
2. **Créer un jeton** : donnez-lui un nom (ex. `Claude Desktop`) et choisissez la portée :
   - **Lecture seule** (`read`) : l'assistant peut consulter projets, tickets, sprints et commentaires.
   - **Lecture + écriture** (`read+write`) : il peut en plus créer/modifier des tickets, commenter, gérer les sprints.
3. Copiez immédiatement le jeton affiché (`dcp_...`) : il ne sera **jamais** réaffiché. En cas de perte, révoquez et recréez.
4. **Révoquer** à tout moment depuis la même liste — la révocation est immédiate.

Les jetons sont personnels : ils agissent avec vos droits dans chaque projet. Un outil d'écriture appelé avec un jeton en lecture seule est refusé.

## 2. Client distant (ChatGPT, Mistral)

Pour les clients qui se connectent à un serveur MCP public :

- **URL du serveur MCP** : `https://<votre-serveur-disciplan>/mcp`
- **Authentification** : clé API / Bearer token — collez le jeton `dcp_...`.

Le serveur Disciplaner étant auto-hébergé, il doit être exposé en HTTPS (reverse-proxy ou tunnel) pour ChatGPT ; Mistral accepte les en-têtes personnalisés. Vérifiez auprès de votre client la syntaxe exacte (en-tête `Authorization: Bearer dcp_...`).

### ChatGPT (connecteurs / Developers)

1. Créez le jeton dans Disciplaner (portée selon l'usage).
2. Dans les réglages ChatGPT → Connecteurs / Apps développeur : URL `https://<serveur>/mcp`, authentification « API key », collez le jeton.
3. Activez le connecteur, puis demandez par exemple : *« Liste mes projets Disciplaner »*.

### Mistral

Dans la configuration MCP de Mistral (paramètres de l'assistant/outils), ajoutez un serveur MCP avec l'URL `https://<serveur>/mcp` et l'en-tête d'authentification `Authorization: Bearer dcp_...`.

## 3. Client local (Claude Desktop, Cursor) — mode stdio

Quand votre serveur n'est pas exposé publiquement, utilisez le proxy local `disciplaner-mcp`, qui relaie les mêmes outils via stdio :

```bash
dotnet publish src/Disciplaner.Mcp -c Release -o ./out   # produit disciplaner-mcp(.exe)
```

Configuration client (bloc `mcpServers`) :

```json
{
  "mcpServers": {
    "disciplaner": {
      "command": "disciplaner-mcp",
      "args": ["--stdio"],
      "env": {
        "DISCIPLAN_URL": "http://localhost:5027",
        "DISCIPLAN_PAT": "dcp_..."
      }
    }
  }
}
```

`DISCIPLAN_URL` est l'URL de base du serveur (le proxy se connecte à `<URL>/mcp`), `DISCIPLAN_PAT` votre jeton. Le proxy miroite exactement les outils du serveur : aucune mise à jour côté client quand le serveur évolue.

## 4. Ce que l'assistant peut faire

Lecture (portée `read`) : `list_projects`, `get_project`, `list_members`, `list_ticket_statuses`, `list_labels`, `list_sprints`, `get_sprint`, `get_ticket`, `list_tickets`, `list_comments`, `ping`.

Écriture (portée `read+write`) : `create_ticket`, `create_tickets` (lots jusqu'à 50), `update_ticket`, `assign_ticket`, `move_ticket_to_sprint`, `close_ticket`, `add_comment`, `create_sprint`, `start_sprint`, `close_sprint`, `update_sprint`.

Deux prompts prêts à l'emploi guident les usages courants : **enrich-backlog** (transformer un objectif produit en tickets à valider avant création) et **sprint-review** (résumé du sprint actif).

Conventions utiles à connaître : les tickets sont référencés `CLE-numéro` (ex. `FIXA-42`), les projets par leur clé courte ; les listes sont paginées (`limit` ≤ 100, `offset`) ; les dates sont ISO 8601 ; les ambiguïtés (deux sprints homonymes...) produisent une erreur listant les candidats — l'assistant vous requestionnera.

## 5. Limites et garde-fous

- **Aucune suppression** n'est exposée au connecteur : tickets, sprints, projets et membres ne peuvent pas être supprimés par un assistant.
- Les lots `create_tickets` sont plafonnés à 50 tickets ; un lot trop grand est refusé.
- Chaque jeton est limité en débit (60 requêtes/minute par défaut, réglable via `Mcp:RateLimitPerMinute`).
- Le connecteur peut être désactivé entièrement : `Mcp:Enabled=false` dans `appsettings.json` (l'endpoint `/mcp` répond alors 404).
- Toute écriture reste tracée : l'historique de ticket et le nom du jeton (`LastUsedAt`) attestent de l'origine.

## 6. Dépannage

| Symptôme | Cause probable / action |
|---|---|
| 401 sur `/mcp` avec le jeton | Jeton mal copié, révoqué, ou JWT de l'application utilisé au lieu d'un jeton MCP (`dcp_...`). |
| 404 sur `/mcp` | `Mcp:Enabled=false`, ou URL incorrecte (l'endpoint est `<base>/mcp`). |
| 429 | Débit dépassé — ralentissez ou augmentez `Mcp:RateLimitPerMinute`. |
| « This token is read-only » | Créez un jeton avec la portée Lecture + écriture. |
| Proxy stdio silencieux | Vérifiez `DISCIPLAN_URL` (base, sans `/mcp`) et `DISCIPLAN_PAT` ; les logs du proxy vont sur stderr. |
| Assistant ne voit pas un projet | Le jeton agit avec vos droits : demandez une invitation dans le projet concerné. |
