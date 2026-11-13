import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._notifier);

  static const String _header = 'Authorization';
  static const String _scheme = 'Bearer ';

  final SessionStorage _storage;
  final SessionExpiredNotifier _notifier;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty && _isApiOrigin(options)) {
      options.headers[_header] = '$_scheme$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode == 401 &&
        !_isAuthPath(options) &&
        await _wasSentWithCurrentToken(options)) {
      await _storage.clear();
      _notifier.notifyExpired();
    }
    handler.next(err);
  }

  Future<bool> _wasSentWithCurrentToken(RequestOptions options) async {
    final current = await _storage.readToken();
    final sent = options.headers[_header];
    final sentToken = sent is String && sent.startsWith(_scheme)
        ? sent.substring(_scheme.length)
        : null;
    return _orNull(sentToken) == _orNull(current);
  }

  static String? _orNull(String? value) =>
      value == null || value.isEmpty ? null : value;

  static bool _isApiOrigin(RequestOptions options) {
    final base = Uri.tryParse(options.baseUrl);
    if (base == null || !base.hasScheme) return true;
    return options.uri.origin == base.origin;
  }

  static bool _isAuthPath(RequestOptions options) {
    var path = options.path;
    final parsed = Uri.tryParse(path);
    if (parsed != null && parsed.hasScheme) path = parsed.path;
    if (!path.startsWith('/')) path = '/$path';
    return path.startsWith('/auth/');
  }
}
