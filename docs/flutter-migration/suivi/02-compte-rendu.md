# Compte Rendu — Lot 02 : Couche Réseau, Modèles API, Configuration Homelab & Authentification

## 1. Périmètre Réalisé & Fichiers Créés

- **Modèles et DTOs Dart (`lib/core/models/`)** :
  - `enums.dart` : Correspondance exacte des enums C# (`CardPriority`, `StatusCategory`, `SprintStatus`, `TicketType`, `MemberRole`, `DefaultAssigneePolicy`) avec conversion résiliente int/string.
  - `auth_models.dart` : `AuthResponse`, `LoginRequest`, `RegisterRequest`, `SetupRequest`, `SetupStatusResponse`, `InvitationInfoResponse`, `InvitationRegisterRequest`.
  - `project_models.dart` : `ProjectSummaryDto`, `ProjectDetailDto`, `CreateProjectRequest`, `UpdateProjectRequest`, `UpdateProjectDefaultsRequest`, `TicketStatusDto`, `CreateTicketStatusRequest`, `UpdateTicketStatusRequest`, `MemberDto`, `AddMemberRequest`, `UpdateMemberRoleRequest`.
  - `sprint_models.dart` : `SprintDto`, `SprintDetailDto`, `CreateSprintRequest`, `UpdateSprintRequest`, `StartSprintRequest`.
  - `ticket_models.dart` : `TicketDto`, `LabelDto`, `CreateTicketRequest`, `UpdateTicketRequest`, `MoveTicketToSprintRequest`, `ChangeTicketStatusRequest`.
  - `collaboration_models.dart` : `CommentDto`, `CreateCommentRequest`, `AttachmentDto`, `SavedViewDto`, `CreateSavedViewRequest`, `TicketHistoryEntryDto`, `ActivityItemDto`, `CalendarTokenDto`, `UserSummaryDto`, `AdminUserDto`.

- **Gestion des erreurs & Stockage (`lib/core/errors/`, `lib/core/storage/`)** :
  - `app_failure.dart` : Classe d'exception typée (`network`, `unauthorized`, `forbidden`, `notFound`, `conflict`, `badRequest`, `server`) avec messages lisibles en français.
  - `server_config_storage.dart` : Stockage dynamique de l'URL Homelab (avec repli mémoire transparent et assainissement de l'URL).
  - `token_storage.dart` : Gestion du JWT et de la session (`FlutterSecureStorage` avec repli `SharedPreferences` et cache mémoire).

- **Couche Réseau Dio (`lib/core/network/`)** :
  - `interceptors.dart` : `BaseUrlInterceptor` (résolution dynamique de l'URL configurée) et `AuthInterceptor` (injection Bearer et détection 401).
  - `dio_client.dart` : Configuration globale de Dio, timeouts, headers et convertisseur d'erreurs HTTP vers `AppFailure`.

- **Authentification & Setup Initial (`lib/features/auth/`)** :
  - `auth_repository.dart` : Consommation de `/api/setup/status`, `/api/setup`, `/api/auth/login`, `/api/auth/register`, `/api/auth/invitation/{token}`, `/api/auth/register-invited`.
  - `auth_state.dart` & `auth_providers.dart` : `AuthNotifier` Riverpod 3 avec gestion des états `unconfiguredServer`, `needsInitialSetup`, `unauthenticated`, `authenticated`.
  - `homelab_server_card.dart` : Bandeau de configuration de l'instance locale avec indicateur de statut et bouton "Tester".
  - `setup_screen.dart` : Écran premier démarrage pour initialiser le compte administrateur racine.
  - `login_screen.dart` : Écran de connexion et formulaire d'inscription sur invitation.
  - `main.dart` : Routage réactif conditionné par l'état d'authentification.

- **Tests unitaires et de widgets (`test/models_and_auth_test.dart`)** :
  - 4 tests de sérialisation/désérialisation JSON (AuthResponse, TicketDto, SprintDto, ProjectDetailDto).
  - 3 tests de stockage et de machine à états `AuthNotifier`.
  - Test de rendu des widgets de connexion et du bandeau Homelab.

---

## 2. Décisions Techniques

1. **Tolérance aux formats JSON des Enums** : Implémentation d'une double stratégie dans chaque `fromJson` d'énumération acceptant à la fois les valeurs entières ASP.NET Core et les chaînes de caractères littérales pour prévenir toute désynchronisation.
2. **Architecture Riverpod 3 Notifier** : Utilisation du nouveau paradigme `Notifier<AuthState>` avec initialisation synchrone découplée et injection de dépendances modulaire, garantissant une testabilité immédiate sans dépendre de services natifs.

---

## 3. Résultats de Validation

- `flutter analyze` : **0 erreur, 0 warning**
- `flutter test` : **12 tests passés avec succès** (3 dans `theme_and_widgets_test.dart`, 9 dans `models_and_auth_test.dart`)

---

## 4. Statut des Critères d'Acceptation

| Critère | Statut |
|---|---|
| DTOs complets conformes aux contrats C# backend | **PASS** |
| URL du serveur Homelab configurable et persistée dynamiquement | **PASS** |
| Intercepteurs BaseUrl et JWT Auth avec déconnexion 401 | **PASS** |
| Écrans Setup Initial, Login et Configuration Homelab stylisés Neo-Linear | **PASS** |
| `flutter analyze` et `flutter test` sans erreur | **PASS** |
