# Connexion du MCP Disciplaner dans un client chat (ChatGPT, Mistral, Claude, Cursor...)

Ce guide détaille pas à pas comment connecter le serveur **Model Context Protocol (MCP)** de Disciplaner à vos assistants et clients chat IA préférés : **ChatGPT**, **Mistral AI (Le Chat / Agents)**, **Claude Desktop**, **Cursor**, **LibreChat**, **Open WebUI**, etc.

Disciplaner supporte deux modes d'authentification pour le connecteur MCP :
1. **Bearer Token (Personal Access Token - PAT)** : statique, simple, immédiat, idéal pour les clients demandant une clé API ou un token Bearer (Mistral Le Chat, ChatGPT en clé API, LibreChat, configurations stdio).
2. **OAuth 2.1 avec PKCE** : conforme au standard officiel *Model Context Protocol Authorization*, avec découverte automatique, enregistrement dynamique de client (RFC 7591), écran de consentement utilisateur et renouvellement par jeton de rafraîchissement.

---

## Sommaire

1. [Prérequis & Notions clés](#1-prérequis--notions-clés)
2. [Méthode 1 — Connexion via Bearer Token (PAT)](#2-méthode-1--connexion-via-bearer-token-pat)
3. [Méthode 2 — Connexion via OAuth 2.1 (MCP Authorization)](#3-méthode-2--connexion-via-oauth-21-mcp-authorization)
4. [Guides de configuration par client chat](#4-guides-de-configuration-par-client-chat)
   - [A. ChatGPT (OpenAI)](#a-chatgpt-openai)
   - [B. Mistral AI (Le Chat & Agents)](#b-mistral-ai-le-chat--agents)
   - [C. Claude Desktop (Anthropic)](#c-claude-desktop-anthropic)
   - [D. Cursor & VS Code](#d-cursor--vs-code)
   - [E. Clients Web open-source (LibreChat, Open WebUI)](#e-clients-web-open-source-librechat-open-webui)
5. [Exemples d'utilisation dans la conversation](#5-exemples-dutilisation-dans-la-conversation)
6. [Exposer une instance locale sur Internet (Tunnel HTTPS)](#6-exposer-une-instance-locale-sur-internet-tunnel-https)
7. [Dépannage & Erreurs fréquentes](#7-dépannage--erreurs-fréquentes)

---

## 1. Prérequis & Notions clés

### Endpoint MCP
- **URL standard de l'endpoint** : `https://<votre-domaine-disciplan>/mcp`
- **Protocole** : Streamable HTTP (spécification MCP 2024-11-05+)
- **Activation** : Le connecteur doit être activé sur le serveur (dans `appsettings.json` : `"Mcp": { "Enabled": true }`, valeur par défaut).

### Exigence HTTPS pour les clients Cloud
Les assistants SaaS hébergés dans le cloud (ChatGPT, Mistral Le Chat) exigent une **URL publiquement accessible en HTTPS** avec un certificat SSL valide. Si votre instance Disciplaner tourne sur votre machine locale (`http://localhost:5027`), consultez la section [Exposer une instance locale sur Internet](#6-exposer-une-instance-locale-sur-internet-tunnel-https).

### Portées d'accès (Scopes)
Que ce soit via PAT ou OAuth, deux portées sont disponibles :
- **`read` (Lecture seule)** : L'assistant ne peut que consulter vos projets, tickets, sprints, étiquettes et commentaires (11 outils exposés, outils d'écriture masqués).
- **`read+write` (Lecture + Écriture)** : L'assistant peut en plus créer et modifier des tickets, ajouter des commentaires, créer et démarrer des sprints (22 outils exposés).

> [!NOTE]
> Le connecteur respecte strictement vos droits applicatifs : un utilisateur avec le rôle *Guest* dans un projet ne pourra jamais écrire dans ce projet, même avec un jeton `read+write`. Aucune opération de suppression (ticket, projet, sprint) n'est jamais exposée au MCP.

---

## 2. Méthode 1 — Connexion via Bearer Token (PAT)

Le jeton d'accès personnel (**Personal Access Token**) est la méthode la plus rapide et la plus universelle.

### Étape 1 : Créer le jeton dans Disciplaner
1. Connectez-vous à votre interface Disciplaner.
2. Cliquez sur votre avatar ou rendez-vous dans les **Paramètres** (`/settings`).
3. Accédez à la section **Jetons MCP**.
4. Cliquez sur **Créer un jeton**.
5. Renseignez :
   - **Nom / Libellé** : le nom du client (ex. `Mistral Le Chat`, `ChatGPT`, `Cursor`).
   - **Portée** : `read` (lecture seule) ou `read+write` (lecture et écriture).
6. Cliquez sur **Générer**.
7. **Copiez immédiatement le jeton** affiché (commençant par `dcp_...`).

> [!WARNING]
> Pour des raisons de sécurité, le jeton brut n'est affiché qu'une seule fois. Si vous le perdez, vous devrez le révoquer et en générer un nouveau.

### Étape 2 : Format de transmission
Le jeton est transmis dans l'en-tête HTTP standard :
```http
Authorization: Bearer dcp_abcdef1234567890...
```

### Étape 3 : Révocation
À tout moment, vous pouvez consulter la liste de vos jetons dans **Paramètres > Jetons MCP** et cliquer sur **Révoquer**. La révocation prend effet immédiatement.

---

## 3. Méthode 2 — Connexion via OAuth 2.1 (MCP Authorization)

Disciplaner implémente la spécification standard **Model Context Protocol Authorization** basée sur OAuth 2.1. Ce flux permet aux clients compatibles d'authentifier l'utilisateur de manière interactive et sécurisée, sans saisie manuelle de clé API.

### Endpoints OAuth mis à disposition par Disciplaner

| Rôle | URL | Norme |
|---|---|---|
| Métadonnées de ressource protégée | `GET /.well-known/oauth-protected-resource` | RFC 9728 |
| Métadonnées du serveur d'autorisation | `GET /.well-known/oauth-authorization-server` | RFC 8414 |
| Configuration OpenID (alias de compatibilité) | `GET /.well-known/openid-configuration` | OpenID Connect |
| Enregistrement dynamique de client | `POST /oauth/register` | RFC 7591 |
| Endpoint d'autorisation (consentement) | `GET` & `POST /oauth/authorize` | RFC 6749 / 7636 |
| Endpoint d'échange de jetons | `POST /oauth/token` | RFC 6749 / 7636 |
| Endpoint de révocation | `POST /oauth/revoke` | RFC 7009 |
| Gestion des autorisations utilisateur | `GET` & `DELETE /api/me/oauth-authorizations` | API REST Disciplaner |

### Déroulement automatique du flux OAuth 2.1

```mermaid
sequenceDiagram
    autonumber
    actor User as Utilisateur
    participant Client as Client Chat (ex. ChatGPT, Claude)
    participant Server as Disciplaner (/mcp & /oauth)

    Client->>Server: POST /mcp (sans token)
    Server-->>Client: 401 Unauthorized + Header WWW-Authenticate (RFC 9728)
    Client->>Server: GET /.well-known/oauth-protected-resource
    Server-->>Client: Métadonnées (URL serveur auth, scopes disponibles)
    Client->>Server: POST /oauth/register (Enregistrement dynamique)
    Server-->>Client: client_id généré (ex. dcp_client_...)
    Client->>User: Ouvre le navigateur vers /oauth/authorize (avec PKCE S256)
    User->>Server: Saisie des identifiants & Choix de la portée (read / read+write)
    Server-->>Client: Redirection vers redirect_uri?code=dcp_ac_...
    Client->>Server: POST /oauth/token (code + code_verifier PKCE)
    Server-->>Client: access_token (dcp_at_...) + refresh_token (dcp_rt_...)
    Client->>Server: POST /mcp (Authorization: Bearer dcp_at_...)
    Server-->>Client: 200 OK (Exécution des outils MCP)
```

1. **Découverte (RFC 9728)** : Lorsque le client appelle `https://<serveur>/mcp` sans jeton, le serveur renvoie HTTP `401 Unauthorized` avec l'en-tête :
   ```http
   WWW-Authenticate: Bearer resource_metadata="https://<serveur>/.well-known/oauth-protected-resource"
   ```
2. **Enregistrement dynamique (RFC 7591)** : Le client s'enregistre automatiquement auprès de `POST /oauth/register` avec son nom et ses URLs de redirection.
3. **Consentement (RFC 6749 & RFC 7636)** : L'utilisateur est dirigé vers la page d'autorisation `/oauth/authorize`. Il se connecte avec son compte Disciplaner et approuve l'accès de l'assistant en confirmant la portée souhaitée.
4. **Émission des jetons** : Le client échange le code d'autorisation contre :
   - Un `access_token` commençant par `dcp_at_...` (durée de validité : 1 heure).
   - Un `refresh_token` commençant par `dcp_rt_...` (durée de validité : 30 jours, renouvelable).
5. **Appel des outils** : Le client envoie l'en-tête `Authorization: Bearer dcp_at_...` à chaque requête MCP.

---

## 4. Guides de configuration par client chat

### A. ChatGPT (OpenAI)

ChatGPT permet de connecter des outils MCP soit via les **Connecteurs / Developer Apps**, soit via une **Action Custom GPT**.

#### Option 1 : Connecteur MCP / Outil développeur ChatGPT
1. Dans ChatGPT, ouvrez vos **Paramètres** → **Connecteurs** ou **Fonctionnalités Développeur**.
2. Cliquez sur **Ajouter un nouveau serveur MCP**.
3. Remplissez les informations :
   - **Nom du serveur** : `Disciplaner`
   - **URL du serveur** : `https://<votre-domaine-disciplan>/mcp`
   - **Type d'authentification** : Choisissez **Bearer Token** ou **API Key**.
   - **Jeton / Clé** : Collez votre jeton personnel `dcp_...` (généré avec la portée `read+write`).
4. Enregistrez. ChatGPT interrogera automatiquement `tools/list` pour découvrir les outils Disciplaner.

#### Option 2 : Connexion OAuth 2.0 dans Custom GPT
Si vous créez un GPT dédié dans **GPT Builder** :
1. Créez votre Custom GPT, puis allez dans **Configure > Actions > Create new action**.
2. Dans **Authentication** :
   - **Type** : `OAuth`
   - **Client ID** : Créé via `/oauth/register` ou fourni par l'administrateur
   - **Authorization URL** : `https://<votre-domaine-disciplan>/oauth/authorize`
   - **Token URL** : `https://<votre-domaine-disciplan>/oauth/token`
   - **Scope** : `read+write` (ou `read`)
   - **Token Exchange Method** : `Basic authorization header` ou `POST request body`
3. Lorsque vous ouvrez le chat, ChatGPT vous invitera à cliquer sur **Se connecter à Disciplaner** pour approuver l'accès.

---

### B. Mistral AI (Le Chat & Agents)

Mistral AI permet d'équiper ses agents et conversations avec des connecteurs MCP distants Streamable HTTP.

#### Configuration dans Le Chat / Agents Mistral
1. Rendez-vous sur [console.mistral.ai](https://console.mistral.ai/) ou dans l'interface **Le Chat**.
2. Créez ou modifiez un **Agent**.
3. Dans la section **Outils / Tools**, sélectionnez **Ajouter un outil MCP** (ou *Model Context Protocol*).
4. Configurez l'outil :
   - **Type de transport** : `HTTP` / `Streamable HTTP`
   - **URL de l'endpoint** : `https://<votre-domaine-disciplan>/mcp`
   - **En-têtes personnalisés (Custom Headers)** :
     - Nom de l'en-tête : `Authorization`
     - Valeur : `Bearer dcp_votre_jeton_ici`
5. Enregistrez l'agent.
6. Testez immédiatement dans la fenêtre de chat en demandant :
   > « *Quels sont les projets configurés sur mon instance Disciplaner ?* »

---

### C. Claude Desktop (Anthropic)

Claude Desktop supporte les serveurs MCP soit en mode local via proxy `stdio`, soit en mode distant Streamable HTTP / SSE.

#### Configuration via proxy stdio local (Recommandé pour serveur local ou intranet)
Lorsque votre serveur Disciplaner tourne en local (`http://localhost:5027`) ou derrière un VPN non exposé à Internet, compilez le proxy léger `disciplaner-mcp` :

```bash
# Compilation du proxy (à exécuter à la racine du dépôt)
dotnet publish src/Disciplaner.Mcp -c Release -o ./dist-mcp
```

Éditez le fichier de configuration de Claude Desktop :
- **Windows** : `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS** : `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux** : `~/.config/Claude/claude_desktop_config.json`

Ajoutez le bloc suivant :

```json
{
  "mcpServers": {
    "disciplaner": {
      "command": "C:\\chemin\\vers\\dist-mcp\\disciplaner-mcp.exe",
      "args": ["--stdio"],
      "env": {
        "DISCIPLAN_URL": "http://localhost:5027",
        "DISCIPLAN_PAT": "dcp_votre_jeton_ici"
      }
    }
  }
}
```

#### Configuration avec mcp-remote / HTTP direct
Si vous disposez de la version de Claude Desktop supportant les connecteurs HTTP distants :

```json
{
  "mcpServers": {
    "disciplaner": {
      "url": "https://<votre-domaine-disciplan>/mcp",
      "headers": {
        "Authorization": "Bearer dcp_votre_jeton_ici"
      }
    }
  }
}
```

Redémarrez Claude Desktop : l'icône marteau 🔨 apparaît avec les outils Disciplaner.

---

### D. Cursor & VS Code

Cursor intègre nativement le protocole MCP pour assister vos développements dans le chat et le compositeur.

1. Ouvrez **Cursor Settings** (`Ctrl+,` ou `Cmd+,`) → **Features** → **MCP**.
2. Cliquez sur **Add New MCP Server**.
3. Renseignez :
   - **Name** : `disciplaner`
   - **Type** : `command` (stdio proxy) ou `http` (si disponible dans votre version)
   - Si `command` :
     - **Command** : `C:\chemin\disciplaner-mcp.exe --stdio`
     - **Environment Variables** :
       - `DISCIPLAN_URL` = `https://<votre-domaine-disciplan>`
       - `DISCIPLAN_PAT` = `dcp_votre_jeton_ici`
4. Vérifiez que le statut passe au vert (outils détectés : 11 ou 22 selon la portée).
5. Dans le chat Cursor (`Ctrl+L`), tapez `@disciplaner` pour solliciter vos tickets et sprints pendant que vous codez.

---

### E. Clients Web open-source (LibreChat, Open WebUI)

#### LibreChat
Dans votre fichier `librechat.yaml` :

```yaml
mcpServers:
  disciplaner:
    type: streamable-http
    url: https://<votre-domaine-disciplan>/mcp
    headers:
      Authorization: "Bearer dcp_votre_jeton_ici"
```

#### Open WebUI / AnythingLLM
Dans l'interface d'administration :
1. Allez dans **Settings > External Tools / MCP**.
2. Ajoutez un serveur Streamable HTTP :
   - **URL** : `https://<votre-domaine-disciplan>/mcp`
   - **Authorization Header** : `Bearer dcp_...`

---

## 5. Exemples d'utilisation dans la conversation

Une fois le serveur connecté à votre client chat, vous pouvez interagir en langage naturel. L'assistant convertit vos instructions en appels d'outils Disciplaner :

### Exemples d'invites (Prompts)

| Action souhaitée | Ce que vous pouvez demander au chat | Outil MCP appelé en sous-main |
|---|---|---|
| **Consulter les projets** | *« Donne-moi la liste de tous mes projets Disciplaner et leurs clés. »* | `list_projects` |
| **Inspecter un sprint** | *« Quel est l'état du sprint actif dans le projet DISC ? Quels tickets restent à faire ? »* | `list_sprints`, `get_sprint`, `list_tickets` |
| **Consulter un ticket** | *« Affiche-moi les détails et les derniers commentaires du ticket DISC-42. »* | `get_ticket`, `list_comments` |
| **Créer un ticket** | *« Crée un ticket dans DISC intitulé 'Corriger le bouton de déconnexion' avec priorité Haute et description 'Le clic ne déclenche pas la déconnexion'. »* | `create_ticket` |
| **Assigner un ticket** | *« Assigne le ticket DISC-42 à Axel et déplace-le dans le sprint actif. »* | `assign_ticket`, `move_ticket_to_sprint` |
| **Ajouter un commentaire** | *« Ajoute un commentaire sur DISC-42 indiquant que le correctif est en cours de test en staging. »* | `add_comment` |
| **Clôturer un ticket** | *« Clôture le ticket DISC-42 avec la raison Done. »* | `close_ticket` |
| **Création par lot** | *« Voici les spécifications du module d'export. Découpe-les et crée les 4 tickets correspondants dans le projet DISC. »* | `create_tickets` (jusqu'à 50 tickets en un seul appel) |

### Prompts MCP prédéfinis

Le connecteur MCP expose également deux modèles de prompts guidés :
- `enrich-backlog` : demande à l'assistant d'analyser un objectif produit ou une fonctionnalité et de proposer un ensemble de tickets structurés avant validation.
- `sprint-review` : génère un compte-rendu exécutif du sprint actif (tickets terminés, tickets bloqués, vélocité).

---

## 6. Exposer une instance locale sur Internet (Tunnel HTTPS)

Si votre serveur Disciplaner est hébergé localement (`http://localhost:5027`) et que vous souhaitez le connecter à un client cloud (ChatGPT ou Mistral), vous devez créer un tunnel HTTPS public.

### Option A — Cloudflare Tunnel (Gratuit, sans compte obligatoire)
```bash
cloudflared tunnel --url http://localhost:5027
```
Cloudflare vous donne une URL temporaire du type :
```text
https://random-subdomain.trycloudflare.com
```
L'URL de votre connecteur MCP devient alors :
```text
https://random-subdomain.trycloudflare.com/mcp
```

### Option B — Ngrok
```bash
ngrok http 5027
```
Copiez l'URL HTTPS fournie par ngrok (`https://xxxx.ngrok-free.app/mcp`).

> [!IMPORTANT]
> Si vous utilisez OAuth 2.1 avec un tunnel, assurez-vous que votre reverse-proxy ou tunnel transmet fidèlement les en-têtes `X-Forwarded-Proto: https` et `X-Forwarded-Host`, pour que les URLs de redirection et métadonnées RFC 9728 soient générées en HTTPS.

---

## 7. Dépannage & Erreurs fréquentes

| Erreur / Symptôme | Cause probable | Solution |
|---|---|---|
| **HTTP 401 Unauthorized** | Jeton manquant, mal orthographié ou révoqué. | Vérifiez le préfixe de l'en-tête `Authorization: Bearer dcp_...`. Ne confondez pas le token JWT applicatif avec un token MCP (`dcp_...` ou `dcp_at_...`). |
| **HTTP 404 Not Found sur `/mcp`** | Le connecteur est désactivé côté serveur. | Vérifiez que `"Mcp": { "Enabled": true }` est présent dans `appsettings.json` et que l'URL est bien terminée par `/mcp`. |
| **HTTP 429 Too Many Requests** | La limite de requêtes par minute est atteinte (par défaut : 60 req/min). | Ralentissez les requêtes de l'assistant ou augmentez `"RateLimitPerMinute"` dans la configuration serveur. |
| **« This token is read-only »** | Tentative d'écriture (création/modification) avec un jeton configuré en portée `read`. | Créez un nouveau jeton dans Disciplaner avec la portée `read+write`. Notez qu'avec un jeton `read`, les outils d'écriture ne sont même pas listés. |
| **Erreur SSL / HTTPS dans ChatGPT ou Mistral** | Le certificat SSL est invalide ou auto-signé, ou vous utilisez une URL `http://`. | Les services cloud exigent un certificat TLS public valide (Let's Encrypt, Cloudflare, etc.). Utilisez un tunnel HTTPS en développement. |
| **Erreur de redirection OAuth (`redirect_uri_mismatch`)** | L'URL de redirection demandée par le client ne correspond pas à celle déclarée lors de l'enregistrement. | Vérifiez les paramètres de redirection de votre client chat. Disciplaner autorise les redirections déclarées lors du `POST /oauth/register`. |
| **Outils non visibles dans le chat** | Le client n'a pas rafraîchi la liste des outils (`tools/list`). | Déconnectez et reconnectez le serveur MCP dans les paramètres de votre client chat. |
| **Un projet n'apparaît pas** | L'utilisateur propriétaire du jeton n'est pas membre du projet concerné. | Le jeton hérite de vos permissions utilisateur : demandez à être invité dans le projet dans Disciplaner. |

---

## 8. Pour aller plus loin

- [Conception architecturale du connecteur MCP](01-conception-architecture.md) : Détail technique du protocole, des filtres de sécurité et de l'architecture logicielle.
- [Guide utilisateur général du connecteur](02-guide-utilisateur.md) : Présentation des outils et spécifications.
- [Spécification officielle Model Context Protocol](https://modelcontextprotocol.io) : Documentation de référence du protocole MCP.
