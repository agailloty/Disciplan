import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/core/errors/app_failure.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/network/dio_client.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/data/auth_repository.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';

final serverConfigStorageProvider = Provider<ServerConfigStorage>((ref) {
  return ServerConfigStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final homelabServerUrlProvider = Provider<String>((ref) {
  final storage = ref.watch(serverConfigStorageProvider);
  return storage.getBaseUrl();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final serverStorage = ref.watch(serverConfigStorageProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient(
    serverConfigStorage: serverStorage,
    tokenStorage: tokenStorage,
    onUnauthorized: () {
      tokenStorage.clear();
      // Basculer l'état d'authentification déclenche la redirection du
      // routeur vers l'écran de connexion : plus de pages figées en 401.
      ref.read(authNotifierProvider.notifier).sessionInvalidated();
    },
  );
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRepository(client);
});

class AuthNotifier extends Notifier<AuthState> {
  final IAuthRepository? _customAuthRepo;
  final TokenStorage? _customTokenStorage;
  final ServerConfigStorage? _customServerStorage;

  AuthNotifier({
    IAuthRepository? authRepo,
    TokenStorage? tokenStorage,
    ServerConfigStorage? serverStorage,
  })  : _customAuthRepo = authRepo,
        _customTokenStorage = tokenStorage,
        _customServerStorage = serverStorage;

  IAuthRepository get _authRepo => _customAuthRepo ?? ref.read(authRepositoryProvider);
  TokenStorage get _tokenStorage => _customTokenStorage ?? ref.read(tokenStorageProvider);
  ServerConfigStorage get _serverStorage => _customServerStorage ?? ref.read(serverConfigStorageProvider);

  @override
  AuthState build() {
    return const AuthInitial();
  }

  // Permet de mettre à jour le state dans les tests manuels si besoin
  void setManualState(AuthState newState) {
    state = newState;
  }

  /// Restaure la session persistée ; si elle est expirée, tente un refresh
  /// silencieux (fenêtre de grâce serveur) avant de déconnecter l'utilisateur.
  Future<AuthState> _resolveStoredSession() async {
    final session = await _tokenStorage.getSession();
    if (session == null) return const AuthUnauthenticated();
    if (session.expiresAt.isAfter(DateTime.now())) {
      return AuthAuthenticated(session);
    }
    try {
      final refreshed = await _authRepo.refresh();
      await _tokenStorage.saveSession(refreshed);
      return AuthAuthenticated(refreshed);
    } catch (_) {
      await _tokenStorage.clear();
      return const AuthUnauthenticated();
    }
  }

  /// Session invalidée côté réseau (401 définitif après échec de refresh) :
  /// le stockage a déjà été vidé par l'intercepteur, il ne reste qu'à faire
  /// basculer l'état pour que le routeur ramène l'écran de connexion.
  void sessionInvalidated() {
    if (state is! AuthUnauthenticated) {
      state = const AuthUnauthenticated();
    }
  }

  /// À la reprise de l'application, rafraîchit proactivement une session
  /// expirée ou proche de l'expiration pour éviter des 401 visibles sur les
  /// écrans encore ouverts. Une erreur réseau transitoire ne déconnecte pas.
  Future<void> ensureFreshSession() async {
    if (state is! AuthAuthenticated) return;
    final session = (state as AuthAuthenticated).session;
    if (session.expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) return;
    try {
      final refreshed = await _authRepo.refresh();
      await _tokenStorage.saveSession(refreshed);
      state = AuthAuthenticated(refreshed);
    } on AppFailure catch (e) {
      if (e.type == AppFailureType.unauthorized) {
        await _tokenStorage.clear();
        state = const AuthUnauthenticated();
      }
      // Erreur réseau/serveur transitoire : on garde la session courante.
    } catch (_) {
      // Idem : ne pas déconnecter sur un échec non lié à l'authentification.
    }
  }

  Future<void> checkStatusAndSession() async {
    state = const AuthLoading();
    try {
      final setupStatus = await _authRepo.getSetupStatus();
      if (setupStatus.setupRequired) {
        state = const AuthNeedsInitialSetup();
        return;
      }

      state = await _resolveStoredSession();
    } catch (e) {
      state = AuthUnconfiguredServer(error: e);
    }
  }

  Future<bool> updateServerUrl(String url) async {
    await _serverStorage.setBaseUrl(url);
    try {
      final status = await _authRepo.getSetupStatus();
      if (status.setupRequired) {
        state = const AuthNeedsInitialSetup();
      } else {
        state = await _resolveStoredSession();
      }
      return true;
    } catch (e) {
      state = AuthUnconfiguredServer(error: e);
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final res = await _authRepo.login(LoginRequest(email: email, password: password));
      await _tokenStorage.saveSession(res);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = AuthUnauthenticated(error: e);
    }
  }

  Future<void> setupInitialAdmin({
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final res = await _authRepo.executeSetup(
        SetupRequest(email: email, displayName: displayName, password: password),
      );
      await _tokenStorage.saveSession(res);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = const AuthNeedsInitialSetup();
      rethrow;
    }
  }

  Future<void> registerWithInvitation({
    required String token,
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final res = await _authRepo.registerInvited(
        InvitationRegisterRequest(
          token: token,
          email: email,
          displayName: displayName,
          password: password,
        ),
      );
      await _tokenStorage.saveSession(res);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = AuthUnauthenticated(error: e);
      rethrow;
    }
  }

  Future<void> updateDisplayNameLocal(String displayName) async {
    if (state is AuthAuthenticated) {
      final current = (state as AuthAuthenticated).session;
      final updated = AuthResponse(
        token: current.token,
        email: current.email,
        displayName: displayName,
        roles: current.roles,
        expiresAt: current.expiresAt,
      );
      await _tokenStorage.saveSession(updated);
      state = AuthAuthenticated(updated);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
