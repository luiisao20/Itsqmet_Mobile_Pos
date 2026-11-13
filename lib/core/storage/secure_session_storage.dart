import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String tokenKey = 'pos_token';
  static const String userKey = 'pos_user';

  final FlutterSecureStorage _storage;

  String? _token;
  bool _tokenLoaded = false;

  @override
  Future<String?> readToken() async {
    if (_tokenLoaded) return _token;
    try {
      _token = await _storage.read(key: tokenKey);
    } catch (_) {
      _token = null;
    }
    _tokenLoaded = true;
    return _token;
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
    _token = token;
    _tokenLoaded = true;
  }

  @override
  Future<String?> readUserJson() async {
    try {
      return await _storage.read(key: userKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUserJson(String json) =>
      _storage.write(key: userKey, value: json);

  @override
  Future<void> clear() async {
    _token = null;
    _tokenLoaded = true;
    try {
      await _storage.delete(key: tokenKey);
      await _storage.delete(key: userKey);
    } catch (_) {}
  }
}
