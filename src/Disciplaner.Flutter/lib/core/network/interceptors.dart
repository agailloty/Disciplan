import 'package:dio/dio.dart';
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

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._tokenStorage, {this.onUnauthorized});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ne pas injecter de token sur les routes publiques
    final isAuthRoute = options.path.contains('/api/auth/login') ||
        options.path.contains('/api/auth/register') ||
        options.path.contains('/api/setup');

    if (!isAuthRoute) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
