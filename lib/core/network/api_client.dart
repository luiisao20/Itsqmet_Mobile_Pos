import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';
import 'package:itsqmet_mobile_pos/core/network/auth_interceptor.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';

class ApiClient {
  ApiClient({
    required SessionStorage storage,
    required SessionExpiredNotifier notifier,
    String? baseUrl,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? AppEnvironment.apiBaseUrl,
           contentType: Headers.jsonContentType,
           connectTimeout: timeout,
           receiveTimeout: timeout,
         ),
       ) {
    dio.interceptors.add(AuthInterceptor(storage, notifier));
  }

  static const Duration timeout = Duration(seconds: 15);

  final Dio dio;
}
