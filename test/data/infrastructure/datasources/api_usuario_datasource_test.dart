import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_usuario_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _usuarioJson = {
  'uuid': 'u-1',
  'nombre': 'Ana',
  'apellido': 'Pérez',
  'cedula': '1712345678',
  'email': 'ana@itsqmet.edu.ec',
  'rol': 'MESERO',
  'activo': true,
  'createdAt': '2026-01-15T10:30:00',
};

const _request = UsuarioRequest(
  nombre: 'Ana',
  apellido: 'Pérez',
  cedula: '1712345678',
  email: 'ana@itsqmet.edu.ec',
  password: 'secreto',
  rol: Rol.mesero,
  activo: true,
);

const _requestJson = {
  'nombre': 'Ana',
  'apellido': 'Pérez',
  'cedula': '1712345678',
  'email': 'ana@itsqmet.edu.ec',
  'password': 'secreto',
  'rol': 'MESERO',
  'activo': true,
};

void main() {
  late MockDio dio;
  late ApiUsuarioDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiUsuarioDatasource(dio);
  });

  group('getUsuarios', () {
    test(
      'GETs /usuarios with page and size and parses the Spring page',
      () async {
        when(
          () => dio.get<dynamic>(
            '/usuarios',
            queryParameters: {'page': 2, 'size': 10},
          ),
        ).thenAnswer((_) async => okResponse(pageJson([_usuarioJson])));

        final page = await datasource.getUsuarios(page: 2, size: 10);

        expect(page.content, hasLength(1));
        final usuario = page.content.single;
        expect(usuario.uuid, 'u-1');
        expect(usuario.rol, Rol.mesero);
        expect(usuario.createdAt, DateTime(2026, 1, 15, 10, 30));
        expect(page.totalElements, 1);
      },
    );

    test('uses page 0 and size 100 by default', () async {
      when(
        () => dio.get<dynamic>(
          '/usuarios',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.getUsuarios();

      expect(page.empty, isTrue);
      verify(
        () => dio.get<dynamic>(
          '/usuarios',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).called(1);
    });
  });

  test('getUsuario GETs /usuarios/{uuid}', () async {
    when(() => dio.get<dynamic>('/usuarios/u-1'))
        .thenAnswer((_) async => okResponse(_usuarioJson));

    final usuario = await datasource.getUsuario('u-1');

    expect(usuario.email, 'ana@itsqmet.edu.ec');
    expect(usuario.activo, isTrue);
  });

  test('createUsuario POSTs /usuarios with the request body', () async {
    when(() => dio.post<dynamic>('/usuarios', data: _requestJson))
        .thenAnswer((_) async => okResponse(_usuarioJson, status: 201));

    final usuario = await datasource.createUsuario(_request);

    expect(usuario.uuid, 'u-1');
    verify(() => dio.post<dynamic>('/usuarios', data: _requestJson)).called(1);
  });

  test('updateUsuario PUTs /usuarios/{uuid} with the request body', () async {
    when(
      () => dio.put<dynamic>('/usuarios/u-1', data: _requestJson),
    ).thenAnswer((_) async => okResponse({..._usuarioJson, 'activo': false}));

    final usuario = await datasource.updateUsuario('u-1', _request);

    expect(usuario.activo, isFalse);
    verify(() => dio.put<dynamic>('/usuarios/u-1', data: _requestJson))
        .called(1);
  });

  test('deleteUsuario DELETEs /usuarios/{uuid} (204)', () async {
    when(() => dio.delete<dynamic>('/usuarios/u-1'))
        .thenAnswer((_) async => okResponse(null, status: 204));

    await datasource.deleteUsuario('u-1');

    verify(() => dio.delete<dynamic>('/usuarios/u-1')).called(1);
  });

  test('lets DioException propagate unmapped', () async {
    when(() => dio.get<dynamic>('/usuarios/x')).thenThrow(httpError(404));

    await expectLater(datasource.getUsuario('x'), throwsA(isA<DioException>()));
  });
}
