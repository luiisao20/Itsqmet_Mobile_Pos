import 'package:dio/dio.dart';

abstract final class CookieTokenExtractor {
  static const String cookieName = 'jwt';

  static final RegExp _cookieBoundary = RegExp(r',(?=\s*[^;,=\s]+=)');

  static String? extractJwt(Object? headers) {
    for (final raw in _setCookieValues(headers)) {
      for (final cookie in raw.split(_cookieBoundary)) {
        final token = _jwtFrom(cookie);
        if (token != null) return token;
      }
    }
    return null;
  }

  static List<String> _setCookieValues(Object? headers) {
    final Map<dynamic, dynamic>? map = switch (headers) {
      Headers() => headers.map,
      Map<dynamic, dynamic>() => headers,
      _ => null,
    };
    if (map == null) return const [];

    final result = <String>[];
    map.forEach((key, value) {
      if (key.toString().toLowerCase() != 'set-cookie') return;
      if (value is Iterable) {
        result.addAll(value.map((item) => item.toString()));
      } else if (value != null) {
        result.add(value.toString());
      }
    });
    return result;
  }

  static String? _jwtFrom(String cookie) {
    final parts = cookie.split(';');
    final pair = parts.first.trim();
    final separator = pair.indexOf('=');
    if (separator <= 0) return null;

    final name = pair.substring(0, separator).trim();
    if (name != cookieName) return null;

    var value = pair.substring(separator + 1).trim();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    if (value.isEmpty) return null;

    for (final attribute in parts.skip(1)) {
      final normalized = attribute.replaceAll(' ', '').toLowerCase();
      if (normalized == 'max-age=0') return null;
    }
    return value;
  }
}
