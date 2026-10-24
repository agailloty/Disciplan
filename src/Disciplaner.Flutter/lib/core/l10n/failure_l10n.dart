import '../../../l10n/app_localizations.dart';
import '../errors/app_failure.dart';

/// Resolves the user-facing message for [failure] in the current locale.
///
/// A server-provided detail is preferred when the backend sent one; otherwise
/// the message is derived from the failure type.
String localizedFailureMessage(AppLocalizations l10n, AppFailure failure) {
  final detail = failure.message;
  final hasDetail = detail != null && detail.trim().isNotEmpty;
  if (hasDetail) return detail;
  return switch (failure.type) {
    AppFailureType.network => l10n.errorNetwork,
    AppFailureType.badRequest => l10n.errorBadRequest,
    AppFailureType.unauthorized => l10n.errorUnauthorized,
    AppFailureType.forbidden => l10n.errorForbidden,
    AppFailureType.notFound => l10n.errorNotFound,
    AppFailureType.conflict => l10n.errorConflict,
    AppFailureType.server => l10n.errorServer,
    AppFailureType.unknown => l10n.errorGenericNetwork,
  };
}
