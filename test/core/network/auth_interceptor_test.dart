import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/network/auth_interceptor.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';

class _StubAdapter implements HttpClientAdapter {
  int statusCode = 200;
  RequestOptions? lastRequest;

  Future<void> Function()? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    await onFetch?.call();
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late InMemorySessionStorage storage;
  late SessionExpiredNotifier notifier;
  late _StubAdapter adapter;
  late Dio dio;
  late int expiredCount;

  setUp(() {
    storage = InMemorySessionStorage();
    notifier = SessionExpiredNotifier();
    adapter = _StubAdapter();
    expiredCount = 0;
    notifier.onExpired.listen((_) => expiredCount++);
    dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(storage, notifier));
  });

  tearDown(() => notifier.dispose());

  group('onRequest', () {
    test('adds the Bearer token when a token exists', () async {
      await storage.saveToken('tok');

      await dio.get<dynamic>('/mesas');

      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer tok');
    });

    test('does not add Authorization when there is no token', () async {
      await dio.get<dynamic>('/platos');

      expect(
        adapter.lastRequest!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('reads the token on every request (no stale token)', () async {
      await storage.saveToken('first');
      await dio.get<dynamic>('/mesas');
      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer first');

      await storage.saveToken('second');
      await dio.get<dynamic>('/mesas');
      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer second');

      await storage.clear();
      await dio.get<dynamic>('/mesas');
      expect(
        adapter.lastRequest!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('adds the token to absolute URLs on the API origin', () async {
      await storage.saveToken('tok');

      await dio.get<dynamic>('http://localhost/mesas');

      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer tok');
    });

    test('never sends the token to another origin', () async {
      await storage.saveToken('tok');

      await dio.get<dynamic>('https://other-host.example/mesas');

      expect(
        adapter.lastRequest!.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  });

  group('onError', () {
    test('401 on a non-auth path clears the session and notifies', () async {
      await storage.saveToken('tok');
      await storage.saveUserJson('{"uuid":"1"}');
      adapter.statusCode = 401;

      await expectLater(
        dio.get<dynamic>('/pedidos'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
      expect(expiredCount, 1);
    });

    test('401 on /auth/ paths is left to the auth flow', () async {
      await storage.saveToken('tok');
      adapter.statusCode = 401;

      await expectLater(
        dio.get<dynamic>('/auth/me'),
        throwsA(isA<DioException>()),
      );
      await expectLater(
        dio.post<dynamic>('/auth/login'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await storage.readToken(), 'tok');
      expect(expiredCount, 0);
    });

    test('401 on an absolute /auth/ URL is also ignored', () async {
      await storage.saveToken('tok');
      adapter.statusCode = 401;

      await expectLater(
        dio.get<dynamic>('http://other-host/auth/me'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await storage.readToken(), 'tok');
      expect(expiredCount, 0);
    });

    test('a late 401 sent with an old token keeps the newer session', () async {
      await storage.saveToken('old');
      adapter
        ..statusCode = 401
        ..onFetch = () => storage.saveToken('new');

      await expectLater(
        dio.get<dynamic>('/pedidos'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await storage.readToken(), 'new');
      expect(expiredCount, 0);
    });

    test('other error statuses do not expire the session', () async {
      await storage.saveToken('tok');

      for (final status in [400, 403, 404, 500]) {
        adapter.statusCode = status;
        await expectLater(
          dio.get<dynamic>('/mesas'),
          throwsA(isA<DioException>()),
        );
      }
      await Future<void>.delayed(Duration.zero);

      expect(await storage.readToken(), 'tok');
      expect(expiredCount, 0);
    });
  });
}
