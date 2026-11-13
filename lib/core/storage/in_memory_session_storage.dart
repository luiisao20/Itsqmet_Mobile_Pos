import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';

class InMemorySessionStorage implements SessionStorage {
  String? _token;
  String? _userJson;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> readUserJson() async => _userJson;

  @override
  Future<void> saveUserJson(String json) async => _userJson = json;

  @override
  Future<void> clear() async {
    _token = null;
    _userJson = null;
  }
}
