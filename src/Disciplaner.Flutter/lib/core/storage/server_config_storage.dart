import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfigStorage {
  static const String keyBaseUrl = 'disciplan_server_base_url';
  static const String defaultBaseUrl = 'http://localhost:5000';

  /// URL injectée à la compilation (`--dart-define=DISCIPLAN_API_URL=…`).
  /// Utilisée par le script de dev pour pointer vers l'API locale.
  static const String _definedBaseUrl = String.fromEnvironment('DISCIPLAN_API_URL');

  final SharedPreferences? _prefs;
  String? _memoryBaseUrl;

  ServerConfigStorage([this._prefs]);

  static Future<ServerConfigStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ServerConfigStorage(prefs);
  }

  /// URL par défaut : valeur injectée à la compilation, sinon l'origine
  /// courante sur le web (build servi par le container API, même origine),
  /// sinon l'URL locale de développement.
  static String get _effectiveDefaultBaseUrl {
    final defined = _definedBaseUrl.trim();
    if (defined.isNotEmpty) return defined;
    if (kIsWeb) {
      final base = Uri.base;
      if (base.hasScheme && base.host.isNotEmpty) return base.origin;
    }
    return defaultBaseUrl;
  }

  String getBaseUrl() {
    if (_prefs != null) {
      final stored = _prefs.getString(keyBaseUrl)?.trim();
      if (stored != null && stored.isNotEmpty) {
        return _sanitize(stored);
      }
    }
    if (_memoryBaseUrl != null) {
      return _sanitize(_memoryBaseUrl!);
    }
    return _sanitize(_effectiveDefaultBaseUrl);
  }

  Future<void> setBaseUrl(String url) async {
    final sanitized = _sanitize(url.trim());
    _memoryBaseUrl = sanitized;
    if (_prefs != null) {
      await _prefs.setString(keyBaseUrl, sanitized);
    }
  }

  static String _sanitize(String url) {
    var clean = url;
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'http://$clean';
    }
    return clean;
  }
}
