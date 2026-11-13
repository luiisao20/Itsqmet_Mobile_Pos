import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_factura_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

Map<String, dynamic> _facturaJson({int id = 7, Object? total = '20.00'}) => {
  'id': id,
  'idPedido': 50,
  'idCliente': 'c-1',
  'razonSocialCliente': 'Juan Cliente',
  'numeroSecuencial': '001-001-000000007',
  'fechaEmision': '2026-05-01T13:00:00Z',
  'subtotal': 17,
  'subtotalIva': 2.55,
  'propina': 0.45,
  'total': total,
  'estado': 'EMITIDA',
};

Map<String, dynamic> _pagoJson({int id = 9, String metodo = 'EFECTIVO'}) => {
  'id': id,
  'idFactura': 7,
  'numeroSecuencialFactura': '001-001-000000007',
  'metodoPago': metodo,
  'monto': 20,
  'fechaPago': DateTime.utc(2026, 5, 1, 13, 5).millisecondsSinceEpoch,
};

void main() {
  late MockDio dio;
  late ApiFacturaDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiFacturaDatasource(dio);
  });

  group('getFacturas', () {
    test('GETs /facturas with page and size and parses the Page', () async {
      when(
        () => dio.get<dynamic>(
          '/facturas',
          queryParameters: {'page': 1, 'size': 25},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_facturaJson()])));

      final page = await datasource.getFacturas(page: 1, size: 25);

      final factura = page.content.single;
      expect(factura.id, 7);
      expect(factura.total, 20);
      expect(factura.estado, EstadoFactura.emitida);
      expect(factura.fechaEmision?.toUtc(), DateTime.utc(2026, 5, 1, 13));
    });

    test('sends the default page 0 / size 10', () async {
      when(
        () => dio.get<dynamic>(
          '/facturas',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => okResponse(pageJson([])));

      await datasource.getFacturas();

      verify(
        () => dio.get<dynamic>(
          '/facturas',
          queryParameters: {'page': 0, 'size': 10},
        ),
      ).called(1);
    });

    test('lets DioException propagate', () async {
      when(
        () => dio.get<dynamic>(
          '/facturas',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(datasource.getFacturas(), throwsA(isA<DioException>()));
    });
  });

  group('getFactura', () {
    test('GETs /facturas/{id}', () async {
      when(() => dio.get<dynamic>('/facturas/7'))
          .thenAnswer((_) async => okResponse(_facturaJson()));

      final factura = await datasource.getFactura(7);

      expect(factura.numeroSecuencial, '001-001-000000007');
    });
  });

  group('getMisFacturas', () {
    test('GETs /facturas/mis-facturas with page and size', () async {
      when(
        () => dio.get<dynamic>(
          '/facturas/mis-facturas',
          queryParameters: {'page': 0, 'size': 50},
        ),
      ).thenAnswer(
        (_) async =>
            okResponse(pageJson([_facturaJson(), _facturaJson(id: 8)])),
      );

      final page = await datasource.getMisFacturas();

      expect(page.content.map((f) => f.id), [7, 8]);
    });
  });

  group('emitirFactura', () {
    test('POSTs /facturas with the request body', () async {
      const request = FacturaRequest(
        idPedido: 50,
        idCliente: 'c-1',
        numeroSecuencial: '001-001-000000007',
        propina: 0.45,
      );
      when(() => dio.post<dynamic>('/facturas', data: any(named: 'data')))
          .thenAnswer((_) async => okResponse(_facturaJson(), status: 201));

      final factura = await datasource.emitirFactura(request);

      expect(factura.id, 7);
      verify(
        () => dio.post<dynamic>(
          '/facturas',
          data: {
            'idPedido': 50,
            'idCliente': 'c-1',
            'numeroSecuencial': '001-001-000000007',
            'propina': 0.45,
          },
        ),
      ).called(1);
    });
  });

  group('registrarPago', () {
    test('POSTs /pagos with the request body', () async {
      const request = PagoRequest(
        idFactura: 7,
        metodoPago: MetodoPago.tarjeta,
        monto: 20,
        referenciaTransaccion: 'TX-1',
      );
      when(() => dio.post<dynamic>('/pagos', data: any(named: 'data')))
          .thenAnswer(
            (_) async => okResponse(_pagoJson(metodo: 'TARJETA'), status: 201),
          );

      final pago = await datasource.registrarPago(request);

      expect(pago.metodoPago, MetodoPago.tarjeta);
      expect(pago.fechaPago?.toUtc(), DateTime.utc(2026, 5, 1, 13, 5));
      verify(
        () => dio.post<dynamic>(
          '/pagos',
          data: {
            'idFactura': 7,
            'metodoPago': 'TARJETA',
            'monto': 20.0,
            'referenciaTransaccion': 'TX-1',
          },
        ),
      ).called(1);
    });
  });

  group('getPagosByFactura', () {
    test(
      'GETs /pagos/factura/{id} with size 100 and unwraps the Page content',
      () async {
        when(
          () => dio.get<dynamic>(
            '/pagos/factura/7',
            queryParameters: {'page': 0, 'size': 100},
          ),
        ).thenAnswer(
          (_) async => okResponse(pageJson([_pagoJson(), _pagoJson(id: 10)])),
        );

        final pagos = await datasource.getPagosByFactura(7);

        expect(pagos.map((p) => p.id), [9, 10]);
        expect(pagos.first.idFactura, 7);
      },
    );

    test('accepts a plain array response', () async {
      when(
        () => dio.get<dynamic>(
          '/pagos/factura/7',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse([_pagoJson()]));

      final pagos = await datasource.getPagosByFactura(7);

      expect(pagos.single.id, 9);
    });
  });
}
