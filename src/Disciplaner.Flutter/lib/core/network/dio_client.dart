import 'package:dio/dio.dart';
import '../errors/app_failure.dart';
import '../storage/server_config_storage.dart';
import '../storage/token_storage.dart';
import 'interceptors.dart';

class DioClient {
  final Dio dio;
  final ServerConfigStorage serverConfigStorage;
  final TokenStorage tokenStorage;

  DioClient({
    required this.serverConfigStorage,
    required this.tokenStorage,
    void Function()? onUnauthorized,
    Dio? customDio,
  }) : dio = customDio ?? Dio() {
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.sendTimeout = const Duration(seconds: 10);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    dio.interceptors.addAll([
      BaseUrlInterceptor(serverConfigStorage),
      AuthInterceptor(tokenStorage, onUnauthorized: onUnauthorized),
    ]);
  }

  static AppFailure handleError(Object error) {
    if (error is AppFailure) {
      return error;
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      String? serverMessage;

      if (data is Map<String, dynamic>) {
        serverMessage = data['message']?.toString() ??
            data['title']?.toString() ??
            data['error']?.toString();
      } else if (data is String && data.isNotEmpty) {
        serverMessage = data;
      }

      switch (statusCode) {
        case 400:
          return AppFailure.badRequest(serverMessage ?? 'Requête invalide.');
        case 401:
          return AppFailure.unauthorized(serverMessage);
        case 403:
          return AppFailure.forbidden(serverMessage);
        case 404:
          return AppFailure.notFound(serverMessage);
        case 409:
          return AppFailure.conflict(serverMessage);
        case 500:
        case 502:
        case 503:
          return AppFailure.server(serverMessage);
        default:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            return AppFailure.network();
          }
          return AppFailure(
            message: serverMessage ?? error.message ?? 'Une erreur réseau est survenue.',
            statusCode: statusCode,
          );
      }
    }

    return AppFailure(message: error.toString());
  }
}
