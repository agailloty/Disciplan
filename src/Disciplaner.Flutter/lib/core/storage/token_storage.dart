import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class TokenStorage {
  static const String _keyToken = 'disciplan_jwt_token';
  static const String _keySession = 'disciplan_auth_session';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences? _fallbackPrefs;
  final Map<String, String> _memoryCache = {};

  TokenStorage({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? fallbackPrefs,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _fallbackPrefs = fallbackPrefs;

  Future<void> saveSession(AuthResponse auth) async {
    final sessionJson = jsonEncode(auth.toJson());
    _memoryCache[_keyToken] = auth.token;
    _memoryCache[_keySession] = sessionJson;

    try {
      await _secureStorage.write(key: _keyToken, value: auth.token);
      await _secureStorage.write(key: _keySession, value: sessionJson);
    } catch (_) {
      // Fallback
      if (_fallbackPrefs != null) {
        await _fallbackPrefs.setString(_keyToken, auth.token);
        await _fallbackPrefs.setString(_keySession, sessionJson);
      }
    }
  }

  Future<String?> getToken() async {
    if (_memoryCache.containsKey(_keyToken)) {
      return _memoryCache[_keyToken];
    }
    try {
      final token = await _secureStorage.read(key: _keyToken);
      if (token != null) {
        _memoryCache[_keyToken] = token;
        return token;
      }
    } catch (_) {}

    final fallback = _fallbackPrefs?.getString(_keyToken);
    if (fallback != null) {
      _memoryCache[_keyToken] = fallback;
    }
    return fallback;
  }

  Future<AuthResponse?> getSession() async {
    if (_memoryCache.containsKey(_keySession)) {
      try {
        final decoded = jsonDecode(_memoryCache[_keySession]!) as Map<String, dynamic>;
        return AuthResponse.fromJson(decoded);
      } catch (_) {}
    }

    String? raw;
    try {
      raw = await _secureStorage.read(key: _keySession);
    } catch (_) {}

    raw ??= _fallbackPrefs?.getString(_keySession);

    if (raw != null) {
      try {
        _memoryCache[_keySession] = raw;
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return AuthResponse.fromJson(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> clear() async {
    _memoryCache.clear();
    try {
      await _secureStorage.delete(key: _keyToken);
      await _secureStorage.delete(key: _keySession);
    } catch (_) {}
    if (_fallbackPrefs != null) {
      await _fallbackPrefs.remove(_keyToken);
      await _fallbackPrefs.remove(_keySession);
    }
  }
}
