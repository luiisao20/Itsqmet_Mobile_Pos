import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:mocktail/mocktail.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockFacturaRepository extends Mock implements FacturaRepository {}

class _FixedRandom implements Random {
  _FixedRandom(this.value);

  final int value;
  int? lastMax;

  @override
  int nextInt(int max) {
    lastMax = max;
    return value;
  }

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

DetallePedido _linea(double subtotal) => DetallePedido(
  idPlato: 1,
  nombrePlato: 'Ceviche',
  cantidad: 1,
  precioUnitario: subtotal,
  subtotal: subtotal,
  estado: EstadoDetallePedido.values.first,
);

Pedido _pedido(
  int id,
  EstadoPedido estado, {
  TipoPedido tipo = TipoPedido.salon,
  String? idCliente,
  List<DetallePedido>? detalles,
}) => Pedido(
  id: id,
  estado: estado,
  tipo: tipo,
  numeroMesa: 3,
  idCliente: idCliente,
  detalles: detalles ?? [_linea(10)],
);

Factura _factura(int id, {double total = 23, String secuencial = '001'}) =>
    Factura(
      id: id,
      idPedido: 1,
      numeroSecuencial: secuencial,
      subtotal: 20,
      subtotalIva: 3,
      propina: 0,
      total: total,
      estado: EstadoFactura.values.first,
    );

void main() {
  late _MockPedidoRepository pedidos;
  late _MockFacturaRepository facturas;
  late _FixedRandom random;

  CajaCubit build() => CajaCubit(
    pedidoRepository: pedidos,
    facturaRepository: facturas,
    random: random,
  );

  setUpAll(() {
    registerFallbackValue(
      const FacturaDraft(idPedido: 0, idCliente: '', numeroSecuencial: ''),
    );
    registerFallbackValue(
      const PagoDraft(idFactura: 0, metodoPago: MetodoPago.efectivo, monto: 0),
    );
  });

  setUp(() {
    pedidos = _MockPedidoRepository();
    facturas = _MockFacturaRepository();
    random = _FixedRandom(123456);
    when(
      () => pedidos.getPedidos(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single(const []));
    when(
      () => facturas.getFacturas(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single(const []));
  });

  group('load', () {
    test('keeps served orders and open take-away orders', () async {
      when(() => pedidos.getPedidos(page: 0, size: 50)).thenAnswer(
        (_) async => PageResult.single([
          _pedido(1, EstadoPedido.servido),
          _pedido(2, EstadoPedido.abierto),
          _pedido(3, EstadoPedido.abierto, tipo: TipoPedido.llevar),
          _pedido(4, EstadoPedido.facturado, tipo: TipoPedido.llevar),
          _pedido(5, EstadoPedido.anulado, tipo: TipoPedido.llevar),
          _pedido(6, EstadoPedido.enPreparacion, tipo: TipoPedido.llevar),
          _pedido(7, EstadoPedido.facturado),
        ]),
      );
      final cubit = build();

      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.pedidos.map((p) => p.id), [1, 3, 6]);
      await cubit.close();
    });

    test('loads the 10 most recent invoices', () async {
      when(() => facturas.getFacturas(page: 0, size: 10))
          .thenAnswer((_) async => PageResult.single([_factura(9)]));
      final cubit = build();

      await cubit.load();

      expect(cubit.state.facturas, [_factura(9)]);
      verify(() => facturas.getFacturas(page: 0, size: 10)).called(1);
      await cubit.close();
    });

    test('is loading while the orders request is pending', () async {
      final completer = Completer<PageResult<Pedido>>();
      when(() => pedidos.getPedidos(page: 0, size: 50))
          .thenAnswer((_) => completer.future);
      final cubit = build();

      final future = cubit.load();
      expect(cubit.state.loading, isTrue);

      completer.complete(PageResult.single(const []));
      await future;
      expect(cubit.state.loading, isFalse);
      await cubit.close();
    });

    test('an orders error ends loading and keeps the invoices', () async {
      when(() => pedidos.getPedidos(page: 0, size: 50))
          .thenThrow(const ServerException());
      when(() => facturas.getFacturas(page: 0, size: 10))
          .thenAnswer((_) async => PageResult.single([_factura(9)]));
      final cubit = build();

      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.pedidos, isEmpty);
      expect(cubit.state.facturas, [_factura(9)]);
      expect(cubit.state.message, isNull);
      await cubit.close();
    });

    test('an invoices error is ignored', () async {
      when(() => pedidos.getPedidos(page: 0, size: 50)).thenAnswer(
        (_) async => PageResult.single([_pedido(1, EstadoPedido.servido)]),
      );
      when(() => facturas.getFacturas(page: 0, size: 10))
          .thenThrow(const NetworkException());
      final cubit = build();

      await cubit.load();

      expect(cubit.state.pedidos.map((p) => p.id), [1]);
      expect(cubit.state.facturas, isEmpty);
      expect(cubit.state.message, isNull);
      await cubit.close();
    });
  });

  group('facturar', () {
    test('opening suggests a sequential number and zero tip', () async {
      final cubit = build();
      final pedido = _pedido(1, EstadoPedido.servido);

      cubit.openFacturar(pedido);

      final form = cubit.state.facturar!;
      expect(form.pedido, pedido);
      expect(form.numeroSecuencial, '001-001-000223456');
      expect(form.propina, 0);
      expect(form.submitting, isFalse);
      expect(random.lastMax, 900000);
      await cubit.close();
    });

    test('totals add 15% IVA and the tip, rounded to cents', () async {
      final cubit = build()
        ..openFacturar(
          _pedido(
            1,
            EstadoPedido.servido,
            detalles: [_linea(10.33), _linea(5.5)],
          ),
        )
        ..changePropina('2.5');

      final totals = cubit.state.facturar!.totals;
      expect(totals.subtotal, closeTo(15.83, 1e-9));
      expect(totals.iva, 2.37);
      expect(totals.propina, 2.5);
      expect(totals.total, 20.7);
      await cubit.close();
    });

    test('an invalid or empty tip counts as zero', () async {
      final cubit = build()
        ..openFacturar(_pedido(1, EstadoPedido.servido))
        ..changePropina('abc');
      expect(cubit.state.facturar!.propina, 0);

      cubit.changePropina('1,5');
      expect(cubit.state.facturar!.propina, 1.5);

      cubit.changePropina('');
      expect(cubit.state.facturar!.propina, 0);
      await cubit.close();
    });

    test('cancel closes the form', () async {
      final cubit = build()
        ..openFacturar(_pedido(1, EstadoPedido.servido))
        ..cancelFacturar();

      expect(cubit.state.facturar, isNull);
      await cubit.close();
    });

    test('emits the invoice with the order client, trimmed number and tip, '
        'then opens the payment for it and reloads', () async {
      final factura = _factura(40, total: 14.8);
      when(() => facturas.emitirFactura(any()))
          .thenAnswer((_) async => factura);
      final cubit = build()
        ..openFacturar(_pedido(1, EstadoPedido.servido, idCliente: 'cliente-1'))
        ..changeNumeroSecuencial('  001-001-000999  ')
        ..changePropina('2');

      final ok = await cubit.emitirFactura();

      expect(ok, isTrue);
      verify(
        () => facturas.emitirFactura(
          const FacturaDraft(
            idPedido: 1,
            idCliente: 'cliente-1',
            numeroSecuencial: '001-001-000999',
            propina: 2,
          ),
        ),
      ).called(1);
      expect(cubit.state.facturar, isNull);
      final pago = cubit.state.pago!;
      expect(pago.factura, factura);
      expect(pago.metodoPago, MetodoPago.efectivo);
      expect(pago.monto, 14.8);
      expect(pago.referencia, '');
      verify(() => pedidos.getPedidos(page: 0, size: 50)).called(1);
      await cubit.close();
    });

    test('an order without client uses the default client', () async {
      when(() => facturas.emitirFactura(any()))
          .thenAnswer((_) async => _factura(40));
      final cubit = build()..openFacturar(_pedido(1, EstadoPedido.servido));

      await cubit.emitirFactura();

      final draft =
          verify(() => facturas.emitirFactura(captureAny())).captured.single
              as FacturaDraft;
      expect(draft.idCliente, CajaCubit.defaultClienteId);
      expect(draft.idCliente, '9960cfbb-50ec-4caa-bad3-1c0fb0b2a43e');
      expect(draft.propina, 0);
      await cubit.close();
    });

    test('an empty client id also uses the default client', () async {
      when(() => facturas.emitirFactura(any()))
          .thenAnswer((_) async => _factura(40));
      final cubit = build()
        ..openFacturar(_pedido(1, EstadoPedido.servido, idCliente: ''));

      await cubit.emitirFactura();

      final draft =
          verify(() => facturas.emitirFactura(captureAny())).captured.single
              as FacturaDraft;
      expect(draft.idCliente, CajaCubit.defaultClienteId);
      await cubit.close();
    });

    test('is submitting while the request is pending', () async {
      final completer = Completer<Factura>();
      when(() => facturas.emitirFactura(any()))
          .thenAnswer((_) => completer.future);
      final cubit = build()..openFacturar(_pedido(1, EstadoPedido.servido));

      final future = cubit.emitirFactura();
      expect(cubit.state.facturar!.submitting, isTrue);
      expect(await cubit.emitirFactura(), isFalse);

      completer.complete(_factura(40));
      await future;
      verify(() => facturas.emitirFactura(any())).called(1);
      await cubit.close();
    });

    test(
      'an error keeps the form open and reports the backend message',
      () async {
        when(() => facturas.emitirFactura(any()))
            .thenThrow(const BadRequestException('Secuencial duplicado'));
        final cubit = build()..openFacturar(_pedido(1, EstadoPedido.servido));

        final ok = await cubit.emitirFactura();

        expect(ok, isFalse);
        expect(cubit.state.facturar!.submitting, isFalse);
        expect(cubit.state.pago, isNull);
        expect(cubit.state.message!.text, 'Secuencial duplicado');
        expect(cubit.state.message!.isError, isTrue);
        await cubit.close();
      },
    );

    test('an error without message uses the fallback', () async {
      when(() => facturas.emitirFactura(any()))
          .thenThrow(const BadRequestException(' '));
      final cubit = build()..openFacturar(_pedido(1, EstadoPedido.servido));

      await cubit.emitirFactura();

      expect(cubit.state.message!.text, 'Error al emitir factura');
      await cubit.close();
    });

    test('emitting without an open form does nothing', () async {
      final cubit = build();

      expect(await cubit.emitirFactura(), isFalse);
      verifyNever(() => facturas.emitirFactura(any()));
      await cubit.close();
    });
  });

  group('pago', () {
    test('opening prefills the invoice total with cash', () async {
      final cubit = build()..openPago(_factura(5, total: 31.25));

      final form = cubit.state.pago!;
      expect(form.factura.id, 5);
      expect(form.metodoPago, MetodoPago.efectivo);
      expect(form.monto, 31.25);
      expect(form.referencia, '');
      await cubit.close();
    });

    test('registers the payment with the chosen method, amount and '
        'trimmed reference, then reports success and reloads', () async {
      when(() => facturas.registrarPago(any())).thenAnswer(
        (_) async => const Pago(
          id: 1,
          idFactura: 5,
          metodoPago: MetodoPago.tarjeta,
          monto: 30,
        ),
      );
      final cubit = build()
        ..openPago(_factura(5, total: 31.25))
        ..changeMetodoPago(MetodoPago.tarjeta)
        ..changeMonto('30')
        ..changeReferencia('  Lote 45892  ');

      final ok = await cubit.registrarPago();

      expect(ok, isTrue);
      verify(
        () => facturas.registrarPago(
          const PagoDraft(
            idFactura: 5,
            metodoPago: MetodoPago.tarjeta,
            monto: 30,
            referenciaTransaccion: 'Lote 45892',
          ),
        ),
      ).called(1);
      expect(cubit.state.pago, isNull);
      expect(
        cubit.state.message!.text,
        '¡Pago de \$31.25 registrado exitosamente!',
      );
      expect(cubit.state.message!.isError, isFalse);
      verify(() => pedidos.getPedidos(page: 0, size: 50)).called(1);
      await cubit.close();
    });

    test('an empty reference is omitted', () async {
      when(() => facturas.registrarPago(any())).thenAnswer(
        (_) async => const Pago(
          id: 1,
          idFactura: 5,
          metodoPago: MetodoPago.efectivo,
          monto: 23,
        ),
      );
      final cubit = build()
        ..openPago(_factura(5))
        ..changeReferencia('   ');

      await cubit.registrarPago();

      final draft =
          verify(() => facturas.registrarPago(captureAny())).captured.single
              as PagoDraft;
      expect(draft.referenciaTransaccion, isNull);
      expect(draft.monto, 23);
      await cubit.close();
    });

    test('an invalid amount counts as zero', () async {
      final cubit = build()
        ..openPago(_factura(5))
        ..changeMonto('x');

      expect(cubit.state.pago!.monto, 0);
      await cubit.close();
    });

    test('is submitting while the request is pending', () async {
      final completer = Completer<Pago>();
      when(() => facturas.registrarPago(any()))
          .thenAnswer((_) => completer.future);
      final cubit = build()..openPago(_factura(5));

      final future = cubit.registrarPago();
      expect(cubit.state.pago!.submitting, isTrue);
      expect(await cubit.registrarPago(), isFalse);

      completer.complete(
        const Pago(
          id: 1,
          idFactura: 5,
          metodoPago: MetodoPago.efectivo,
          monto: 23,
        ),
      );
      await future;
      verify(() => facturas.registrarPago(any())).called(1);
      await cubit.close();
    });

    test('an error keeps the form open and reports the message', () async {
      when(() => facturas.registrarPago(any()))
          .thenThrow(const ValidationException('Monto insuficiente'));
      final cubit = build()..openPago(_factura(5));

      final ok = await cubit.registrarPago();

      expect(ok, isFalse);
      expect(cubit.state.pago!.submitting, isFalse);
      expect(cubit.state.message!.text, 'Monto insuficiente');
      expect(cubit.state.message!.isError, isTrue);
      await cubit.close();
    });

    test('an error without message uses the fallback', () async {
      when(() => facturas.registrarPago(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build()..openPago(_factura(5));

      await cubit.registrarPago();

      expect(cubit.state.message!.text, 'Error al registrar el pago');
      await cubit.close();
    });

    test('cancel closes the form', () async {
      final cubit = build()
        ..openPago(_factura(5))
        ..cancelPago();

      expect(cubit.state.pago, isNull);
      await cubit.close();
    });

    test(
      'every message gets a new id so equal texts are shown again',
      () async {
        when(() => facturas.registrarPago(any()))
            .thenThrow(const BadRequestException('Error'));
        final cubit = build()..openPago(_factura(5));

        await cubit.registrarPago();
        final first = cubit.state.message!;
        await cubit.registrarPago();

        expect(cubit.state.message, isNot(first));
        await cubit.close();
      },
    );
  });

  test('a closed cubit ignores late responses', () async {
    final completer = Completer<PageResult<Pedido>>();
    when(() => pedidos.getPedidos(page: 0, size: 50))
        .thenAnswer((_) => completer.future);
    final cubit = build();

    final future = cubit.load();
    await cubit.close();
    completer.complete(PageResult.single([_pedido(1, EstadoPedido.servido)]));

    await expectLater(future, completes);
  });
}
