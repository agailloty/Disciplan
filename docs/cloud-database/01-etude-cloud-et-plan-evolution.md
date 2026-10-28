# Étude Cloud Database & Plan d'Évolution Multi-Provider (PostgreSQL / SQLite)

## 1. Synthèse Exécutive

Actuellement, **Disciplan** repose exclusivement sur **SQLite** via Entity Framework Core 10 (`src/Disciplaner.Web/Server/Program.cs` et `src/Disciplaner.Infrastructure/Disciplaner.Infrastructure.csproj`). Si SQLite est idéal pour l'auto-hébergement léger (« single-container ») et les tests d'intégration rapides, il montre ses limites dès lors qu'on vise un déploiement Cloud moderne (conteneurs sans état *stateless*, réplication horizontale, haute disponibilité et écritures concurrentes soutenues).

Cette étude couvre deux volets majeurs :
1. **L'analyse approfondie de l'écosystème Cloud DB** (Relationnel vs NoSQL, comparatif des offres PostgreSQL managées et serverless, pièges techniques du Cloud comme le *connection pooling*, la latence réseau, la concurrence et le stockage des fichiers).
2. **L'audit technique du code actuel de Disciplan et le plan d'évolution** pour supporter **PostgreSQL en priorité** avec un **fallback transparent sur SQLite** lorsqu'aucun serveur PostgreSQL n'est configuré.

---

## 2. Étude Cloud : Bases de Données Managées (Relationnel vs NoSQL)

### 2.1. Relationnel (SQL) vs NoSQL pour le domaine de Disciplan

Dans le Cloud, deux grandes familles de services managés s'offrent à une API :
- **Bases Relationnelles (RDBMS)** : PostgreSQL (AWS RDS/Aurora, Neon, Supabase, Cloud SQL, Azure Flexible Server), MySQL/MariaDB, SQL Server.
- **Bases NoSQL** :
  - *Documentaires* : MongoDB Atlas, AWS DocumentDB, Azure Cosmos DB, Google Firestore.
  - *Clé-Valeur / Wide-Column* : AWS DynamoDB, Redis Cloud, Cassandra.

#### Analyse d'adéquation avec le modèle de données de Disciplan

Le domaine métier de Disciplan (`src/Disciplaner.Infrastructure/Data/ApplicationDbContext.cs`) est **intrinsèquement relationnel et fortement normalisé** :
1. **Intégrité référentielle et suppressions en cascade** : Projets $\rightarrow$ Sprints / Statuts / Tickets $\rightarrow$ Commentaires / Pièces jointes / Historique. Tableaux $\rightarrow$ Colonnes $\rightarrow$ Cartes.
2. **Relations Many-to-Many ($N$-$N$)** : `LabelConfiguration.cs` utilise des tables de jointure (`LabelTickets`, `LabelBoards`) interrogées transversalement avec filtrage de droits (`LabelRepository.cs`).
3. **Contrôle d'accès dynamique par jointures (ACL)** : Presque toutes les requêtes dans `TicketRepository.cs`, `SprintRepository.cs` ou `CommentRepository.cs` filtrent les entités selon l'appartenance de l'utilisateur à `Project.Members` ou `Board.Members`. En NoSQL (ex. DynamoDB ou Firestore), les jointures n'existent pas : il faudrait dénormaliser les listes de membres sur chaque ticket et commentaire, rendant la révocation d'un membre (`IntegrityTests.cs`) complexe et coûteuse.
4. **Séquencement atomique et transactions ACID** : La numérotation séquentielle sans trou par projet (`DISC-1`, `DISC-2` via `_nextTicketNumber` dans `ProjectConfiguration.cs`) et la règle d'unicité d'un seul sprint actif à la fois (`SprintService.cs`) exigent des transactions ACID strictes et des contraintes d'index uniques composites `(ProjectId, TicketNumber)`.
5. **ASP.NET Core Identity** : L'authentification (`ApplicationDbContext`) s'appuie sur `IdentityDbContext<ApplicationUser>`, conçu nativement pour EF Core relationnel.

> **Verdict Architecture : PostgreSQL (Relationnel + JSONB) est le choix optimal.**
> Le NoSQL pur obligerait à réécrire toute la couche `Infrastructure`, abandonner `IdentityDbContext`, et gérer manuellement la cohérence transactionnelle. À l'inverse, **PostgreSQL est une base multi-modèle** : elle offre la rigueur relationnelle ACID tout en proposant le moteur **JSONB** (binaire indexable GIN), supérieur à bien des bases NoSQL pour stocker des structures flexibles comme `SavedView.StatusCategories` (`SavedViewConfiguration.cs`) ou de futurs champs personnalisés (*Custom Fields*) sur les tickets.

---

### 2.2. Panorama des Services PostgreSQL Managés dans le Cloud

On distingue aujourd'hui deux générations d'offres PostgreSQL dans le Cloud :

#### A. Les Cloud Providers Historiques (PaaS Classique : VM dédiée managée)
* **AWS RDS for PostgreSQL** / **Azure Database for PostgreSQL (Flexible Server)** / **Google Cloud SQL** :
  * **Fonctionnement** : Une instance virtuelle dédiée tourne 24h/24 avec stockage réseau attaché (EBS, Azure Managed Disk).
  * **Avantages** : Très prévisible, intégration native IAM/VPC, SLA élevé (Multi-AZ failover), backups continus (Point-In-Time Recovery - PITR).
  * **Inconvénients** : Pas de *scale-to-zero* sur les offres standard (coût minimum ~15 € à 50 €/mois même sans trafic), temps de provisionnement et de redimensionnement en minutes.

#### B. Les Architectures Cloud-Native & Serverless (Séparation Compute / Storage)
* **Neon (Serverless Postgres)** :
  * **Fonctionnement** : Sépare totalement le calcul (Compute PostgreSQL) du stockage distribué multi-couches.
  * **Avantages clés** : *Scale-to-zero* (0 € quand inutilisé, démarrage à froid en ~300 ms), **Database Branching** instantané par *Copy-on-Write* (permet de créer une branche de BDD isolée par Pull Request dans la CI GitHub Actions), pooler `PgBouncer` intégré.
* **Supabase (Managed Postgres)** :
  * **Fonctionnement** : PostgreSQL dédié entouré d'un écosystème open-source (Supavisor pour le pooling, S3 Storage intégré).
  * **Avantages clés** : Excellent rapport performance/prix, pooler transactionnel/session inclus, et surtout **Supabase Storage** (compatible S3) qui peut héberger les fichiers de Disciplan (`Attachments`).
* **AWS Aurora PostgreSQL (Serverless v2)** / **Google Cloud AlloyDB** :
  * **Fonctionnement** : Stockage distribué hautes performances pour charges critiques d'entreprise.
  * **Inconvénients** : Coût d'entrée élevé, surdimensionné pour Disciplan à court/moyen terme.
* **Offres Européennes (Souveraineté RGPD)** :
  * **Scaleway Managed PostgreSQL**, **OVHcloud Public Cloud Databases**, **Clever Cloud** : Excellentes alternatives hébergées en France/UE avec facturation simple et sauvegarde incluse.

| Critère | PaaS Classique (RDS / Azure / Cloud SQL) | Serverless Cloud-Native (Neon / Supabase) | Européen Managé (Scaleway / Clever Cloud) |
| :--- | :--- | :--- | :--- |
| **Modèle de coût** | Fixe à l'heure (instance active 24/7) | Usage réel / Scale-to-zero (Neon) ou Forfait (Supabase) | Fixe à l'heure ou au mois |
| **Connection Pooling** | En option payante (RDS Proxy) ou PgBouncer intégré (Azure) | **Inclus nativement** (PgBouncer / Supavisor) | Souvent inclus (PgBouncer) |
| **Idéal pour Disciplan** | Production Entreprise / Déploiement VPC | SaaS agile, Homelab Cloud, Environnements de Preview CI/CD | Hébergement souverain UE / RGPD |

---

### 2.3. Les 6 Points Critiques à Savoir pour l'Intégration Cloud

Passer d'un fichier SQLite local (`/data/disciplaner.db` dans le même conteneur que l'API) à une base PostgreSQL managée dans le Cloud change radicalement les contraintes d'exploitation :

#### 1. Concurrence et Verrouillage : le piège SQLite vs MVCC PostgreSQL
Dans le code actuel de Disciplan, un comportement subtil repose sur la façon dont SQLite verrouille son fichier :
* Dans `UnitOfWork.cs`, le commentaire indique explicitement :
  `// SQLite's immediate transaction serializes writers before the aggregate is read.`
* Avec SQLite, `BeginTransactionAsync()` pose un verrou d'écriture global (`RESERVED` / `IMMEDIATE`), ce qui met en file d'attente les requêtes concurrentes (testé dans `IntegrityTests.cs` : `Concurrent_creation_keeps_unique_numbers_and_complete_history` et `Sprint_dates_lifecycle_and_concurrent_start_are_enforced`).
* **Sous PostgreSQL**, le niveau d'isolation par défaut est `READ COMMITTED` avec **MVCC** (les lecteurs ne bloquent jamais les écrivains, et deux transactions peuvent lire la même ligne `Project` simultanément avant d'écrire).
* Conséquence sur PostgreSQL lors de 6 créations de tickets simultanées :
  1. Les 6 requêtes lisent `_nextTicketNumber = 3` en même temps.
  2. La première réussit son `UPDATE "Projects" SET "NextTicketNumber" = 4 WHERE "Id" = @p0 AND "NextTicketNumber" = 3`.
  3. Les 5 autres lèvent une `DbUpdateConcurrencyException` (grâce au `.IsConcurrencyToken()` dans `ProjectConfiguration.cs`), que `ApiExceptionFilter.cs` transforme en **HTTP 409 Conflict** au lieu de réussir en séquence.
  4. De même, pour le démarrage concurrent de deux sprints (`StartSprint`), `READ COMMITTED` permettrait aux deux transactions de lire qu'aucun sprint n'est actif et d'activer les deux sprints simultanément.
* **Solution technique à implémenter** :
  * Utiliser une transaction `IsolationLevel.Serializable` dans `UnitOfWork.InTransactionAsync` avec retry automatique sur erreur de sérialisation PostgreSQL (`40001`) / `DbUpdateConcurrencyException`, assortie d'un **index unique filtré** en base sur `Sprint` (`WHERE "Status" = 1`).

#### 2. Gestion des Connexions, Cold Starts et Resiliency (Retries)
* En SQLite, ouvrir une connexion est un simple appel système de fichier local ($< 0.1\text{ ms}$).
* En PostgreSQL Cloud, chaque connexion consomme de la RAM sur le serveur distant (~5 à 10 Mo par processus backend Postgres) et traverse le réseau avec TLS.
* Si vous utilisez une base Serverless (ex. Neon avec *scale-to-zero*) ou lors d'un basculement de haute disponibilité (failover RDS/Azure), la première connexion peut échouer transitoirement ou prendre 500 ms.
* **Action requise** : Activer `EnableRetryOnFailure()` dans Npgsql EF Core (`options.UseNpgsql(conn, npgsql => npgsql.EnableRetryOnFailure(maxRetryCount: 3))`) et envelopper toute transaction manuelle dans `UnitOfWork.InTransactionAsync` via `_context.Database.CreateExecutionStrategy().ExecuteAsync(...)`.
* **Attention aux Poolers Cloud (`PgBouncer` en mode Transaction)** : Si l'URL fournie pointe vers un pooler externe (ex. port `6543` sur Supabase ou host `-pooler` sur Neon), Npgsql 8/10 gère automatiquement les requêtes préparées, mais lors des **migrations au démarrage** (`db.Database.MigrateAsync()`), EF Core utilise un verrou consultatif de session (`pg_advisory_lock`). Il est recommandé d'avoir optionnellement une `DirectConnection` pour les migrations, ou de s'assurer que la configuration Npgsql reste compatible.

#### 3. Latence Réseau et Requêtes `N+1`
* Sur SQLite local, exécuter 20 petites requêtes SQL successives au sein d'un appel HTTP prend moins d'une milliseconde (latence disque mémoire nulle).
* Sur une base Cloud managée, chaque aller-retour réseau (RTT) coûte entre **1 ms et 15 ms**.
* Or, certains services de Disciplan font actuellement des boucles de requêtes séquentielles :
  * `TicketService.ToDtoListAsync` : `foreach (var id in userIds) { var u = await _uow.Users.GetByIdAsync(id, ct); }`
  * `SprintService.GetActiveForUserAsync` : boucle `foreach (var s in sprints)` qui appelle `GetByIdAsync` et `GetBySprintIdAsync` à chaque itération.
  * `AdminUsersController.GetUsers` : `_userManager.Users.ToList()` synchrone suivi d'un `await _userManager.GetRolesAsync(u)` par utilisateur.
* Dans le Cloud, ces boucles dégraderont le temps de réponse de l'API. Ajouter une méthode batch (`GetUsersByIdsAsync(IEnumerable<string> ids)`) réduira $N$ allers-retours à $1$ seul.

#### 4. Typage strict des `DateTime` (UTC) avec Npgsql (.NET 6+)
* SQLite stocke les dates sous forme de chaînes ISO-8601 sans vérifier `DateTime.Kind`.
* Depuis Npgsql 6.0+, PostgreSQL mappe par défaut le type C# `DateTime` vers `timestamp with time zone` (`timestamptz`) et **rejette avec une `InvalidCastException` tout `DateTime` dont le `Kind` est `Unspecified` ou `Local`**.
* Dans Disciplan :
  * Les dates de création utilisent `DateTime.UtcNow` (`Kind = Utc` $\rightarrow$ OK).
  * Mais lors de la désérialisation JSON de requêtes clientes (ex. `IntegrityTests.cs` ligne 200 : `new DateTime(2027, 1, 1)` ou `Sprint_dates_lifecycle` : `startDate = "2026-10-02"` sans `Z`), le `DateTime` reçu a `DateTimeKind.Unspecified`.
* **Action requise** : Ajouter un `ValueConverter` global dans `ApplicationDbContext.ConfigureConventions` qui normalise tous les `DateTime` et `DateTime?` en `DateTimeKind.Utc` avant persistance.

#### 5. Stratégie de Gestion des Migrations EF Core Multi-Provider
* Les fichiers de migrations actuels dans `src/Disciplaner.Infrastructure/Data/Migrations/` contiennent des annotations spécifiques à SQLite (`Sqlite:Autoincrement`, types de colonnes `TEXT`, `INTEGER`).
* PostgreSQL ne peut pas exécuter des migrations générées pour SQLite (les types sont `uuid`, `character varying`, `timestamp with time zone`, `integer` avec `Npgsql:ValueGenerationStrategy.IdentityByDefaultColumn`).
* **La bonne pratique officielle EF Core (.NET 10)** consiste à séparer les ensembles de migrations par provider (soit dans deux assemblies satellites légers `Disciplaner.Migrations.Sqlite` et `Disciplaner.Migrations.Postgres`, soit par sous-dossiers avec `MigrationsAssembly`), tout en partageant exactement le même `ApplicationDbContext` et les mêmes `IEntityTypeConfiguration<T>`.

#### 6. Le corollaire Cloud : le Stockage des Fichiers (`Attachments` & `Profiles`)
* Dès lors qu'on externalise la base de données dans un service Cloud managé (PostgreSQL), le conteneur de l'API a vocation à devenir **stateless** (déployable sur AWS ECS/Fargate, Google Cloud Run, Azure Container Apps, Fly.io, Render, Kubernetes).
* Or, `LocalFileStorageService.cs` écrit les pièces jointes et avatars sur le système de fichiers local (`/data/uploads`).
* Si le conteneur Cloud redémarre ou scale à 2 instances sans volume réseau partagé, les fichiers uploadés disparaissent alors que leurs métadonnées restent dans PostgreSQL.
* **Évolution complémentaire recommandée** : Faire évoluer `IFileStorageService` pour supporter un provider **S3-compatible** (AWS S3, Cloudflare R2, Scaleway Object Storage, Supabase Storage, MinIO) avec fallback sur `LocalFileStorageService`.

---

## 3. Architecture Cible : Sélection Dynamique PostgreSQL & Fallback SQLite

### 3.1. Logique de Résolution et Ordre de Priorité

Conformément au besoin (**PostgreSQL prioritaire, fallback automatique à SQLite si rien n'est spécifié**), voici le diagramme de décision au démarrage de l'API :

```mermaid
flowchart TD
    A["Démarrage de l'API (Program.cs)"] --> B{"Database:Provider ou ConnectionString définis ?"}
    B -- "Provider = Postgres OU ConnectionString commence par Host= / postgres:// / postgresql://" --> C["Mode PostgreSQL (Npgsql)"]
    B -- "Provider = Sqlite OU ConnectionString commence par Data Source= / Filename=" --> D["Mode SQLite"]
    B -- "Aucune configuration fournie (vide ou absente)" --> E["Fallback automatique SQLite (Data Source=disciplaner.db)"]
    C --> F["Conversion automatique des URI Cloud (postgres://user:pass@host:port/db)"]
    F --> G["Application des Migrations PostgreSQL + Seeding Identity"]
    D --> H["Application des Migrations SQLite + Seeding Identity"]
    E --> H
```

#### Détection intelligente et flexibilité de configuration
Les plateformes Cloud (Render, Fly.io, Heroku, Neon, Supabase, Clever Cloud, Railway) injectent souvent une variable d'environnement sous forme d'URI standard (`DATABASE_URL=postgresql://user:pass@ep-xyz.eu-central-1.aws.neon.tech/disciplan?sslmode=require`) plutôt qu'au format ADO.NET (`Host=...;Database=...`).

Le résolveur de configuration supportera :
1. **Explicite via configuration ASP.NET Core** :
   - `Database__Provider=Postgres` (ou `Sqlite`)
   - `ConnectionStrings__Postgres` ou `ConnectionStrings__DefaultConnection`
2. **Explicite via variable standard Cloud** :
   - `DATABASE_URL` (avec parseur automatique `postgres://` ou `postgresql://` $\rightarrow$ `NpgsqlConnectionStringBuilder`).
3. **Auto-détection sur `ConnectionStrings:DefaultConnection`** :
   - Si la chaîne contient `Host=`, `Server=`, ou commence par `postgres://` / `postgresql://` $\rightarrow$ **PostgreSQL** est activé automatiquement.
   - Si la chaîne contient `Data Source=` ou `.db` $\rightarrow$ **SQLite** est activé.
   - Si aucune chaîne n'est spécifiée $\rightarrow$ **Fallback SQLite** (`Data Source=disciplaner.db` en local, ou `/data/disciplaner.db` en conteneur si configuré).

---

## 4. Plan d'Évolution Détaillé de la Solution

Voici le plan d'action structuré en **5 étapes progressives** pour faire évoluer Disciplan proprement, sans casser l'existant ni les tests :

### Étape 1 : Abstraction du Provider et Configuration (`Disciplaner.Infrastructure`)
1. **Ajout du package NuGet PostgreSQL** :
   - Ajouter `Npgsql.EntityFrameworkCore.PostgreSQL` (version `10.0.x` alignée sur EF Core `10.0.7`) dans `Disciplaner.Infrastructure.csproj`.
2. **Création de `DatabaseOptions` et `DatabaseProviderExtensions`** :
   - Créer un résolveur centralisé `AddDisciplanerDatabase(this IServiceCollection services, IConfiguration configuration)` qui :
     - Détermine le provider (`Postgres` prioritaire si configuré, sinon fallback `Sqlite`).
     - Convertit automatiquement les URLs `postgres://` / `postgresql://` (y compris `sslmode=require` pour le Cloud) en chaînes ADO.NET valides via `NpgsqlConnectionStringBuilder`.
     - Configure `UseNpgsql(...)` ou `UseSqlite(...)` avec l'assembly de migration correspondant.
3. **Mise à jour du `Dockerfile` et `appsettings.json`** :
   - Dans `appsettings.json`, ne pas forcer une valeur qui écraserait la logique de priorité si `DATABASE_URL` ou `ConnectionStrings:Postgres` est fourni, tout en conservant `Data Source=disciplaner.db` comme valeur de fallback par défaut.
   - Dans `Dockerfile`, définir `Database__SqliteFallbackPath="/data/disciplaner.db"` (ou laisser `ConnectionStrings__DefaultConnection` surchargeable) pour qu'un conteneur lancé avec `DATABASE_URL=postgres://...` bascule immédiatement sur PostgreSQL sans avoir besoin de vider une variable SQLite.

### Étape 2 : Harmonisation du Modèle EF Core et Concurrence Multi-SGBD
1. **Normalisation globale des `DateTime` en UTC** :
   - Surcharger `ConfigureConventions(ModelConfigurationBuilder configurationBuilder)` dans `ApplicationDbContext.cs` avec un `ValueConverter<DateTime, DateTime>` garantissant `DateTimeKind.Utc` en écriture comme en lecture (indispensable pour PostgreSQL `timestamptz` et cohérent sur SQLite).
2. **Gestion de la concurrence Transactionnelle (`UnitOfWork` & Index Uniques)** :
   - Ajouter dans la configuration de `Sprint` un index unique filtré : `.HasIndex(s => s.ProjectId).IsUnique().HasFilter("\"Status\" = 1")` (garantit au niveau base de données — SQLite ET PostgreSQL — qu'un seul sprint peut être actif par projet même sous forte concurrence MVCC).
   - Adapter `UnitOfWork.InTransactionAsync` pour gérer l'`ExecutionStrategy` EF Core et assurer la sérialisation ou le retry en cas de conflit concurrent sur PostgreSQL (`DbUpdateConcurrencyException` / `PostgresException 40001` / `23505` lors de l'incrémentation de `_nextTicketNumber` ou du démarrage de sprint).
3. **Correction des accès synchrones / `N+1` critiques** :
   - Remplacer `_userManager.Users.ToList()` par `await _userManager.Users.ToListAsync(cancellationToken)` dans `UserRepository.cs` et `AdminUsersController.cs`.
   - Ajouter une résolution groupée `GetByIdsAsync` dans `IUserRepository` pour éviter les requêtes `N+1` dans `TicketService.ToDtoListAsync`.

### Étape 3 : Migrations Multi-Provider (SQLite + PostgreSQL)
1. **Organisation des migrations** :
   - Conserver les migrations SQLite existantes pour ne casser aucune base SQLite déjà déployée.
   - Générer le jeu de migrations PostgreSQL initial (`Data/Migrations/Postgres` ou assembly dédié) via un argument `--provider Postgres` dans `DesignTimeContextFactory.cs`.
2. **Application automatique au démarrage** :
   - `await db.Database.MigrateAsync()` dans `Program.cs` appliquera automatiquement les migrations du provider actif (PostgreSQL ou SQLite).

### Étape 4 : Docker Compose, HealthChecks et Outillage Cloud
1. **Profil PostgreSQL dans `compose.yml`** :
   - Mettre à jour `compose.yml` et `.env.example` pour illustrer :
     - Le mode **Cloud / Externe** (en renseignant simplement `DATABASE_URL` ou `ConnectionStrings__DefaultConnection` vers Neon, Supabase, RDS, etc.).
     - Un service optionnel `postgres:17-alpine` local avec `healthcheck` pour ceux qui veulent auto-héberger avec PostgreSQL via Docker Compose.
     - Le fallback transparent sur SQLite si les variables PostgreSQL sont laissées vides.
2. **Endpoint de HealthCheck (`/health`)** :
   - Indispensable pour les orchestrateurs Cloud (AWS App Runner, Cloud Run, Fly.io, Kubernetes) afin de vérifier la connectivité à la base PostgreSQL ou SQLite.

### Étape 5 : Tests Automatisés Multi-Provider (`Disciplaner.Tests`)
1. **Tests de résolution de configuration** :
   - Tester unitairement la détection automatique du provider : priorité PostgreSQL (format ADO.NET et format URI `postgresql://`), choix explicite, et fallback SQLite quand rien n'est spécifié.
2. **Support PostgreSQL dans `ApiFactory.cs`** :
   - Permettre à la suite de tests d'intégration (`BaselineTests`, `IntegrityTests`, `Mcp*Tests`) de s'exécuter au choix sur SQLite (par défaut) ou sur une instance PostgreSQL de test (via variable d'environnement `TEST_POSTGRES_CONNECTION` ou service container GitHub Actions dans `ci.yml`).

