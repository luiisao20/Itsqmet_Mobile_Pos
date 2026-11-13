import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/network/cookie_token_extractor.dart';

void main() {
  group('CookieTokenExtractor.extractJwt', () {
    test('extracts the jwt cookie from Dio Headers', () {
      final headers = Headers.fromMap({
        'set-cookie': ['jwt=abc.def.ghi; Path=/; HttpOnly; Max-Age=86400'],
      });

      expect(CookieTokenExtractor.extractJwt(headers), 'abc.def.ghi');
    });

    test('accepts a plain map with a case-insensitive key', () {
      final headers = <String, List<String>>{
        'Set-Cookie': ['jwt=tok123; Path=/'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'tok123');
    });

    test('finds the jwt among multiple Set-Cookie values', () {
      final headers = <String, List<String>>{
        'set-cookie': ['theme=dark; Path=/', 'jwt=tok; Path=/', 'x=1'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'tok');
    });

    test('handles comma-joined cookies with Expires date commas', () {
      final headers = <String, List<String>>{
        'set-cookie': [
          'jwt=tok; Expires=Wed, 21 Oct 2026 07:28:00 GMT; Path=/, other=1; Path=/',
        ],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'tok');
    });

    test('handles a jwt that comes after an Expires date comma', () {
      final headers = <String, List<String>>{
        'set-cookie': [
          'other=1; Expires=Wed, 21 Oct 2026 07:28:00 GMT, jwt=tok2; Path=/',
        ],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'tok2');
    });

    test('ignores a cleared cookie (empty value)', () {
      final headers = <String, List<String>>{
        'set-cookie': ['jwt=; Path=/; Max-Age=0'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), isNull);
    });

    test('ignores an expired cookie (Max-Age=0) even with a value', () {
      final headers = <String, List<String>>{
        'set-cookie': ['jwt=deleted; Path=/; Max-Age=0'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), isNull);
    });

    test('prefers a fresh jwt over a cleared one', () {
      final headers = <String, List<String>>{
        'set-cookie': ['jwt=; Max-Age=0', 'jwt=fresh; Path=/'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'fresh');
    });

    test('matches the cookie name exactly', () {
      final headers = <String, List<String>>{
        'set-cookie': ['jwt2=x; Path=/', 'xjwt=abc; Path=/', 'JWT=upper'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), isNull);
    });

    test('keeps = characters inside the value', () {
      final headers = <String, List<String>>{
        'set-cookie': ['jwt=abc==; Path=/'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'abc==');
    });

    test('tolerates whitespace around the cookie', () {
      final headers = <String, List<String>>{
        'set-cookie': ['  jwt=tok ; Path=/'],
      };

      expect(CookieTokenExtractor.extractJwt(headers), 'tok');
    });

    test('returns null when there is no Set-Cookie header', () {
      expect(CookieTokenExtractor.extractJwt(Headers()), isNull);
      expect(
        CookieTokenExtractor.extractJwt(<String, List<String>>{
          'content-type': ['application/json'],
        }),
        isNull,
      );
      expect(
        CookieTokenExtractor.extractJwt(<String, List<String>>{
          'set-cookie': <String>[],
        }),
        isNull,
      );
    });

    test('returns null for null or unsupported input', () {
      expect(CookieTokenExtractor.extractJwt(null), isNull);
      expect(CookieTokenExtractor.extractJwt('jwt=abc'), isNull);
    });
  });
}
