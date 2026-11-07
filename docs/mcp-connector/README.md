# Connecteur MCP Disciplaner

Le connecteur **Model Context Protocol (MCP)** expose Disciplaner aux assistants IA et clients chat LLM (**Mistral Le Chat**, **ChatGPT**, **Claude Desktop**, **Cursor**, **VS Code**, **LibreChat**, **Open WebUI**...) afin de déléguer les opérations du produit en langage naturel : consultation et création de tickets, assignation, commentaires, clôture, gestion de sprints et enrichissement de backlog.

L'authentification supporte deux modes :
- **Bearer Token (PAT)** : génération rapide de jetons d'accès personnels depuis les paramètres Disciplaner (`dcp_...`).
- **OAuth 2.1 avec PKCE** : flux d'autorisation interactif standard MCP avec découverte automatique (`/.well-known/oauth-protected-resource`), enregistrement dynamique et consentement utilisateur.

## Documentation

1. [**Guide de connexion aux clients chat (ChatGPT, Mistral, Claude, Cursor...)**](03-connexion-clients-chat.md) — Guide pas à pas pour connecter le MCP via OAuth 2.1 ou Bearer Token dans vos assistants de chat favoris.
2. [**Guide utilisateur & catalogue d'outils**](02-guide-utilisateur.md) — Présentation des outils exposés, portées (`read` / `read+write`), prompts intégrés, garde-fous et dépannage.
3. [**Conception architecturale**](01-conception-architecture.md) — Spécifications techniques, modèle de sécurité, conformité Streamable HTTP et intégration ASP.NET Core.
4. [**Comptes-rendus d'implémentation & suivi**](suivi/) — Journal de livraison des lots et correctifs de revue.
5. [Prompts d'implémentation](../../prompts/mcp-connector/README.md) — Cahier des charges et consignes pour les agents de développement.
