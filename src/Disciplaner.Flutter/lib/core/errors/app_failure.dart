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

/// Describes a failed operation.
///
/// The failure never carries localized text: [message], when present, is a
/// server-provided detail. User-facing text is resolved from [type] at display
/// time via [localizedFailureMessage] (core/l10n/failure_l10n.dart).
class AppFailure extends Equatable implements Exception {
  final String? message;
  final int? statusCode;
  final AppFailureType type;

  const AppFailure({
    this.message,
    this.statusCode,
    this.type = AppFailureType.unknown,
  });

  factory AppFailure.network() => const AppFailure(
        type: AppFailureType.network,
      );

  factory AppFailure.unauthorized([String? message]) => AppFailure(
        message: message,
        statusCode: 401,
        type: AppFailureType.unauthorized,
      );

  factory AppFailure.forbidden([String? message]) => AppFailure(
        message: message,
        statusCode: 403,
        type: AppFailureType.forbidden,
      );

  factory AppFailure.notFound([String? message]) => AppFailure(
        message: message,
        statusCode: 404,
        type: AppFailureType.notFound,
      );

  factory AppFailure.conflict([String? message]) => AppFailure(
        message: message,
        statusCode: 409,
        type: AppFailureType.conflict,
      );

  factory AppFailure.badRequest([String? message]) => AppFailure(
        message: message,
        statusCode: 400,
        type: AppFailureType.badRequest,
      );

  factory AppFailure.server([String? message]) => AppFailure(
        message: message,
        statusCode: 500,
        type: AppFailureType.server,
      );

  @override
  String toString() => message ?? 'AppFailure(${type.name})';

  @override
  List<Object?> get props => [message, statusCode, type];
}
