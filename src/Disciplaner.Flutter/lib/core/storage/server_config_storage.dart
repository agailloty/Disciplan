import 'package:shared_preferences/shared_preferences.dart';

class ServerConfigStorage {
  static const String keyBaseUrl = 'disciplan_server_base_url';
  static const String defaultBaseUrl = 'http://localhost:8080';

  final SharedPreferences? _prefs;
  String _memoryBaseUrl = defaultBaseUrl;

  ServerConfigStorage([this._prefs]);

  static Future<ServerConfigStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ServerConfigStorage(prefs);
  }

  String getBaseUrl() {
    if (_prefs != null) {
      final stored = _prefs.getString(keyBaseUrl)?.trim();
      if (stored != null && stored.isNotEmpty) {
        return _sanitize(stored);
      }
    }
    return _sanitize(_memoryBaseUrl);
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
