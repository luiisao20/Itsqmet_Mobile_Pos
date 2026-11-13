import 'dart:convert';

bool isTokenExpired(String token, DateTime now) {
  final expiresAt = _expiresAt(token);
  if (expiresAt == null) return false;
  return !now.toUtc().isBefore(expiresAt);
}

DateTime? _expiresAt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final claims = jsonDecode(payload);
    if (claims is! Map<String, dynamic>) return null;
    final exp = claims['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).toInt(),
      isUtc: true,
    );
  } catch (_) {
    return null;
  }
}
