import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';

String authErrorMessage(Object error, String fallback) => switch (error) {
  NetworkException(:final message) => message,
  RequestTimeoutException(:final message) => message,
  _ => fallback,
};
