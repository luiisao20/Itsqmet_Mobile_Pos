abstract interface class SessionStorage {
  Future<String?> readToken();

  Future<void> saveToken(String token);

  Future<String?> readUserJson();

  Future<void> saveUserJson(String json);

  Future<void> clear();
}
