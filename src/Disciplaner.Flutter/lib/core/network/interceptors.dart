import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../storage/server_config_storage.dart';
import '../storage/token_storage.dart';

class BaseUrlInterceptor extends Interceptor {
  final ServerConfigStorage _storage;

  BaseUrlInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final currentBaseUrl = _storage.getBaseUrl();
    if (!options.path.startsWith('http://') && !options.path.startsWith('https://')) {
      final sanitizedPath = options.path.startsWith('/') ? options.path : '/${options.path}';
      options.baseUrl = currentBaseUrl;
      options.path = sanitizedPath;
    }
    handler.next(options);
  }
}

/// Échange un JWT valide ou récemment expiré contre un nouveau via
/// /api/auth/refresh. Les appels concurrents partagent une seule requête
/// (single-flight) : quand plusieurs écrans tombent sur un 401 en même
/// temps, un seul refresh est envoyé au serveur.
class TokenRefreshCoordinator {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<bool>? _inFlight;

  TokenRefreshCoordinator(this._dio, this._tokenStorage);

  Future<bool> refresh() {
    _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);
    return _inFlight!;
  }

  Future<bool> _doRefresh() async {
    try {
      final res = await _dio.post('/api/auth/refresh');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final session = AuthResponse.fromJson(data);
        if (session.token.isNotEmpty) {
          await _tokenStorage.saveSession(session);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class AuthInterceptor extends Interceptor {
  static const String _retriedAfterRefresh = 'retriedAfterRefresh';

  final TokenStorage _tokenStorage;
  final TokenRefreshCoordinator _refreshCoordinator;
  final Dio _dio;
  final void Function()? onUnauthorized;

  AuthInterceptor(
    this._dio,
    this._tokenStorage,
    this._refreshCoordinator, {
    this.onUnauthorized,
  });

  bool _isAuthRoute(String path) =>
      path.contains('/api/auth/login') ||
      path.contains('/api/auth/register') ||
      path.contains('/api/setup');

  bool _isRefreshRoute(String path) => path.contains('/api/auth/refresh');

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ne pas injecter de token sur les routes publiques.
    // Le refresh fait exception : il doit présenter le token (même expiré)
    // à échanger.
    if (!_isAuthRoute(options.path) || _isRefreshRoute(options.path)) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isRefreshRoute = _isRefreshRoute(path);
    final alreadyRetried = err.requestOptions.extra[_retriedAfterRefresh] == true;

    // Un 401 sur le refresh lui-même est géré par le coordinateur :
    // rien à faire ici, laisser remonter l'erreur à l'appelant.
    if (isUnauthorized && isRefreshRoute) {
      handler.next(err);
      return;
    }

    if (isUnauthorized && !alreadyRetried) {
      final refreshed = await _refreshCoordinator.refresh();
      if (refreshed) {
        try {
          // Rejoue la requête une seule fois avec le nouveau token.
          err.requestOptions.extra[_retriedAfterRefresh] = true;
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryErr) {
          err = retryErr;
        }
      }
    }

    // 401 définitif : refresh impossible ou retry toujours non autorisé.
    if (err.response?.statusCode == 401 && !alreadyRetried) {
      await _tokenStorage.clear();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
