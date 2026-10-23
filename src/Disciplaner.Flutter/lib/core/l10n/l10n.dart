import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

export '../../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized messages for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
