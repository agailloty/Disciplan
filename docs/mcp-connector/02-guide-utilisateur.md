# Guide utilisateur — Connecteur MCP Disciplaner

Le connecteur MCP expose Disciplaner aux assistants IA compatibles [Model Context Protocol](https://modelcontextprotocol.io) : Mistral, ChatGPT, Claude Desktop, Cursor, VS Code, etc. L'assistant peut alors consulter vos projets et, selon la portée du jeton, créer des tickets, commenter, gérer les sprints et enrichir le backlog en votre nom — sous le contrôle des mêmes rôles que l'application (un Guest ne lit que, un Member écrit, un Supervisor gère les sprints).

## 1. Authentification

Le connecteur supporte deux modes d'authentification :

### A. Authentification OAuth 2.1 (recommandée pour clients modernes)

Disciplaner implémente la spécification standard **Model Context Protocol Authorization** basée sur OAuth 2.1 et les RFCs associées :
- **RFC 9728 (OAuth Protected Resource Metadata)** : découverte automatique via `GET /.well-known/oauth-protected-resource`
- **RFC 8414 (OAuth Authorization Server Metadata)** : métadonnées d'autorisation via `GET /.well-known/oauth-authorization-server`
- **RFC 7591 (Dynamic Client Registration)** : enregistrement automatique des clients (`POST /oauth/register`)
- **RFC 7636 (PKCE avec S256)** et Authorization Code Flow (`/oauth/authorize`, `/oauth/token`)
- **RFC 7009 (Token Revocation)** : révocation via `POST /oauth/revoke`

Les clients compatibles (Claude Desktop, Cursor, assistants web...) peuvent s'enregistrer et s'authentifier automatiquement :
1. Le client contacte `https://<serveur>/mcp`.
2. Le serveur répond avec un challenge HTTP 401 et l'en-tête `WWW-Authenticate: Bearer resource_metadata="https://<serveur>/.well-known/oauth-protected-resource"`.
3. Le client découvre les métadonnées, s'enregistre dynamiquement et ouvre le navigateur pour le consentement.
4. L'utilisateur valide l'autorisation sur l'écran d'approbation Disciplaner (portée `read` ou `read+write`).
5. Le client échange le code avec PKCE et reçoit son jeton d'accès (`dcp_at_...`) et son jeton de rafraîchissement (`dcp_rt_...`).
6. L'utilisateur peut lister et révoquer ses autorisations à tout moment via `GET /api/me/oauth-authorizations` et `DELETE /api/me/oauth-authorizations/{id}`.

### B. Jetons d'accès personnels (PAT)

Pour les clients ou configurations manuelles statiques :
1. Ouvrez l'application → **Paramètres** → section **Jetons MCP**.
2. **Créer un jeton** : donnez-lui un nom (ex. `Claude Desktop`) et choisissez la portée :
   - **Lecture seule** (`read`) : l'assistant peut consulter projets, tickets, sprints et commentaires.
   - **Lecture + écriture** (`read+write`) : il peut en plus créer/modifier des tickets, commenter, gérer les sprints.
3. Copiez immédiatement le jeton affiché (`dcp_...`) : il ne sera **jamais** réaffiché. En cas de perte, révoquez et recréez.
4. **Révoquer** à tout moment depuis la même liste — la révocation est immédiate.

Les jetons sont personnels : ils agissent avec vos droits dans chaque projet. La portée filtre aussi la liste des outils : un jeton en lecture seule ne voit que les outils de lecture dans `tools/list` (les outils d'écriture sont masqués, et refusent l'appel s'ils sont quand même invoqués).

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

Avec un jeton `read`, `tools/list` ne retourne que les outils de lecture ci-dessus ; avec `read+write`, les 22 outils.

Deux prompts prêts à l'emploi guident les usages courants : **enrich-backlog** (transformer un objectif produit en tickets à valider avant création) et **sprint-review** (résumé du sprint actif).

Conventions utiles à connaître : les tickets sont référencés `CLE-numéro` (ex. `FIXA-42`), les projets par leur clé courte ; les listes sont paginées (`limit` ≤ 100, `offset`) ; les dates sont ISO 8601 ; les ambiguïtés (deux sprints homonymes...) produisent une erreur listant les candidats — l'assistant vous requestionnera.

## 5. Limites et garde-fous

- **Aucune suppression** n'est exposée au connecteur : tickets, sprints, projets et membres ne peuvent pas être supprimés par un assistant.
- Les lots `create_tickets` sont plafonnés à 50 tickets ; un lot trop grand est refusé.
- Chaque jeton est limité en débit (60 requêtes/minute par défaut, réglable via `Mcp:RateLimitPerMinute`).
- Le connecteur peut être désactivé entièrement : `Mcp:Enabled=false` dans `appsettings.json` (l'endpoint `/mcp` répond alors 404).
- Toute écriture reste tracée : l'historique de ticket et le nom du jeton attestent de l'origine. L'horodatage de dernière utilisation (`LastUsedAt`) est persisté au maximum toutes les 5 minutes par jeton : c'est une information indicative, pas un journal d'audit.

## 6. Dépannage

### Erreurs d'authentification

Le connecteur implémente **OAuth 2.1** selon les spécifications MCP et accepte également les jetons personnels (`Authorization: Bearer dcp_...`) :
- Si vous utilisez un flux automatique OAuth (Claude Desktop, Cursor...), le client est dirigé vers `/.well-known/oauth-protected-resource` et le serveur d'autorisation (`/oauth/authorize`, `/oauth/token`).
- Si vous configurez manuellement un PAT, assurez-vous de renseigner le jeton `dcp_...` complet dans l'en-tête `Authorization: Bearer dcp_...`.

### Table des symptômes

| Symptôme | Cause probable / action |
|---|---|
| 401 sur `/mcp` avec le jeton | Jeton mal copié, révoqué, ou JWT de l'application utilisé au lieu d'un jeton MCP (`dcp_...`). Le 401 pointe vers `/.well-known/oauth-protected-resource` pour le diagnostic. |
| 404 sur `/mcp` | `Mcp:Enabled=false`, ou URL incorrecte (l'endpoint est `<base>/mcp`). |
| 429 | Débit dépassé — ralentissez ou augmentez `Mcp:RateLimitPerMinute`. |
| « This token is read-only » | Créez un jeton avec la portée Lecture + écriture. Les outils d'écriture n'apparaissent d'ailleurs pas dans `tools/list` d'un jeton en lecture seule. |
| Proxy stdio silencieux | Vérifiez `DISCIPLAN_URL` (base, sans `/mcp`) et `DISCIPLAN_PAT` ; les logs du proxy vont sur stderr. |
| Assistant ne voit pas un projet | Le jeton agit avec vos droits : demandez une invitation dans le projet concerné. |
