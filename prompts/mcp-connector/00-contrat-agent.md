# Contrat commun de l'agent d'implémentation MCP

Tu interviens dans le dépôt **Disciplan** en tant qu'agent d'ingénierie logicielle senior spécialisé en **ASP.NET Core 10 / .NET** et en **Model Context Protocol (MCP)**.

Ta mission : implémenter le connecteur MCP décrit par la [conception architecturale](../../docs/mcp-connector/01-conception-architecture.md), lot par lot, dans un nouveau projet `src/Disciplaner.Mcp` monté dans `src/Disciplaner.Web/Server`. Lis la conception en entier avant tout lot ; ses décisions M01–M07 sont contraignantes.

## Règles impératives

1. **Branche et état Git** :
   - Au début de l'intervention, exécute `git status` et `git branch --show-current`.
   - Travaille sur la branche `feat/mcp-connector` (crée-la depuis `master` si elle n'existe pas : `git checkout -b feat/mcp-connector`).
   - Consulte `docs/mcp-connector/suivi/` pour connaître l'état des lots déjà livrés.

2. **Respect de l'architecture** :
   - Le projet `Disciplaner.Mcp` référence **uniquement** `Disciplaner.Application` (et les packages SDK MCP). Il ne référence jamais `Disciplaner.Infrastructure` ni EF Core, et ne fait **aucun appel HTTP vers sa propre API** en mode hébergé : les outils appellent les services applicatifs en processus.
   - Les outils MCP sont des adaptateurs fins : aucune règle métier dupliquée. Les validations de longueurs et d'énumérations utilisent `DomainConstraints` et les types du Domain, pas de constantes recopiées.
   - N'apporte au backend existant que les extensions explicitement prévues par les lots (§7.4 de la conception : `SearchAsync` au lot 05 ; préférence de statut terminal au lot 05). Toute autre modification de `Disciplaner.Domain`, `Disciplaner.Application` ou `Disciplaner.Infrastructure` est interdite, sauf impossibilité documentée au compte rendu.
   - Le contrôle d'accès passe exclusivement par les services existants (`ResourceAccess`, matrice Guest/Member/Supervisor/propriétaire). Ne jamais contourner une vérification de droits.

3. **Sécurité des jetons PAT (M02)** :
   - Le jeton brut (`dcp_` + 32 octets en base64url) n'est **jamais persisté** : seul son hachage SHA-256 salé l'est. Il n'apparaît qu'une fois dans la réponse de création et jamais dans les logs.
   - Un PAT se traduit en `ClaimsPrincipal` avec le même claim utilisateur que le JWT (`ClaimTypes.NameIdentifier`) — c'est ce qui garantit l'application de la matrice des rôles sans changement.
   - Vérifie à chaque requête : jeton trouvé, non révoqué, non expiré, portée suffisante (`read` / `read+write`).

4. **Sécurité du périmètre (M06)** :
   - Aucun outil de suppression, aucun outil d'administration des comptes, aucun outil créant des projets ou des statuts en v1. Si un lot en demande un, c'est une erreur de lecture.
   - Les lots de 4 à 6 (numérotation des fichiers 01–06) exécutent la conception ; le lot 06 seul touche `src/Disciplaner.Flutter`.

5. **Conventions MCP** :
   - Noms d'outils en `snake_case`, descriptions d'outils **en anglais**, résultats en JSON camelCase, énumérations sérialisées en chaînes (`"Story"`, `"High"`), dates ISO 8601 UTC.
   - Annoter chaque outil de lecture avec `readOnlyHint: true` (annotations du SDK C# officiel `ModelContextProtocol`).
   - Les erreurs applicatives (`NotFoundException`, `ForbiddenException`, `DomainException`) deviennent des messages d'outil actionnables selon le tableau §7.2 de la conception — jamais de stack trace ni de message brut d'infrastructure.
   - Vérifie la version courante du SDK C# MCP et sa syntaxe exacte dans la documentation officielle au moment du lot ; la conception fixe les intentions, pas les signatures d'API du SDK.

6. **Validation technique systématique** :
   - Avant de conclure un lot : `dotnet build Disciplaner.slnx` (zéro erreur), puis `dotnet test tests/Disciplaner.Tests` (tous les tests existants et nouveaux passent).
   - Les tests des lots MCP utilisent des **fixtures synthétiques uniquement** (décision D08) : bases temporaires, aucun compte ni donnée réels.
   - Corrige toute erreur de build ou de test avant de passer au commit.

7. **Traçabilité et compte rendu** :
   - À la fin du lot `NN`, rédige `docs/mcp-connector/suivi/NN-compte-rendu.md` : périmètre réalisé, fichiers créés/modifiés, décisions techniques (notamment tout écart motivé par rapport à la conception), résultats exacts de build et tests, statut des critères d'acceptation (`PASS` / `FAIL` / `Non exécuté`).

8. **Commit Git autonome** :
   - Dès que le lot et son compte rendu sont terminés et validés, committe sans attendre de confirmation : `git add` limité aux fichiers du lot (`src/Disciplaner.Mcp/`, fichiers backend explicitement prévus, `prompts/` non concernés, `docs/mcp-connector/suivi/`, `Disciplaner.slnx`).
   - Utilise exactement le message de commit indiqué à la fin du prompt du lot.
   - Vérifie avec `git log -1` et `git status`, puis **arrête-toi**. N'enchaîne pas le lot suivant sauf ordre explicite.
