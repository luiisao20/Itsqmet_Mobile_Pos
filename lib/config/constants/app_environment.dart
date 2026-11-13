import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnvironment {
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String wsUrlKey = 'WS_URL';

  static const String defaultApiBaseUrl = 'http://10.0.2.2:8080';
  static const String defaultWsUrl = 'ws://10.0.2.2:8080/ws-pos';

  static String get apiBaseUrl =>
      resolve(_currentEnv(), apiBaseUrlKey, defaultApiBaseUrl);

  static String get wsUrl => resolve(_currentEnv(), wsUrlKey, defaultWsUrl);

  static String resolve(
    Map<String, String>? source,
    String key,
    String fallback,
  ) {
    final value = source?[key]?.trim();
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  static Map<String, String>? _currentEnv() {
    try {
      return dotenv.isInitialized ? dotenv.env : null;
    } catch (_) {
      return null;
    }
  }
}
