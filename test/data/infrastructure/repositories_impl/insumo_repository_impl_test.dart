import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/insumo_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockInsumoDatasource extends Mock implements InsumoDatasource {}

const _model = InsumoModel(
  id: 4,
  nombre: 'Arroz',
  unidadMedida: UnidadMedida.kg,
  stockActual: 10,
  stockMinimo: 5,
  costoPromedio: 1.2,
);

const _draft = InsumoDraft(
  nombre: 'Arroz',
  unidadMedida: UnidadMedida.kg,
  stockActual: 10,
  stockMinimo: 5,
  costoPromedio: 1.2,
);

void main() {
  late _MockInsumoDatasource datasource;
  late InsumoRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(InsumoRequest.fromDraft(_draft));
  });

  setUp(() {
    datasource = _MockInsumoDatasource();
    repository = InsumoRepositoryImpl(datasource);
  });

  group('getInsumos', () {
    test('forwards paging and maps the page to entities', () async {
      when(() => datasource.getInsumos(page: 1, size: 20))
          .thenAnswer((_) async => PageResult.single(const [_model]));

      final page = await repository.getInsumos(page: 1, size: 20);

      expect(page.content, [insumoFixture()]);
      verify(() => datasource.getInsumos(page: 1, size: 20)).called(1);
    });

    test('maps a 500 to ServerException', () async {
      when(
        () => datasource.getInsumos(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(httpError(500, {'error': 'Error interno en el servidor'}));

      await expectLater(
        repository.getInsumos(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getStockBajo', () {
    test('maps the models and computes a missing stockBajo flag', () async {
      when(() => datasource.getStockBajo()).thenAnswer(
        (_) async => const [
          InsumoModel(
            id: 4,
            nombre: 'Arroz',
            unidadMedida: UnidadMedida.kg,
            stockActual: 3,
            stockMinimo: 5,
            costoPromedio: 1.2,
          ),
        ],
      );

      final insumos = await repository.getStockBajo();

      expect(insumos, [
        insumoFixture(stockActual: 3, stockMinimo: 5, stockBajo: true),
      ]);
    });

    test('maps network failures to NetworkException', () async {
      when(() => datasource.getStockBajo()).thenThrow(connectionFailure());

      await expectLater(
        repository.getStockBajo(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('createInsumo', () {
    test('sends the draft as a request and maps the result', () async {
      when(() => datasource.createInsumo(any()))
          .thenAnswer((_) async => _model);

      final insumo = await repository.createInsumo(_draft);

      expect(insumo, insumoFixture());
      final request =
          verify(() => datasource.createInsumo(captureAny())).captured.single
              as InsumoRequest;
      expect(request.toJson(), {
        'nombre': 'Arroz',
        'unidadMedida': 'KG',
        'stockActual': 10.0,
        'stockMinimo': 5.0,
        'costoPromedio': 1.2,
      });
    });

    test('maps a 400 with detalles to ValidationException', () async {
      when(() => datasource.createInsumo(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'nombre': 'El nombre es obligatorio'},
        }),
      );

      await expectLater(
        repository.createInsumo(_draft),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('updateInsumo', () {
    test('forwards the id and the request', () async {
      when(() => datasource.updateInsumo(any(), any()))
          .thenAnswer((_) async => _model);

      final insumo = await repository.updateInsumo(4, _draft);

      expect(insumo, insumoFixture());
      final captured = verify(
        () => datasource.updateInsumo(captureAny(), captureAny()),
      ).captured;
      expect(captured.first, 4);
      expect(
        (captured.last as InsumoRequest).toJson(),
        InsumoRequest.fromDraft(_draft).toJson(),
      );
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.updateInsumo(any(), any()))
          .thenThrow(httpError(404));

      await expectLater(
        repository.updateInsumo(99, _draft),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteInsumo', () {
    test('delegates to the datasource', () async {
      when(() => datasource.deleteInsumo(4)).thenAnswer((_) async {});

      await repository.deleteInsumo(4);

      verify(() => datasource.deleteInsumo(4)).called(1);
    });

    test('maps a 409 conflict to BadRequestException', () async {
      when(() => datasource.deleteInsumo(4))
          .thenThrow(httpError(409, {'message': 'El insumo está en uso'}));

      await expectLater(
        repository.deleteInsumo(4),
        throwsA(isA<BadRequestException>()),
      );
    });
  });
}
