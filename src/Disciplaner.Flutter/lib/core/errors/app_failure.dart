import 'package:equatable/equatable.dart';

enum AppFailureType {
  network,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
  unknown,
}

class AppFailure extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final AppFailureType type;

  const AppFailure({
    required this.message,
    this.statusCode,
    this.type = AppFailureType.unknown,
  });

  factory AppFailure.network([String? message]) => AppFailure(
        message: message ?? 'Impossible de joindre le serveur. Vérifiez votre connexion et l\'URL du serveur.',
        type: AppFailureType.network,
      );

  factory AppFailure.unauthorized([String? message]) => AppFailure(
        message: message ?? 'Identifiants invalides ou session expirée.',
        statusCode: 401,
        type: AppFailureType.unauthorized,
      );

  factory AppFailure.forbidden([String? message]) => AppFailure(
        message: message ?? 'Accès refusé pour cette opération.',
        statusCode: 403,
        type: AppFailureType.forbidden,
      );

  factory AppFailure.notFound([String? message]) => AppFailure(
        message: message ?? 'Ressource introuvable.',
        statusCode: 404,
        type: AppFailureType.notFound,
      );

  factory AppFailure.conflict([String? message]) => AppFailure(
        message: message ?? 'Un conflit est survenu (élément déjà existant ou modifié).',
        statusCode: 409,
        type: AppFailureType.conflict,
      );

  factory AppFailure.badRequest(String message) => AppFailure(
        message: message,
        statusCode: 400,
        type: AppFailureType.badRequest,
      );

  factory AppFailure.server([String? message]) => AppFailure(
        message: message ?? 'Une erreur interne est survenue sur le serveur.',
        statusCode: 500,
        type: AppFailureType.server,
      );

  @override
  String toString() => message;

  @override
  List<Object?> get props => [message, statusCode, type];
}
