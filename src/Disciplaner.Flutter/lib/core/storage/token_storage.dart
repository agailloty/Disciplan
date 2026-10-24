import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class TokenStorage {
  static const String _keyToken = 'disciplan_jwt_token';
  static const String _keySession = 'disciplan_auth_session';

  final SharedPreferences? _prefs;
  final Map<String, String> _memoryCache = {};

  TokenStorage({SharedPreferences? prefs, SharedPreferences? fallbackPrefs})
      : _prefs = prefs ?? fallbackPrefs;

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage(prefs: prefs);
  }

  Future<void> saveSession(AuthResponse auth) async {
    final sessionJson = jsonEncode(auth.toJson());
    _memoryCache[_keyToken] = auth.token;
    _memoryCache[_keySession] = sessionJson;

    if (_prefs != null) {
      await _prefs.setString(_keyToken, auth.token);
      await _prefs.setString(_keySession, sessionJson);
    }
  }

  Future<String?> getToken() async {
    if (_memoryCache.containsKey(_keyToken)) {
      return _memoryCache[_keyToken];
    }
    if (_prefs != null) {
      final token = _prefs.getString(_keyToken);
      if (token != null) {
        _memoryCache[_keyToken] = token;
        return token;
      }
    }
    return null;
  }

  Future<AuthResponse?> getSession() async {
    if (_memoryCache.containsKey(_keySession)) {
      try {
        final decoded = jsonDecode(_memoryCache[_keySession]!) as Map<String, dynamic>;
        return AuthResponse.fromJson(decoded);
      } catch (_) {}
    }
    if (_prefs != null) {
      final raw = _prefs.getString(_keySession);
      if (raw != null) {
        try {
          _memoryCache[_keySession] = raw;
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          return AuthResponse.fromJson(decoded);
        } catch (_) {}
      }
    }
    return null;
  }

  Future<void> clear() async {
    _memoryCache.remove(_keyToken);
    _memoryCache.remove(_keySession);
    if (_prefs != null) {
      await _prefs.remove(_keyToken);
      await _prefs.remove(_keySession);
    }
  }
}
