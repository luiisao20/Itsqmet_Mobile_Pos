import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';

void main() {
  tearDown(dotenv.clean);

  group('AppEnvironment.resolve', () {
    test('returns the fallback when the source map is null', () {
      expect(AppEnvironment.resolve(null, 'KEY', 'fallback'), 'fallback');
    });

    test('returns the fallback when the key is missing', () {
      expect(
        AppEnvironment.resolve({'OTHER': 'x'}, 'KEY', 'fallback'),
        'fallback',
      );
    });

    test('returns the fallback when the value is blank', () {
      expect(
        AppEnvironment.resolve({'KEY': '   '}, 'KEY', 'fallback'),
        'fallback',
      );
    });

    test('returns the trimmed value when present', () {
      expect(
        AppEnvironment.resolve({'KEY': '  http://host:8080 '}, 'KEY', 'fb'),
        'http://host:8080',
      );
    });
  });

  group('AppEnvironment getters', () {
    test('fall back to the emulator host when dotenv is not loaded', () {
      expect(dotenv.isInitialized, isFalse);

      expect(AppEnvironment.apiBaseUrl, 'http://10.0.2.2:8080');
      expect(AppEnvironment.wsUrl, 'ws://10.0.2.2:8080/ws-pos');
    });

    test('fall back when dotenv is loaded without the keys', () {
      dotenv.loadFromString(envString: 'SOMETHING_ELSE=1');

      expect(AppEnvironment.apiBaseUrl, AppEnvironment.defaultApiBaseUrl);
      expect(AppEnvironment.wsUrl, AppEnvironment.defaultWsUrl);
    });

    test('read the values from dotenv when available', () {
      dotenv.loadFromString(
        envString:
            'API_BASE_URL=https://api.example.com\n'
            'WS_URL=wss://api.example.com/ws-pos',
      );

      expect(AppEnvironment.apiBaseUrl, 'https://api.example.com');
      expect(AppEnvironment.wsUrl, 'wss://api.example.com/ws-pos');
    });
  });
}
