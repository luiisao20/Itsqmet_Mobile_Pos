import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> okResponse(
  Object? data, {
  int status = 200,
  Map<String, List<String>>? headers,
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/'),
    statusCode: status,
    data: data,
    headers: Headers.fromMap(headers ?? const {}),
  );
}

DioException httpError(int status, [Object? body]) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

DioException connectionFailure() => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: DioExceptionType.connectionError,
);

Map<String, dynamic> pageJson(List<Map<String, dynamic>> content) => {
  'content': content,
  'totalElements': content.length,
  'totalPages': content.isEmpty ? 0 : 1,
  'number': 0,
  'size': 100,
  'first': true,
  'last': true,
  'empty': content.isEmpty,
};
