import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/mesa_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockMesaDatasource extends Mock implements MesaDatasource {}

const _mesaModel = MesaModel(
  id: 3,
  numeroMesa: 3,
  capacidad: 4,
  ubicacion: 'Terraza',
  estado: EstadoMesa.libre,
);

void main() {
  late _MockMesaDatasource datasource;
  late MesaRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const MesaRequest(numeroMesa: 0, capacidad: 0));
    registerFallbackValue(EstadoMesa.libre);
  });

  setUp(() {
    datasource = _MockMesaDatasource();
    repository = MesaRepositoryImpl(datasource);
  });

  test('getMesas maps the page keeping its metadata', () async {
    when(() => datasource.getMesas(page: 1, size: 10)).thenAnswer(
      (_) async => const PageResult<MesaModel>(
        content: [_mesaModel],
        totalElements: 11,
        totalPages: 2,
        number: 1,
        size: 10,
        first: false,
        last: true,
        empty: false,
      ),
    );

    final page = await repository.getMesas(page: 1, size: 10);

    expect(page.content, [mesaFixture()]);
    expect(page.totalElements, 11);
    expect(page.number, 1);
    expect(page.last, isTrue);
  });

  test('getMesas forwards the default paging', () async {
    when(() => datasource.getMesas(page: 0, size: 100))
        .thenAnswer((_) async => PageResult<MesaModel>.single(const []));

    expect((await repository.getMesas()).empty, isTrue);
  });

  test('getMesa maps the model', () async {
    when(() => datasource.getMesa(3)).thenAnswer((_) async => _mesaModel);

    expect(await repository.getMesa(3), mesaFixture());
  });

  test('getMesa maps a 404 to NotFoundException', () async {
    when(() => datasource.getMesa(99)).thenThrow(httpError(404));

    await expectLater(
      repository.getMesa(99),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('createMesa maps the draft to the request', () async {
    when(() => datasource.createMesa(any()))
        .thenAnswer((_) async => _mesaModel);

    final mesa = await repository.createMesa(
      const MesaDraft(
        numeroMesa: 3,
        capacidad: 4,
        ubicacion: 'Terraza',
        estado: EstadoMesa.libre,
      ),
    );

    expect(mesa, mesaFixture());
    final request =
        verify(() => datasource.createMesa(captureAny())).captured.single
            as MesaRequest;
    expect(request.toJson(), {
      'numeroMesa': 3,
      'capacidad': 4,
      'ubicacion': 'Terraza',
      'estado': 'LIBRE',
    });
  });

  test('createMesa surfaces validation errors', () async {
    when(() => datasource.createMesa(any())).thenThrow(
      httpError(400, {
        'error': 'Validación fallida',
        'detalles': {'capacidad': 'Debe ser mayor a 0'},
      }),
    );

    await expectLater(
      repository.createMesa(const MesaDraft(numeroMesa: 1, capacidad: 0)),
      throwsA(
        isA<ValidationException>().having((e) => e.fieldErrors, 'fieldErrors', {
          'capacidad': 'Debe ser mayor a 0',
        }),
      ),
    );
  });

  test('updateMesa passes the id and the request', () async {
    when(() => datasource.updateMesa(any(), any()))
        .thenAnswer((_) async => _mesaModel);

    await repository.updateMesa(
      3,
      const MesaDraft(numeroMesa: 3, capacidad: 6),
    );

    final captured = verify(
      () => datasource.updateMesa(captureAny(), captureAny()),
    ).captured;
    expect(captured.first, 3);
    expect((captured.last as MesaRequest).toJson(), {
      'numeroMesa': 3,
      'capacidad': 6,
    });
  });

  test('deleteMesa delegates to the datasource', () async {
    when(() => datasource.deleteMesa(3)).thenAnswer((_) async {});

    await repository.deleteMesa(3);

    verify(() => datasource.deleteMesa(3)).called(1);
  });

  test('deleteMesa maps network failures', () async {
    when(() => datasource.deleteMesa(3)).thenThrow(connectionFailure());

    await expectLater(
      repository.deleteMesa(3),
      throwsA(isA<NetworkException>()),
    );
  });

  test('updateEstado forwards the state and maps the result', () async {
    when(() => datasource.updateEstado(3, EstadoMesa.ocupada)).thenAnswer(
      (_) async => const MesaModel(
        id: 3,
        numeroMesa: 3,
        capacidad: 4,
        ubicacion: 'Terraza',
        estado: EstadoMesa.ocupada,
      ),
    );

    final mesa = await repository.updateEstado(3, EstadoMesa.ocupada);

    expect(mesa, mesaFixture(estado: EstadoMesa.ocupada));
  });

  test('updateEstado maps a 401 to UnauthorizedException', () async {
    when(() => datasource.updateEstado(any(), any())).thenThrow(httpError(401));

    await expectLater(
      repository.updateEstado(3, EstadoMesa.cuenta),
      throwsA(isA<UnauthorizedException>()),
    );
  });
}
