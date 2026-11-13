import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/detalle_pedido_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';

Map<String, dynamic> _pedidoJson() => {
  'id': 50,
  'idMesa': 3,
  'numeroMesa': 3,
  'idUsuario': 'u-1',
  'nombreUsuario': 'Ana Pérez',
  'idCliente': null,
  'razonSocialCliente': null,
  'fechaApertura': 1731456000.5,
  'fechaCierre': null,
  'estado': 'EN_PREPARACION',
  'tipo': 'SALON',
  'observaciones': 'Sin cebolla',
  'detalles': [
    {
      'id': 100,
      'idPlato': 10,
      'nombrePlato': 'Ceviche',
      'cantidad': 2,
      'precioUnitario': 8.5,
      'subtotal': 17.0,
      'notasPreparacion': 'Poco picante',
      'estado': 'PENDIENTE',
    },
    {
      'id': 101,
      'idPlato': 11,
      'nombrePlato': 'Jugo',
      'cantidad': 1,
      'precioUnitario': 2,
      'subtotal': 2,
      'estado': 'LISTO',
    },
  ],
  'createdAt': '2025-11-12T10:30:00',
};

void main() {
  group('DetallePedidoModel', () {
    test('parses a backend line', () {
      final model = DetallePedidoModel.fromJson({
        'id': 100,
        'idPedido': 50,
        'idPlato': 10,
        'nombrePlato': 'Ceviche',
        'cantidad': 2,
        'precioUnitario': 8.5,
        'subtotal': 17.0,
        'notasPreparacion': 'Poco picante',
        'estado': 'IMPRESO',
      });

      expect(model.id, 100);
      expect(model.idPedido, 50);
      expect(model.idPlato, 10);
      expect(model.nombrePlato, 'Ceviche');
      expect(model.cantidad, 2);
      expect(model.precioUnitario, 8.5);
      expect(model.subtotal, 17);
      expect(model.notasPreparacion, 'Poco picante');
      expect(model.estado, EstadoDetallePedido.impreso);
    });

    test('computes the subtotal when the backend omits it', () {
      final model = DetallePedidoModel.fromJson({
        'idPlato': 10,
        'nombrePlato': 'Ceviche',
        'cantidad': 3,
        'precioUnitario': 2.5,
      });

      expect(model.subtotal, 7.5);
      expect(model.id, isNull);
      expect(model.estado, EstadoDetallePedido.pendiente);
    });

    test('request omits null notes and keeps the wire fields', () {
      final request = DetallePedidoRequest.fromDraft(
        const DetallePedidoDraft(idPlato: 10, cantidad: 2),
      );

      expect(request.toJson(), {'idPlato': 10, 'cantidad': 2});
    });

    test('request keeps notes when present', () {
      final request = DetallePedidoRequest.fromDraft(
        const DetallePedidoDraft(
          idPlato: 10,
          cantidad: 2,
          notasPreparacion: 'Sin sal',
        ),
      );

      expect(request.toJson()['notasPreparacion'], 'Sin sal');
    });
  });

  group('PedidoModel', () {
    test('parses a backend order with its lines', () {
      final model = PedidoModel.fromJson(_pedidoJson());

      expect(model.id, 50);
      expect(model.idMesa, 3);
      expect(model.numeroMesa, 3);
      expect(model.idUsuario, 'u-1');
      expect(model.nombreUsuario, 'Ana Pérez');
      expect(model.idCliente, isNull);
      expect(model.fechaApertura!.millisecondsSinceEpoch, 1731456000500);
      expect(model.fechaCierre, isNull);
      expect(model.estado, EstadoPedido.enPreparacion);
      expect(model.tipo, TipoPedido.salon);
      expect(model.observaciones, 'Sin cebolla');
      expect(model.detalles, hasLength(2));
      expect(model.detalles.first.nombrePlato, 'Ceviche');
      expect(model.detalles.last.estado, EstadoDetallePedido.listo);
      expect(model.createdAt, DateTime(2025, 11, 12, 10, 30));
    });

    test('missing detalles become an empty list', () {
      final json = _pedidoJson()..remove('detalles');

      expect(PedidoModel.fromJson(json).detalles, isEmpty);
    });

    test('unknown enums fall back to ABIERTO / SALON', () {
      final json = _pedidoJson()
        ..['estado'] = 'EN_CAMINO'
        ..['tipo'] = 'DOMICILIO';

      final model = PedidoModel.fromJson(json);

      expect(model.estado, EstadoPedido.abierto);
      expect(model.tipo, TipoPedido.salon);
    });

    test('a take-away order has no table', () {
      final json = _pedidoJson()
        ..['idMesa'] = null
        ..['numeroMesa'] = null
        ..['tipo'] = 'LLEVAR';

      final model = PedidoModel.fromJson(json);

      expect(model.idMesa, isNull);
      expect(model.tipo, TipoPedido.llevar);
    });
  });

  group('PedidoRequest', () {
    test('serializes lines and omits null optionals', () {
      final request = PedidoRequest.fromDraft(
        const PedidoDraft(
          idMesa: 3,
          tipo: TipoPedido.salon,
          detalles: [
            DetallePedidoDraft(idPlato: 10, cantidad: 2),
            DetallePedidoDraft(
              idPlato: 11,
              cantidad: 1,
              notasPreparacion: 'Sin hielo',
            ),
          ],
        ),
      );

      expect(request.toJson(), {
        'idMesa': 3,
        'tipo': 'SALON',
        'detalles': [
          {'idPlato': 10, 'cantidad': 2},
          {'idPlato': 11, 'cantidad': 1, 'notasPreparacion': 'Sin hielo'},
        ],
      });
    });

    test('keeps client and observations when present', () {
      final request = PedidoRequest.fromDraft(
        const PedidoDraft(
          idCliente: 'c-1',
          tipo: TipoPedido.llevar,
          observaciones: 'Para las 8pm',
          detalles: [],
        ),
      );

      expect(request.toJson(), {
        'idCliente': 'c-1',
        'tipo': 'LLEVAR',
        'observaciones': 'Para las 8pm',
        'detalles': <Object?>[],
      });
    });
  });

  group('PedidoClienteRequest', () {
    test('has no table, client or type', () {
      final request = PedidoClienteRequest.fromDraft(
        const PedidoClienteDraft(
          detalles: [DetallePedidoDraft(idPlato: 10, cantidad: 1)],
        ),
      );

      expect(request.toJson(), {
        'detalles': [
          {'idPlato': 10, 'cantidad': 1},
        ],
      });
    });

    test('keeps observations when present', () {
      final request = PedidoClienteRequest.fromDraft(
        const PedidoClienteDraft(observaciones: 'Sin picante', detalles: []),
      );

      expect(request.toJson()['observaciones'], 'Sin picante');
    });
  });
}
