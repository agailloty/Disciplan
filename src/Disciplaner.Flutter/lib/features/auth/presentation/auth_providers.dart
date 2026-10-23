import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> checkStatusAndSession() async {
    state = const AuthLoading();
    try {
      final setupStatus = await _authRepo.getSetupStatus();
      if (setupStatus.setupRequired) {
        state = const AuthNeedsInitialSetup();
        return;
      }

      final existingSession = await _tokenStorage.getSession();
      if (existingSession != null && existingSession.expiresAt.isAfter(DateTime.now())) {
        state = AuthAuthenticated(existingSession);
      } else {
        await _tokenStorage.clear();
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthUnconfiguredServer(errorMessage: e.toString());
    }
  }

  Future<bool> updateServerUrl(String url) async {
    await _serverStorage.setBaseUrl(url);
    try {
      final status = await _authRepo.getSetupStatus();
      if (status.setupRequired) {
        state = const AuthNeedsInitialSetup();
      } else {
        final session = await _tokenStorage.getSession();
        if (session != null && session.expiresAt.isAfter(DateTime.now())) {
          state = AuthAuthenticated(session);
        } else {
          state = const AuthUnauthenticated();
        }
      }
      return true;
    } catch (e) {
      state = AuthUnconfiguredServer(errorMessage: e.toString());
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
      state = AuthUnauthenticated(errorMessage: e.toString());
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
      state = AuthUnauthenticated(errorMessage: e.toString());
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
