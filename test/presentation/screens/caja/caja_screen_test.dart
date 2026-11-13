import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/caja_screen.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockCajaCubit extends MockCubit<CajaState> implements CajaCubit {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockFacturaRepository extends Mock implements FacturaRepository {}

class _FixedRandom implements Random {
  @override
  int nextInt(int max) => 123456;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

DetallePedido _linea({String nombre = 'Lomo saltado', int cantidad = 2}) =>
    DetallePedido(
      idPlato: 1,
      nombrePlato: nombre,
      cantidad: cantidad,
      precioUnitario: 10,
      subtotal: 10.0 * cantidad,
      estado: EstadoDetallePedido.values.first,
    );

Pedido _pedido(int id, {TipoPedido tipo = TipoPedido.salon}) => Pedido(
  id: id,
  estado: EstadoPedido.servido,
  tipo: tipo,
  numeroMesa: 3,
  fechaApertura: DateTime(2026, 11, 13, 9, 5),
  detalles: [_linea()],
);

Factura _factura(int id, {double total = 23}) => Factura(
  id: id,
  idPedido: 1,
  razonSocialCliente: 'Consumidor Final',
  numeroSecuencial: '001-001-000555555',
  subtotal: 20,
  subtotalIva: 3,
  propina: 0,
  total: total,
  estado: EstadoFactura.values.first,
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  scaffoldMessengerKey: NotificationsService.messengerKey,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const FacturaDraft(idPedido: 0, idCliente: '', numeroSecuencial: ''),
    );
    registerFallbackValue(
      const PagoDraft(idFactura: 0, metodoPago: MetodoPago.efectivo, monto: 0),
    );
  });

  group('view', () {
    late _MockCajaCubit cubit;

    setUp(() {
      cubit = _MockCajaCubit();
      when(() => cubit.load()).thenAnswer((_) async {});
    });

    Future<void> pumpView(
      WidgetTester tester,
      CajaState state, {
      Size size = TestScreens.tabletLandscape,
    }) async {
      when(() => cubit.state).thenReturn(state);
      await tester.pumpApp(
        BlocProvider<CajaCubit>.value(value: cubit, child: const CajaView()),
        size: size,
      );
    }

    testWidgets('shows the header, the count and reloads on Actualizar', (
      tester,
    ) async {
      await pumpView(tester, CajaState(pedidos: [_pedido(1), _pedido(2)]));

      expect(find.text('Módulo de Caja & Facturación'), findsOneWidget);
      expect(
        find.text(
          'Emisión de facturas electrónicas autorizadas y recaudación de pagos (Efectivo, Tarjeta, Transferencia)',
        ),
        findsOneWidget,
      );
      expect(find.text('Comandas Listas para Facturar (2)'), findsOneWidget);

      await tester.tap(find.text('Actualizar'));

      verify(() => cubit.load()).called(1);
    });

    testWidgets('shows the loading text while loading', (tester) async {
      await pumpView(tester, const CajaState(loading: true));

      expect(find.text('Cargando comandas pendientes...'), findsOneWidget);
    });

    testWidgets('shows both empty states', (tester) async {
      await pumpView(tester, const CajaState());

      expect(find.text('No hay comandas pendientes de cobro'), findsOneWidget);
      expect(
        find.text(
          'Los pedidos aparecerán aquí cuando estén marcados como Servidos o Para Llevar.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('No hay facturas emitidas recientemente.'),
        findsOneWidget,
      );
      expect(find.text('Facturas Recientes'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets('an order card shows the table, lines and the action', (
      tester,
    ) async {
      await pumpView(tester, CajaState(pedidos: [_pedido(7)]));

      expect(find.text('Pedido #7'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('Mesa 3'), findsOneWidget);
      expect(find.text('2x Lomo saltado'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);
      expect(find.text('Facturar y Cobrar'), findsOneWidget);
    });

    testWidgets('a take-away order shows Llevar', (tester) async {
      await pumpView(
        tester,
        CajaState(pedidos: [_pedido(7, tipo: TipoPedido.llevar)]),
      );

      expect(find.text('Llevar'), findsOneWidget);
      expect(find.text('Mesa 3'), findsNothing);
    });

    testWidgets('a recent invoice shows its number, client and total', (
      tester,
    ) async {
      await pumpView(tester, CajaState(facturas: [_factura(4)]));

      expect(find.text('001-001-000555555'), findsOneWidget);
      expect(find.text('Consumidor Final'), findsOneWidget);
      expect(find.text('\$23.00'), findsOneWidget);
      expect(find.text('+ Registrar Pago'), findsOneWidget);
    });

    testWidgets('a wide screen puts the invoices beside the orders', (
      tester,
    ) async {
      await pumpView(
        tester,
        CajaState(pedidos: [_pedido(1)], facturas: [_factura(4)]),
      );

      final pedido = tester.getTopLeft(find.text('Pedido #1'));
      final facturas = tester.getTopLeft(find.text('Facturas Recientes'));
      expect(facturas.dx, greaterThan(pedido.dx));
      expect(facturas.dy, lessThan(pedido.dy));
    });

    testWidgets('a phone stacks the invoices below the orders', (tester) async {
      await pumpView(
        tester,
        CajaState(pedidos: [_pedido(1)], facturas: [_factura(4)]),
        size: TestScreens.phone,
      );

      final pedido = tester.getTopLeft(find.text('Pedido #1'));
      final facturas = tester.getTopLeft(find.text('Facturas Recientes'));
      expect(facturas.dy, greaterThan(pedido.dy));
    });

    testWidgets('messages are shown as notifications', (tester) async {
      tester.setScreenSize(TestScreens.tabletLandscape);
      whenListen(
        cubit,
        Stream.fromIterable([
          const CajaState(message: CajaMessage(1, 'Error', isError: true)),
          const CajaState(message: CajaMessage(2, 'Listo')),
        ]),
        initialState: const CajaState(),
      );

      await tester.pumpWidget(
        _app(
          BlocProvider<CajaCubit>.value(value: cubit, child: const CajaView()),
        ),
      );
      await tester.pump();

      expect(find.text('Listo'), findsOneWidget);
    });
  });

  group('billing flow', () {
    late _MockPedidoRepository pedidos;
    late _MockFacturaRepository facturas;
    late CajaCubit cubit;

    setUp(() {
      pedidos = _MockPedidoRepository();
      facturas = _MockFacturaRepository();
      when(
        () => pedidos.getPedidos(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => PageResult.single([_pedido(1)]));
      when(
        () => facturas.getFacturas(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => PageResult.single(const []));
      cubit = CajaCubit(
        pedidoRepository: pedidos,
        facturaRepository: facturas,
        random: _FixedRandom(),
      );
    });

    tearDown(() => cubit.close());

    Future<void> pumpFlow(WidgetTester tester) async {
      tester.setScreenSize(TestScreens.tabletLandscape);
      await cubit.load();
      await tester.pumpWidget(
        _app(
          BlocProvider<CajaCubit>.value(value: cubit, child: const CajaView()),
        ),
      );
      await tester.tap(find.text('Facturar y Cobrar'));
      await tester.pumpAndSettle();
    }

    testWidgets('the invoice modal shows the suggested number and totals', (
      tester,
    ) async {
      await pumpFlow(tester);

      expect(find.text('Emitir Factura - Pedido #1'), findsOneWidget);
      expect(
        find.text('Número Secuencial de Factura *', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('001-001-000223456'), findsOneWidget);
      expect(find.text('Propina Sugerida (\$)'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('IVA (15%)'), findsOneWidget);
      expect(find.text('\$3.00'), findsOneWidget);
      expect(find.text('Propina'), findsNothing);
      expect(find.text('Total a Facturar'), findsOneWidget);
      expect(find.text('\$23.00'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('caja.propina')), '2');
      await tester.pump();

      expect(find.text('Propina'), findsOneWidget);
      expect(find.text('\$2.00'), findsOneWidget);
      expect(find.text('\$25.00'), findsOneWidget);
    });

    testWidgets('cancel closes the invoice modal and clears the form', (
      tester,
    ) async {
      await pumpFlow(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Emitir Factura - Pedido #1'), findsNothing);
      expect(cubit.state.facturar, isNull);
    });

    testWidgets('confirming emits the invoice, then the payment modal '
        'registers the payment and reports success', (tester) async {
      when(() => facturas.emitirFactura(any()))
          .thenAnswer((_) async => _factura(4, total: 25));
      when(() => facturas.registrarPago(any())).thenAnswer(
        (_) async => const Pago(
          id: 1,
          idFactura: 4,
          metodoPago: MetodoPago.tarjeta,
          monto: 25,
        ),
      );
      await pumpFlow(tester);

      await tester.tap(find.text('Confirmar Factura'));
      await tester.pumpAndSettle();

      expect(find.text('Emitir Factura - Pedido #1'), findsNothing);
      expect(
        find.text('Registrar Pago - Factura 001-001-000555555'),
        findsOneWidget,
      );
      expect(find.text('Método de Pago *', findRichText: true), findsOneWidget);
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('25.00'), findsOneWidget);
      expect(find.text('Referencia de Transacción (opcional)'), findsOneWidget);

      await tester.tap(find.text('Efectivo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tarjeta de Débito / Crédito').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('caja.referencia')),
        'Lote 45892',
      );
      await tester.tap(find.text('Finalizar Pago'));
      await tester.pumpAndSettle();

      verify(
        () => facturas.registrarPago(
          const PagoDraft(
            idFactura: 4,
            metodoPago: MetodoPago.tarjeta,
            monto: 25,
            referenciaTransaccion: 'Lote 45892',
          ),
        ),
      ).called(1);
      expect(
        find.text('Registrar Pago - Factura 001-001-000555555'),
        findsNothing,
      );
      expect(
        find.text('¡Pago de \$25.00 registrado exitosamente!'),
        findsOneWidget,
      );
    });

    testWidgets('an invoice error keeps the modal open and notifies', (
      tester,
    ) async {
      when(() => facturas.emitirFactura(any()))
          .thenThrow(const BadRequestException('Secuencial duplicado'));
      await pumpFlow(tester);

      await tester.tap(find.text('Confirmar Factura'));
      await tester.pumpAndSettle();

      expect(find.text('Emitir Factura - Pedido #1'), findsOneWidget);
      expect(find.text('Secuencial duplicado'), findsOneWidget);
    });

    testWidgets('Registrar Pago on a recent invoice opens its payment', (
      tester,
    ) async {
      when(
        () => facturas.getFacturas(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => PageResult.single([_factura(4)]));
      tester.setScreenSize(TestScreens.tabletLandscape);
      await cubit.load();
      await tester.pumpWidget(
        _app(
          BlocProvider<CajaCubit>.value(value: cubit, child: const CajaView()),
        ),
      );

      await tester.tap(find.text('+ Registrar Pago'));
      await tester.pumpAndSettle();
      expect(
        find.text('Registrar Pago - Factura 001-001-000555555'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(cubit.state.pago, isNull);
    });
  });
}
