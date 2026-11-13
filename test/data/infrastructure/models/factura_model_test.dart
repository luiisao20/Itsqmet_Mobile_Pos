import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/factura_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pago_model.dart';

void main() {
  group('FacturaModel', () {
    test('parses a backend invoice', () {
      final model = FacturaModel.fromJson({
        'id': 7,
        'idPedido': 50,
        'idCliente': 'c-1',
        'razonSocialCliente': 'Juan Cliente',
        'identificacionCliente': '1712345678',
        'idUsuario': 'u-1',
        'nombreUsuario': 'Ana Pérez',
        'numeroSecuencial': '001-001-000000007',
        'claveAccesoSri': '1211202501179001234500110010010000000071234567813',
        'fechaEmision': 1731456000,
        'subtotal': 17,
        'subtotalIva': 2.55,
        'propina': 0.45,
        'total': 20.0,
        'estado': 'EMITIDA',
        'createdAt': '2025-11-12T10:30:00',
      });

      expect(model.id, 7);
      expect(model.idPedido, 50);
      expect(model.idCliente, 'c-1');
      expect(model.razonSocialCliente, 'Juan Cliente');
      expect(model.identificacionCliente, '1712345678');
      expect(model.numeroSecuencial, '001-001-000000007');
      expect(model.claveAccesoSri, startsWith('1211'));
      expect(model.fechaEmision!.millisecondsSinceEpoch, 1731456000000);
      expect(model.subtotal, 17);
      expect(model.subtotalIva, 2.55);
      expect(model.propina, 0.45);
      expect(model.total, 20);
      expect(model.estado, EstadoFactura.emitida);
    });

    test('accepts a numeric numeroSecuencial and an unknown state', () {
      final model = FacturaModel.fromJson({
        'id': 1,
        'numeroSecuencial': 12,
        'estado': 'RECHAZADA',
      });

      expect(model.numeroSecuencial, '12');
      expect(model.estado, EstadoFactura.emitida);
      expect(model.total, 0);
    });

    test('request omits null optionals', () {
      final request = FacturaRequest.fromDraft(
        const FacturaDraft(
          idPedido: 50,
          idCliente: 'c-1',
          numeroSecuencial: '001-001-000000008',
        ),
      );

      expect(request.toJson(), {
        'idPedido': 50,
        'idCliente': 'c-1',
        'numeroSecuencial': '001-001-000000008',
      });
    });

    test('request keeps access key and tip when present', () {
      final request = FacturaRequest.fromDraft(
        const FacturaDraft(
          idPedido: 50,
          idCliente: 'c-1',
          numeroSecuencial: '001-001-000000008',
          claveAccesoSri: 'ABC',
          propina: 1.5,
        ),
      );

      expect(request.toJson()['claveAccesoSri'], 'ABC');
      expect(request.toJson()['propina'], 1.5);
    });
  });

  group('PagoModel', () {
    test('parses a backend payment', () {
      final model = PagoModel.fromJson({
        'id': 9,
        'idFactura': 7,
        'numeroSecuencialFactura': '001-001-000000007',
        'metodoPago': 'TRANSFERENCIA',
        'monto': 20,
        'referenciaTransaccion': 'TX-123',
        'fechaPago': '2025-11-12T10:45:00',
      });

      expect(model.id, 9);
      expect(model.idFactura, 7);
      expect(model.numeroSecuencialFactura, '001-001-000000007');
      expect(model.metodoPago, MetodoPago.transferencia);
      expect(model.monto, 20.0);
      expect(model.referenciaTransaccion, 'TX-123');
      expect(model.fechaPago, DateTime(2025, 11, 12, 10, 45));
    });

    test('an unknown method falls back to EFECTIVO', () {
      expect(
        PagoModel.fromJson({'id': 1, 'metodoPago': 'CRIPTO'}).metodoPago,
        MetodoPago.efectivo,
      );
    });

    test('request omits a null reference', () {
      final request = PagoRequest.fromDraft(
        const PagoDraft(
          idFactura: 7,
          metodoPago: MetodoPago.tarjeta,
          monto: 20,
        ),
      );

      expect(request.toJson(), {
        'idFactura': 7,
        'metodoPago': 'TARJETA',
        'monto': 20.0,
      });
    });

    test('request keeps the reference when present', () {
      final request = PagoRequest.fromDraft(
        const PagoDraft(
          idFactura: 7,
          metodoPago: MetodoPago.transferencia,
          monto: 20,
          referenciaTransaccion: 'TX-1',
        ),
      );

      expect(request.toJson()['referenciaTransaccion'], 'TX-1');
    });
  });
}
