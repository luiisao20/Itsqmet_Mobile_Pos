import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/cliente_pedidos_screen.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockCubit extends MockCubit<ClientePedidosState>
    implements ClientePedidosCubit {}

Plato _plato(int id, String nombre) => Plato(
  id: id,
  idCategoria: 1,
  nombre: nombre,
  precioUnitario: 4.5,
  aplicaIva: true,
  disponible: true,
);

const _categoria = CategoriaPlato(
  id: 3,
  nombre: 'Bebidas',
  areaImpresion: AreaImpresion.bar,
);

Pedido _pedido(
  int id, {
  String? observaciones,
  String? notas,
  EstadoPedido estado = EstadoPedido.enPreparacion,
}) => Pedido(
  id: id,
  estado: estado,
  tipo: TipoPedido.llevar,
  observaciones: observaciones,
  fechaApertura: DateTime(2026, 11, 13, 9, 5),
  detalles: [
    DetallePedido(
      idPlato: 1,
      nombrePlato: 'Ceviche',
      cantidad: 2,
      precioUnitario: 8.5,
      subtotal: 17,
      notasPreparacion: notas,
      estado: EstadoDetallePedido.values.first,
    ),
  ],
);

Factura _factura() => Factura(
  id: 1,
  idPedido: 1,
  numeroSecuencial: '001-001-000123456',
  fechaEmision: DateTime(2026, 11, 13, 9, 5),
  subtotal: 10,
  subtotalIva: 1.5,
  propina: 0,
  total: 11.5,
  estado: EstadoFactura.values.first,
);

void main() {
  late _MockCubit cubit;

  setUpAll(() {
    registerFallbackValue(ClienteTab.nuevo);
    registerFallbackValue(_plato(0, ''));
  });

  setUp(() {
    cubit = _MockCubit();
    when(() => cubit.changeTab(any())).thenAnswer((_) async {});
    when(() => cubit.filterCategoria(any())).thenAnswer((_) async {});
    when(() => cubit.submitOrder()).thenAnswer((_) async => true);
  });

  Future<void> pumpView(
    WidgetTester tester,
    ClientePedidosState state, {
    Size size = TestScreens.tabletLandscape,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<ClientePedidosCubit>.value(
        value: cubit,
        child: const ClientePedidosView(),
      ),
      size: size,
    );
  }

  group('header and tabs', () {
    testWidgets('shows the title, subtitle and the three tabs', (tester) async {
      await pumpView(tester, ClientePedidosState(misPedidos: [_pedido(1)]));

      expect(find.text('Panel de Pedidos & Facturas'), findsOneWidget);
      expect(
        find.text(
          'Arma tu pedido para llevar en tiempo real y consulta tu historial fiscal',
        ),
        findsOneWidget,
      );
      expect(find.text('Nuevo Pedido (Llevar)'), findsOneWidget);
      expect(find.text('Mis Pedidos'), findsOneWidget);
      expect(find.text('Mis Facturas'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping a tab changes it in the cubit', (tester) async {
      await pumpView(tester, const ClientePedidosState());

      await tester.tap(find.text('Mis Facturas'));

      verify(() => cubit.changeTab(ClienteTab.facturas)).called(1);
    });

    testWidgets('shows the success banner', (tester) async {
      await pumpView(
        tester,
        const ClientePedidosState(
          successMessage: '¡Pedido #42 enviado exitosamente a la cocina!',
        ),
      );

      expect(
        find.text('¡Pedido #42 enviado exitosamente a la cocina!'),
        findsOneWidget,
      );
    });

    testWidgets('an error is shown as a notification', (tester) async {
      tester.setScreenSize(TestScreens.tabletLandscape);
      whenListen(
        cubit,
        Stream.fromIterable([
          const ClientePedidosState(
            error: ClientePedidosError(1, 'Plato agotado'),
          ),
        ]),
        initialState: const ClientePedidosState(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          scaffoldMessengerKey: NotificationsService.messengerKey,
          home: Scaffold(
            body: BlocProvider<ClientePedidosCubit>.value(
              value: cubit,
              child: const ClientePedidosView(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Plato agotado'), findsOneWidget);
    });
  });

  group('nuevo pedido', () {
    ClientePedidosState nuevo({ShoppingCart cart = const ShoppingCart()}) =>
        ClientePedidosState(
          categorias: const [_categoria],
          platos: [_plato(1, 'Limonada'), _plato(2, 'Ceviche')],
          cart: cart,
        );

    testWidgets('shows the categories, dishes and the take-away summary', (
      tester,
    ) async {
      await pumpView(tester, nuevo());

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Bebidas'), findsOneWidget);
      expect(find.text('Limonada'), findsOneWidget);
      expect(find.text('Ceviche'), findsOneWidget);
      expect(find.text('Mi Pedido Para Llevar'), findsOneWidget);
    });

    testWidgets('a category pill filters the dishes', (tester) async {
      await pumpView(tester, nuevo());

      await tester.tap(find.text('Bebidas'));

      verify(() => cubit.filterCategoria(3)).called(1);
    });

    testWidgets('adding a dish puts it in the cart', (tester) async {
      await pumpView(tester, nuevo());

      await tester.tap(find.text('+ Agregar').first);

      verify(() => cubit.addPlato(_plato(1, 'Limonada'))).called(1);
    });

    testWidgets('the summary submits the order to the kitchen', (tester) async {
      await pumpView(
        tester,
        nuevo(cart: const ShoppingCart().add(_plato(1, 'Limonada'))),
      );

      final submit = find.text('Enviar Pedido a Cocina');
      await tester.ensureVisible(submit);
      await tester.tap(submit);

      verify(() => cubit.submitOrder()).called(1);
    });

    testWidgets('a wide screen puts the summary beside the catalog', (
      tester,
    ) async {
      await pumpView(tester, nuevo());

      final catalog = tester.getTopLeft(find.text('Todos'));
      final summary = tester.getTopLeft(find.text('Mi Pedido Para Llevar'));
      expect(summary.dx, greaterThan(catalog.dx));
    });

    testWidgets('a phone stacks the summary below the catalog', (tester) async {
      await pumpView(tester, nuevo(), size: TestScreens.phone);

      final catalog = tester.getTopLeft(find.text('Todos'));
      final summary = tester.getTopLeft(
        find.text('Mi Pedido Para Llevar', skipOffstage: false),
      );
      expect(summary.dy, greaterThan(catalog.dy));
    });
  });

  group('mis pedidos', () {
    testWidgets('shows the loading text', (tester) async {
      await pumpView(
        tester,
        const ClientePedidosState(tab: ClienteTab.historial, loadingList: true),
      );

      expect(find.text('Cargando tus pedidos...'), findsOneWidget);
    });

    testWidgets('the empty state goes back to the new order tab', (
      tester,
    ) async {
      await pumpView(
        tester,
        const ClientePedidosState(tab: ClienteTab.historial),
      );

      expect(find.text('No tienes pedidos registrados'), findsOneWidget);
      expect(
        find.text('Arma tu primer pedido para llevar en la pestaña anterior.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Crear Pedido'));

      verify(() => cubit.changeTab(ClienteTab.nuevo)).called(1);
    });

    testWidgets('an order card shows every field', (tester) async {
      await pumpView(
        tester,
        ClientePedidosState(
          tab: ClienteTab.historial,
          misPedidos: [
            _pedido(8, observaciones: 'Paso a las 8', notas: 'Sin cebolla'),
          ],
        ),
      );

      expect(find.text('Pedido #8'), findsOneWidget);
      expect(find.text('LLEVAR'), findsOneWidget);
      expect(find.text('En Preparación'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
      expect(find.text('Ceviche'), findsOneWidget);
      expect(find.text('"Sin cebolla"'), findsOneWidget);
      expect(find.text('\$17.00'), findsOneWidget);
      expect(
        find.text('Observación: Paso a las 8', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Registrado: 13/11/2026 09:05'), findsOneWidget);
      expect(find.text('1 items'), findsOneWidget);
    });

    testWidgets('a narrow phone fits a long order header', (tester) async {
      await pumpView(
        tester,
        ClientePedidosState(
          tab: ClienteTab.historial,
          misPedidos: [_pedido(123456, observaciones: 'Paso a las 8')],
        ),
        size: const Size(320, 640),
      );

      expect(find.text('Pedido #123456'), findsOneWidget);
      expect(find.text('En Preparación'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('optional fields are hidden when missing', (tester) async {
      await pumpView(
        tester,
        ClientePedidosState(
          tab: ClienteTab.historial,
          misPedidos: [_pedido(8)],
        ),
      );

      expect(
        find.textContaining('Observación:', findRichText: true),
        findsNothing,
      );
      expect(find.textContaining('"'), findsNothing);
    });
  });

  group('mis facturas', () {
    testWidgets('shows the empty message', (tester) async {
      await pumpView(
        tester,
        const ClientePedidosState(tab: ClienteTab.facturas),
      );

      expect(find.text('Historial de Facturas Electrónicas'), findsOneWidget);
      expect(
        find.text('Comprobantes autorizados emitidos a tu nombre o cédula'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Aún no tienes facturas emitidas. Las facturas se generan automáticamente al completar y pagar tus pedidos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a tablet shows the invoices table', (tester) async {
      await pumpView(
        tester,
        ClientePedidosState(
          tab: ClienteTab.facturas,
          misFacturas: [_factura()],
        ),
      );

      for (final header in [
        'SECUENCIAL',
        'FECHA',
        'SUBTOTAL',
        'IVA (15%)',
        'TOTAL',
        'ESTADO',
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      expect(find.text('001-001-000123456'), findsOneWidget);
      expect(find.text('13/11/2026'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget);
      expect(find.text('\$1.50'), findsOneWidget);
      expect(find.text('\$11.50'), findsOneWidget);
      expect(find.text('Emitida'), findsOneWidget);
    });

    testWidgets('a phone shows the invoices as cards', (tester) async {
      await pumpView(
        tester,
        ClientePedidosState(
          tab: ClienteTab.facturas,
          misFacturas: [_factura()],
        ),
        size: TestScreens.phone,
      );

      expect(find.text('001-001-000123456'), findsOneWidget);
      expect(find.text('\$11.50'), findsOneWidget);
    });
  });
}
