import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/distribuidor_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockDistribuidorDatasource extends Mock
    implements DistribuidorDatasource {}

const _model = DistribuidorModel(
  id: 2,
  ruc: '1790012345001',
  razonSocial: 'Distribuidora S.A.',
);

const _draft = DistribuidorDraft(
  ruc: '1790012345001',
  razonSocial: 'Distribuidora S.A.',
  email: 'ventas@dist.com',
);

void main() {
  late _MockDistribuidorDatasource datasource;
  late DistribuidorRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(DistribuidorRequest.fromDraft(_draft));
  });

  setUp(() {
    datasource = _MockDistribuidorDatasource();
    repository = DistribuidorRepositoryImpl(datasource);
  });

  group('getDistribuidores', () {
    test('forwards paging and maps the page to entities', () async {
      when(() => datasource.getDistribuidores(page: 3, size: 15))
          .thenAnswer((_) async => PageResult.single(const [_model]));

      final page = await repository.getDistribuidores(page: 3, size: 15);

      expect(page.content, [distribuidorFixture()]);
      verify(() => datasource.getDistribuidores(page: 3, size: 15)).called(1);
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => datasource.getDistribuidores(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(
        repository.getDistribuidores(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps an unexpected payload to UnknownException', () async {
      when(
        () => datasource.getDistribuidores(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(const FormatException('bad payload'));

      await expectLater(
        repository.getDistribuidores(),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  group('createDistribuidor', () {
    test('sends the draft as a request and maps the result', () async {
      when(() => datasource.createDistribuidor(any()))
          .thenAnswer((_) async => _model);

      final distribuidor = await repository.createDistribuidor(_draft);

      expect(distribuidor, distribuidorFixture());
      final request =
          verify(() => datasource.createDistribuidor(captureAny()))
                  .captured
                  .single
              as DistribuidorRequest;
      expect(request.toJson(), {
        'ruc': '1790012345001',
        'razonSocial': 'Distribuidora S.A.',
        'email': 'ventas@dist.com',
      });
    });

    test('maps a 400 with detalles to ValidationException', () async {
      when(() => datasource.createDistribuidor(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'ruc': 'RUC inválido'},
        }),
      );

      await expectLater(
        repository.createDistribuidor(_draft),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors,
            'fieldErrors',
            {'ruc': 'RUC inválido'},
          ),
        ),
      );
    });

    test('maps a 409 conflict to BadRequestException', () async {
      when(() => datasource.createDistribuidor(any()))
          .thenThrow(httpError(409, {'message': 'El RUC ya existe'}));

      await expectLater(
        repository.createDistribuidor(_draft),
        throwsA(isA<BadRequestException>()),
      );
    });
  });

  group('updateDistribuidor', () {
    test('forwards the id and the request', () async {
      when(() => datasource.updateDistribuidor(any(), any()))
          .thenAnswer((_) async => _model);

      final distribuidor = await repository.updateDistribuidor(2, _draft);

      expect(distribuidor, distribuidorFixture());
      final captured = verify(
        () => datasource.updateDistribuidor(captureAny(), captureAny()),
      ).captured;
      expect(captured.first, 2);
      expect(
        (captured.last as DistribuidorRequest).toJson(),
        DistribuidorRequest.fromDraft(_draft).toJson(),
      );
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.updateDistribuidor(any(), any()))
          .thenThrow(httpError(404));

      await expectLater(
        repository.updateDistribuidor(9, _draft),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  test('deleteDistribuidor delegates to the datasource', () async {
    when(() => datasource.deleteDistribuidor(2)).thenAnswer((_) async {});

    await repository.deleteDistribuidor(2);

    verify(() => datasource.deleteDistribuidor(2)).called(1);
  });
}
