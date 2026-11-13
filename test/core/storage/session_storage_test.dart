import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/core/storage/secure_session_storage.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('InMemorySessionStorage', () {
    late SessionStorage storage;

    setUp(() => storage = InMemorySessionStorage());

    test('starts empty', () async {
      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
    });

    test('stores and reads the token and the user snapshot', () async {
      await storage.saveToken('tok');
      await storage.saveUserJson('{"uuid":"1"}');

      expect(await storage.readToken(), 'tok');
      expect(await storage.readUserJson(), '{"uuid":"1"}');
    });

    test('clear removes everything', () async {
      await storage.saveToken('tok');
      await storage.saveUserJson('{}');

      await storage.clear();

      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
    });
  });

  group('SecureSessionStorage', () {
    late _MockSecureStorage secure;
    late SecureSessionStorage storage;

    setUp(() {
      secure = _MockSecureStorage();
      storage = SecureSessionStorage(storage: secure);
      when(
        () => secure.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => secure.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
    });

    test('reads the token from secure storage once and caches it', () async {
      when(() => secure.read(key: 'pos_token')).thenAnswer((_) async => 'tok');

      expect(await storage.readToken(), 'tok');
      expect(await storage.readToken(), 'tok');

      verify(() => secure.read(key: 'pos_token')).called(1);
    });

    test('caches an absent token too', () async {
      when(() => secure.read(key: 'pos_token')).thenAnswer((_) async => null);

      expect(await storage.readToken(), isNull);
      expect(await storage.readToken(), isNull);

      verify(() => secure.read(key: 'pos_token')).called(1);
    });

    test('saveToken persists under pos_token and updates the cache', () async {
      await storage.saveToken('new');

      expect(await storage.readToken(), 'new');
      verify(() => secure.write(key: 'pos_token', value: 'new')).called(1);
      verifyNever(() => secure.read(key: 'pos_token'));
    });

    test('user snapshot uses the pos_user key', () async {
      when(() => secure.read(key: 'pos_user'))
          .thenAnswer((_) async => '{"uuid":"1"}');

      await storage.saveUserJson('{"uuid":"2"}');

      expect(await storage.readUserJson(), '{"uuid":"1"}');
      verify(() => secure.write(key: 'pos_user', value: '{"uuid":"2"}'))
          .called(1);
    });

    test('clear deletes both keys and resets the cached token', () async {
      await storage.saveToken('tok');

      await storage.clear();

      expect(await storage.readToken(), isNull);
      verify(() => secure.delete(key: 'pos_token')).called(1);
      verify(() => secure.delete(key: 'pos_user')).called(1);
      verifyNever(() => secure.read(key: 'pos_token'));
    });

    test('a failing secure storage read behaves as no session', () async {
      when(() => secure.read(key: any(named: 'key')))
          .thenThrow(Exception('keystore unavailable'));

      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
    });
  });
}
