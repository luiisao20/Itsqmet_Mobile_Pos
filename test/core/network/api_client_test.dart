import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';
import 'package:itsqmet_mobile_pos/core/network/api_client.dart';
import 'package:itsqmet_mobile_pos/core/network/auth_interceptor.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';

void main() {
  late SessionExpiredNotifier notifier;

  setUp(() => notifier = SessionExpiredNotifier());
  tearDown(() => notifier.dispose());

  test('builds a Dio with the environment base url by default', () {
    final client = ApiClient(
      storage: InMemorySessionStorage(),
      notifier: notifier,
    );

    expect(client.dio.options.baseUrl, AppEnvironment.apiBaseUrl);
  });

  test('allows overriding the base url', () {
    final client = ApiClient(
      storage: InMemorySessionStorage(),
      notifier: notifier,
      baseUrl: 'https://api.example.com',
    );

    expect(client.dio.options.baseUrl, 'https://api.example.com');
  });

  test('configures json content type and 15s timeouts', () {
    final options = ApiClient(
      storage: InMemorySessionStorage(),
      notifier: notifier,
    ).dio.options;

    expect(options.contentType, 'application/json');
    expect(options.connectTimeout, const Duration(seconds: 15));
    expect(options.receiveTimeout, const Duration(seconds: 15));
  });

  test('registers exactly one AuthInterceptor', () {
    final dio = ApiClient(
      storage: InMemorySessionStorage(),
      notifier: notifier,
    ).dio;

    expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
  });
}
