# Lot 02 — Couche Réseau, Modèles API, Configuration Homelab & Authentification

## Instruction

Lis et applique le [Prompt Maître](00-prompt-maitre.md) ainsi que l'[Architecture de référence](../../docs/flutter-migration/01-architecture-et-plan.md). Exécute intégralement ce lot et termine par un commit Git autonome.

## Prérequis

- Lot 01 terminé et commité (`docs/flutter-migration/suivi/01-compte-rendu.md` présent).

## Fichiers de référence à inspecter

- `src/Disciplaner.Web/Server/Controllers/AuthController.cs`
- `src/Disciplaner.Web/Server/Controllers/SetupController.cs`
- `src/Disciplaner.Application/DTOs/` (tous les sous-dossiers : `Auth`, `Project`, `Sprint`, `Ticket`, `TicketStatus`, `Comment`, `Attachment`, `Label`, `Member`, `SavedView`, `Activity`, `Calendar`, `User`)
- `src/Disciplaner.Domain/Enums/` (énumérations métier : `TicketType`, `TicketPriority`, `StatusCategory`, `SprintStatus`, `ProjectRole`, etc.)

## Travail à réaliser

1. **Modèles & DTOs Dart (`lib/core/models/` ou par feature)** :
   - Traduis fidèlement en Dart (avec `fromJson` / `toJson` et égalité par valeur) l'ensemble des énumérations et DTOs de `src/Disciplaner.Application/DTOs/` :
     - **Auth & Setup** : `AuthResponse`, `LoginRequest`, `RegisterRequest`, `SetupRequest`, `SetupStatusResponse`, `InvitationInfoResponse`, `InvitationRegisterRequest`.
     - **Projets & Membres** : `ProjectSummaryDto`, `ProjectDetailDto`, `CreateProjectRequest`, `UpdateProjectRequest`, `UpdateProjectDefaultsRequest`, `TicketStatusDto`, `MemberDto`.
     - **Sprints** : `SprintDto`, `SprintDetailDto`, `CreateSprintRequest`, `UpdateSprintRequest`, `CloseSprintRequest`.
     - **Tickets** : `TicketDto`, `CreateTicketRequest`, `UpdateTicketRequest`, `ChangeTicketStatusRequest`, `MoveTicketToSprintRequest`.
     - **Collaboration & Vues** : `CommentDto`, `AttachmentDto`, `LabelDto`, `SavedViewDto`, `TicketHistoryEntryDto`, `ActivityItemDto`, `CalendarTokenDto`, `UserSummaryDto`, `AdminUserDto`.

2. **Configuration Dynamique du Serveur Homelab (`lib/core/storage/` & `lib/core/network/`)** :
   - Crée `ServerConfigStorage` (basé sur `SharedPreferences`) stockant l'URL du backend Disciplan (par défaut `http://localhost:8080`, modifiable par l'utilisateur pour cibler son instance Homelab locale ou distante).
   - Crée `TokenStorage` (basé sur `FlutterSecureStorage` avec repli mémoire/préférences pour les tests et le Web) stockant le JWT Bearer, l'email, le `displayName`, les rôles et la date d'expiration.
   - Configure `DioClient` avec :
     - `BaseUrlInterceptor` résolvant dynamiquement l'URL configurée dans `ServerConfigStorage`.
     - `AuthInterceptor` injectant `Authorization: Bearer <token>` et déclenchant une déconnexion propre sur réception d'un `401 Unauthorized`.
     - Conversion propre des erreurs HTTP (`400`, `401`, `403`, `404`, `409`, erreurs réseau) en `AppFailure` lisible.

3. **Services & État d'Authentification (`lib/features/auth/`)** :
   - `AuthRepository` couvrant `/api/setup/status`, `/api/setup`, `/api/auth/login`, `/api/auth/register`, `/api/auth/invitation/{token}`, `/api/auth/register-invited`.
   - `AuthStateNotifier` (Riverpod) gérant les états : `unconfiguredServer`, `needsInitialSetup`, `unauthenticated`, `authenticated(AuthSession)`.

4. **Écrans de Connexion, Setup Initial & Configuration Homelab (`lib/features/auth/presentation/`)** :
   - Stylisés avec le Design System **Neo-Linear** (carte centrale blanche `#FFFFFF` sur fond lin `#FBF9F4`, bordure 1px `#E4E0D7`, logo `D` en `JetBrains Mono`) :
     - Sélecteur / Bandeau d'URL du serveur Homelab avec bouton "Tester la connexion" (`GET /api/setup/status`).
     - Écran de **Setup Initial** (affiché automatiquement si le serveur indique qu'aucun administrateur n'existe encore).
     - Écran de **Login** (email, mot de passe, gestion des erreurs d'identifiants) et prise en charge de l'inscription sur invitation.

5. **Tests unitaires et de widgets** :
   - Tests unitaires de sérialisation/désérialisation JSON des DTOs principaux (`TicketDto`, `ProjectDetailDto`, `SprintDto`, `AuthResponse`).
   - Tests du `AuthStateNotifier` et test de widget de l'écran de connexion/configuration serveur.

## Critères d'acceptation

- Tous les DTOs correspondent exactement aux propriétés JSON retournées par ASP.NET Core (camelCase).
- L'URL du serveur Homelab est configurable et persistée sans recompiler l'application.
- `flutter analyze` et `flutter test` passent sans erreur.

## Livrables & Commit Autonome

1. Rédige le compte rendu dans `docs/flutter-migration/suivi/02-compte-rendu.md`.
2. Exécute un commit Git en totale autonomie avec le message exact :
   `feat(flutter): implement network layer, API models, homelab config and authentication`
