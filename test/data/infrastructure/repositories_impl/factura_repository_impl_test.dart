import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/factura_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockFacturaDatasource extends Mock implements FacturaDatasource {}

FacturaModel _facturaModel({int id = 7}) => FacturaModel(
  id: id,
  idPedido: 50,
  numeroSecuencial: '001-001-000000007',
  subtotal: 17,
  subtotalIva: 2.55,
  propina: 0.45,
  total: 20,
  estado: EstadoFactura.emitida,
);

PagoModel _pagoModel({int id = 9}) =>
    PagoModel(id: id, idFactura: 7, metodoPago: MetodoPago.efectivo, monto: 20);

PageResult<FacturaModel> _page(List<FacturaModel> content) => PageResult(
  content: content,
  totalElements: 25,
  totalPages: 3,
  number: 0,
  size: 10,
  first: true,
  last: false,
  empty: content.isEmpty,
);

void main() {
  late _MockFacturaDatasource datasource;
  late FacturaRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const FacturaRequest(idPedido: 0, idCliente: '', numeroSecuencial: ''),
    );
    registerFallbackValue(
      const PagoRequest(
        idFactura: 0,
        metodoPago: MetodoPago.efectivo,
        monto: 0,
      ),
    );
  });

  setUp(() {
    datasource = _MockFacturaDatasource();
    repository = FacturaRepositoryImpl(datasource);
  });

  group('getFacturas', () {
    test('maps the page of models keeping metadata', () async {
      when(() => datasource.getFacturas(page: 0, size: 10))
          .thenAnswer((_) async => _page([_facturaModel()]));

      final page = await repository.getFacturas();

      expect(page.totalElements, 25);
      expect(page.hasNext, isTrue);
      expect(page.content.single, facturaFixture());
    });

    test('maps a 401 to UnauthorizedException', () async {
      when(
        () => datasource.getFacturas(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(httpError(401));

      await expectLater(
        repository.getFacturas(page: 2, size: 5),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => datasource.getFacturas(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(
        repository.getFacturas(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getFactura', () {
    test('maps the model', () async {
      when(() => datasource.getFactura(7))
          .thenAnswer((_) async => _facturaModel());

      expect(await repository.getFactura(7), facturaFixture());
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.getFactura(99))
          .thenThrow(httpError(404, {'message': 'Factura no encontrada'}));

      await expectLater(
        repository.getFactura(99),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Factura no encontrada',
          ),
        ),
      );
    });
  });

  group('getMisFacturas', () {
    test('forwards paging and maps the page', () async {
      when(
        () => datasource.getMisFacturas(page: 1, size: 20),
      ).thenAnswer((_) async => _page([_facturaModel(), _facturaModel(id: 8)]));

      final page = await repository.getMisFacturas(page: 1, size: 20);

      expect(page.content.map((f) => f.id), [7, 8]);
    });
  });

  group('emitirFactura', () {
    test('converts the draft into a request and maps the result', () async {
      const draft = FacturaDraft(
        idPedido: 50,
        idCliente: 'c-1',
        numeroSecuencial: '001-001-000000007',
        claveAccesoSri: '0105202601',
        propina: 0.45,
      );
      when(() => datasource.emitirFactura(any()))
          .thenAnswer((_) async => _facturaModel());

      final factura = await repository.emitirFactura(draft);

      expect(factura, facturaFixture());
      final request =
          verify(() => datasource.emitirFactura(captureAny())).captured.single
              as FacturaRequest;
      expect(request.toJson(), {
        'idPedido': 50,
        'idCliente': 'c-1',
        'numeroSecuencial': '001-001-000000007',
        'claveAccesoSri': '0105202601',
        'propina': 0.45,
      });
    });

    test('maps a 400 business error to BadRequestException', () async {
      when(() => datasource.emitirFactura(any()))
          .thenThrow(httpError(400, {'error': 'El pedido ya fue facturado'}));

      await expectLater(
        repository.emitirFactura(
          const FacturaDraft(
            idPedido: 50,
            idCliente: 'c-1',
            numeroSecuencial: '1',
          ),
        ),
        throwsA(
          isA<BadRequestException>().having(
            (e) => e.message,
            'message',
            'El pedido ya fue facturado',
          ),
        ),
      );
    });
  });

  group('registrarPago', () {
    test('converts the draft into a request and maps the result', () async {
      const draft = PagoDraft(
        idFactura: 7,
        metodoPago: MetodoPago.efectivo,
        monto: 20,
      );
      when(() => datasource.registrarPago(any()))
          .thenAnswer((_) async => _pagoModel());

      final pago = await repository.registrarPago(draft);

      expect(pago, pagoFixture());
      final request =
          verify(() => datasource.registrarPago(captureAny())).captured.single
              as PagoRequest;
      expect(request.toJson(), {
        'idFactura': 7,
        'metodoPago': 'EFECTIVO',
        'monto': 20.0,
      });
    });

    test('maps network failures to NetworkException', () async {
      when(() => datasource.registrarPago(any()))
          .thenThrow(connectionFailure());

      await expectLater(
        repository.registrarPago(
          const PagoDraft(
            idFactura: 7,
            metodoPago: MetodoPago.tarjeta,
            monto: 1,
          ),
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getPagosByFactura', () {
    test('maps every payment', () async {
      when(() => datasource.getPagosByFactura(7))
          .thenAnswer((_) async => [_pagoModel(), _pagoModel(id: 10)]);

      final pagos = await repository.getPagosByFactura(7);

      expect(pagos, [pagoFixture(), pagoFixture(id: 10)]);
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.getPagosByFactura(99)).thenThrow(httpError(404));

      await expectLater(
        repository.getPagosByFactura(99),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
