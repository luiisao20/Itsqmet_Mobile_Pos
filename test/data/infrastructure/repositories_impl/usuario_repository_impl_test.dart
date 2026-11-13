import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/usuario_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockUsuarioDatasource extends Mock implements UsuarioDatasource {}

const _model = UsuarioModel(
  uuid: 'u-1',
  nombre: 'Ana',
  apellido: 'Pérez',
  cedula: '1712345678',
  email: 'ana@itsqmet.edu.ec',
  rol: Rol.mesero,
  activo: true,
);

const _draft = UsuarioDraft(
  nombre: 'Ana',
  apellido: 'Pérez',
  cedula: '1712345678',
  email: 'ana@itsqmet.edu.ec',
  password: 'secreto',
  rol: Rol.mesero,
  activo: true,
);

void main() {
  late _MockUsuarioDatasource datasource;
  late UsuarioRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(UsuarioRequest.fromDraft(_draft));
  });

  setUp(() {
    datasource = _MockUsuarioDatasource();
    repository = UsuarioRepositoryImpl(datasource);
  });

  group('getUsuarios', () {
    test('forwards paging and maps the page to entities', () async {
      when(() => datasource.getUsuarios(page: 1, size: 5))
          .thenAnswer((_) async => PageResult.single(const [_model]));

      final page = await repository.getUsuarios(page: 1, size: 5);

      expect(page.content, [usuarioFixture()]);
      expect(page.totalElements, 1);
      verify(() => datasource.getUsuarios(page: 1, size: 5)).called(1);
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => datasource.getUsuarios(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(
        repository.getUsuarios(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getUsuario', () {
    test('maps the model to an entity', () async {
      when(() => datasource.getUsuario('u-1')).thenAnswer((_) async => _model);

      expect(await repository.getUsuario('u-1'), usuarioFixture());
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.getUsuario('x')).thenThrow(
        httpError(404, {
          'error': 'No encontrado',
          'message': 'Usuario no existe',
        }),
      );

      await expectLater(
        repository.getUsuario('x'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Usuario no existe',
          ),
        ),
      );
    });
  });

  group('createUsuario', () {
    test('sends the draft as a request and maps the result', () async {
      when(() => datasource.createUsuario(any()))
          .thenAnswer((_) async => _model);

      final usuario = await repository.createUsuario(_draft);

      expect(usuario, usuarioFixture());
      final request =
          verify(() => datasource.createUsuario(captureAny())).captured.single
              as UsuarioRequest;
      expect(request.toJson(), {
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'cedula': '1712345678',
        'email': 'ana@itsqmet.edu.ec',
        'password': 'secreto',
        'rol': 'MESERO',
        'activo': true,
      });
    });

    test('maps a 400 with detalles to ValidationException', () async {
      when(() => datasource.createUsuario(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'cedula': 'Cédula inválida'},
        }),
      );

      await expectLater(
        repository.createUsuario(_draft),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors,
            'fieldErrors',
            {'cedula': 'Cédula inválida'},
          ),
        ),
      );
    });

    test('maps a 409 conflict to BadRequestException', () async {
      when(
        () => datasource.createUsuario(any()),
      ).thenThrow(httpError(409, {'message': 'El email ya está registrado'}));

      await expectLater(
        repository.createUsuario(_draft),
        throwsA(
          isA<BadRequestException>().having(
            (e) => e.message,
            'message',
            'El email ya está registrado',
          ),
        ),
      );
    });
  });

  test('updateUsuario forwards the uuid and the request', () async {
    when(() => datasource.updateUsuario(any(), any()))
        .thenAnswer((_) async => _model);

    final usuario = await repository.updateUsuario('u-1', _draft);

    expect(usuario, usuarioFixture());
    final captured = verify(
      () => datasource.updateUsuario(captureAny(), captureAny()),
    ).captured;
    expect(captured.first, 'u-1');
    expect(
      (captured.last as UsuarioRequest).toJson(),
      UsuarioRequest.fromDraft(_draft).toJson(),
    );
  });

  group('deleteUsuario', () {
    test('delegates to the datasource', () async {
      when(() => datasource.deleteUsuario('u-1')).thenAnswer((_) async {});

      await repository.deleteUsuario('u-1');

      verify(() => datasource.deleteUsuario('u-1')).called(1);
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.deleteUsuario('x')).thenThrow(httpError(404));

      await expectLater(
        repository.deleteUsuario('x'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
