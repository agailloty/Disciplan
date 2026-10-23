import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';

/// Persists and exposes the locale chosen by the user.
///
/// Falls back to the system locale when it is supported, otherwise French
/// (the default language of the application, as in the Blazor client).
class LocaleController extends Notifier<Locale> {
  static const _storageKey = 'app.locale';

  @override
  Locale build() {
    return const Locale('fr');
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) {
      final system = PlatformDispatcher.instance.locale;
      state = AppLocalizations.supportedLocales.any((l) =>
              l.languageCode == system.languageCode)
          ? Locale(system.languageCode)
          : const Locale('fr');
      return;
    }
    final parts = stored.split('_');
    final locale =
        parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
    state = AppLocalizations.supportedLocales
            .any((l) => l.languageCode == locale.languageCode)
        ? locale
        : const Locale('fr');
  }

  Future<void> set(Locale locale) async {
    if (!AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, locale.countryCode == null || locale.countryCode!.isEmpty
          ? locale.languageCode
          : locale.toString());
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
