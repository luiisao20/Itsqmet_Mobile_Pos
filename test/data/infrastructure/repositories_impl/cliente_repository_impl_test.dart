import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/cliente_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockClienteDatasource extends Mock implements ClienteDatasource {}

const _model = ClienteModel(
  uuid: 'c-1',
  tipoIdentificacion: TipoIdentificacion.cedula,
  identificacion: '1712345678',
  razonSocial: 'Juan Cliente',
);

const _draft = ClienteDraft(
  tipoIdentificacion: TipoIdentificacion.cedula,
  identificacion: '1712345678',
  razonSocial: 'Juan Cliente',
  telefono: '0999999999',
  activo: true,
);

void main() {
  late _MockClienteDatasource datasource;
  late ClienteRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ClienteRequest.fromDraft(_draft));
  });

  setUp(() {
    datasource = _MockClienteDatasource();
    repository = ClienteRepositoryImpl(datasource);
  });

  group('getClientes', () {
    test('forwards paging and maps the page to entities', () async {
      when(() => datasource.getClientes(page: 2, size: 10))
          .thenAnswer((_) async => PageResult.single(const [_model]));

      final page = await repository.getClientes(page: 2, size: 10);

      expect(page.content, [clienteFixture()]);
      verify(() => datasource.getClientes(page: 2, size: 10)).called(1);
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => datasource.getClientes(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(
        repository.getClientes(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getCliente', () {
    test('maps the model to an entity', () async {
      when(() => datasource.getCliente('c-1')).thenAnswer((_) async => _model);

      expect(await repository.getCliente('c-1'), clienteFixture());
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.getCliente('x')).thenThrow(httpError(404));

      await expectLater(
        repository.getCliente('x'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getByIdentificacion', () {
    test('maps the model to an entity', () async {
      when(() => datasource.getByIdentificacion('1712345678'))
          .thenAnswer((_) async => _model);

      expect(
        await repository.getByIdentificacion('1712345678'),
        clienteFixture(),
      );
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.getByIdentificacion('000'))
          .thenThrow(httpError(404, {'mensaje': 'Cliente no encontrado'}));

      await expectLater(
        repository.getByIdentificacion('000'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Cliente no encontrado',
          ),
        ),
      );
    });
  });

  test('searchClientes forwards filtro and paging and maps the page', () async {
    when(() => datasource.searchClientes('juan', page: 1, size: 5))
        .thenAnswer((_) async => PageResult.single(const [_model]));

    final page = await repository.searchClientes('juan', page: 1, size: 5);

    expect(page.content, [clienteFixture()]);
    verify(() => datasource.searchClientes('juan', page: 1, size: 5)).called(1);
  });

  group('createCliente', () {
    test('sends the draft as a request and maps the result', () async {
      when(() => datasource.createCliente(any()))
          .thenAnswer((_) async => _model);

      final cliente = await repository.createCliente(_draft);

      expect(cliente, clienteFixture());
      final request =
          verify(() => datasource.createCliente(captureAny())).captured.single
              as ClienteRequest;
      expect(request.toJson(), {
        'tipoIdentificacion': 'CEDULA',
        'identificacion': '1712345678',
        'razonSocial': 'Juan Cliente',
        'telefono': '0999999999',
        'activo': true,
      });
    });

    test('maps a 400 with detalles to ValidationException', () async {
      when(() => datasource.createCliente(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'identificacion': 'Identificación requerida'},
        }),
      );

      await expectLater(
        repository.createCliente(_draft),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors,
            'fieldErrors',
            {'identificacion': 'Identificación requerida'},
          ),
        ),
      );
    });
  });

  test('updateCliente forwards the uuid and the request', () async {
    when(() => datasource.updateCliente(any(), any()))
        .thenAnswer((_) async => _model);

    final cliente = await repository.updateCliente('c-1', _draft);

    expect(cliente, clienteFixture());
    final captured = verify(
      () => datasource.updateCliente(captureAny(), captureAny()),
    ).captured;
    expect(captured.first, 'c-1');
    expect(
      (captured.last as ClienteRequest).toJson(),
      ClienteRequest.fromDraft(_draft).toJson(),
    );
  });

  group('deleteCliente', () {
    test('delegates to the datasource', () async {
      when(() => datasource.deleteCliente('c-1')).thenAnswer((_) async {});

      await repository.deleteCliente('c-1');

      verify(() => datasource.deleteCliente('c-1')).called(1);
    });

    test('maps a 409 conflict to BadRequestException', () async {
      when(() => datasource.deleteCliente('c-1'))
          .thenThrow(httpError(409, {'message': 'El cliente tiene facturas'}));

      await expectLater(
        repository.deleteCliente('c-1'),
        throwsA(isA<BadRequestException>()),
      );
    });
  });
}
