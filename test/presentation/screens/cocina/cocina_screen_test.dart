import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/cocina_screen.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockCocinaCubit extends MockCubit<CocinaState> implements CocinaCubit {}

DetallePedido _linea({
  int idPlato = 1,
  String nombre = 'Lomo saltado',
  int cantidad = 2,
  String? notas,
}) => DetallePedido(
  idPlato: idPlato,
  nombrePlato: nombre,
  cantidad: cantidad,
  precioUnitario: 10,
  subtotal: 10.0 * cantidad,
  notasPreparacion: notas,
  estado: EstadoDetallePedido.values.first,
);

Pedido _pedido(
  int id,
  EstadoPedido estado, {
  TipoPedido tipo = TipoPedido.salon,
  String? cliente,
  String? observaciones,
  List<DetallePedido>? detalles,
}) => Pedido(
  id: id,
  estado: estado,
  tipo: tipo,
  numeroMesa: 3,
  nombreUsuario: 'Ana Pérez',
  razonSocialCliente: cliente,
  fechaApertura: DateTime(2026, 11, 13, 9, 5),
  observaciones: observaciones,
  detalles: detalles ?? [_linea()],
);

void main() {
  late _MockCocinaCubit cubit;

  setUpAll(() {
    registerFallbackValue(_pedido(0, EstadoPedido.abierto));
    registerFallbackValue(EstadoPedido.abierto);
    registerFallbackValue(CocinaFiltro.todos);
  });

  setUp(() {
    cubit = _MockCocinaCubit();
    when(() => cubit.updateEstado(any(), any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester,
    CocinaState state, {
    Size size = TestScreens.tabletLandscape,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<CocinaCubit>.value(value: cubit, child: const CocinaView()),
      size: size,
    );
  }

  testWidgets('shows the header, live badge and filters with the count', (
    tester,
  ) async {
    await pumpView(
      tester,
      CocinaState(
        pedidos: [
          _pedido(1, EstadoPedido.abierto),
          _pedido(2, EstadoPedido.servido),
        ],
      ),
    );

    expect(find.text('Monitor KDS de Cocina & Bar'), findsOneWidget);
    expect(find.text('WebSocket En Vivo'), findsOneWidget);
    expect(
      find.text(
        'Recepción instantánea de comandas por orden de llegada con instrucciones de preparación',
      ),
      findsOneWidget,
    );
    expect(find.text('Todos (2)'), findsOneWidget);
    expect(find.text('Nuevos'), findsOneWidget);
    expect(find.text('En Preparación'), findsOneWidget);
    expect(find.text('Listos / Servidos'), findsOneWidget);
  });

  testWidgets('shows the loading text while loading', (tester) async {
    await pumpView(tester, const CocinaState(loading: true));

    expect(find.text('Cargando monitor de cocina...'), findsOneWidget);
  });

  testWidgets('shows the empty state when no order matches', (tester) async {
    await pumpView(tester, const CocinaState());

    expect(find.text('¡Todo al día en Cocina!'), findsOneWidget);
    expect(
      find.text(
        'No hay pedidos pendientes por preparar en este momento. La pantalla se actualizará automáticamente con campanilla al recibir un nuevo pedido.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a salon order card shows every field of the comanda', (
    tester,
  ) async {
    await pumpView(
      tester,
      CocinaState(
        pedidos: [
          _pedido(
            12,
            EstadoPedido.abierto,
            cliente: 'Juan Torres',
            observaciones: 'Sin cubiertos',
            detalles: [_linea(notas: 'Sin cebolla')],
          ),
        ],
      ),
    );

    expect(find.text('Pedido #12'), findsOneWidget);
    expect(find.text('09:05'), findsOneWidget);
    expect(find.text('Mesa 3'), findsOneWidget);
    expect(
      find.text('Atendido por: Ana Pérez', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Cliente: Juan Torres', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Lomo saltado'), findsOneWidget);
    expect(
      find.text('Instrucción: Sin cebolla', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Nota general: Sin cubiertos', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('optional fields are hidden when missing', (tester) async {
    await pumpView(
      tester,
      CocinaState(pedidos: [_pedido(12, EstadoPedido.abierto)]),
    );

    expect(find.textContaining('Cliente:', findRichText: true), findsNothing);
    expect(
      find.textContaining('Instrucción:', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Nota general:', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('a take-away order shows Para Llevar instead of the table', (
    tester,
  ) async {
    await pumpView(
      tester,
      CocinaState(
        pedidos: [_pedido(5, EstadoPedido.abierto, tipo: TipoPedido.llevar)],
      ),
    );

    expect(find.text('Para Llevar'), findsOneWidget);
    expect(find.text('Mesa 3'), findsNothing);
  });

  testWidgets('an open order starts preparation', (tester) async {
    final pedido = _pedido(1, EstadoPedido.abierto);
    await pumpView(tester, CocinaState(pedidos: [pedido]));

    await tester.tap(find.text('Iniciar Preparación'));

    verify(() => cubit.updateEstado(pedido, EstadoPedido.enPreparacion))
        .called(1);
  });

  testWidgets('an order in preparation is marked as served', (tester) async {
    final pedido = _pedido(1, EstadoPedido.enPreparacion);
    await pumpView(tester, CocinaState(pedidos: [pedido]));

    await tester.tap(find.text('Marcar Servido / Listo'));

    verify(() => cubit.updateEstado(pedido, EstadoPedido.servido)).called(1);
    expect(find.text('Iniciar Preparación'), findsNothing);
  });

  testWidgets('a served order shows the ready label and no action button', (
    tester,
  ) async {
    await pumpView(
      tester,
      CocinaState(pedidos: [_pedido(1, EstadoPedido.servido)]),
    );

    expect(find.text('Listo para Despacho / Mesa'), findsOneWidget);
    expect(find.text('Iniciar Preparación'), findsNothing);
    expect(find.text('Marcar Servido / Listo'), findsNothing);
  });

  testWidgets('every order can be cancelled', (tester) async {
    final pedido = _pedido(1, EstadoPedido.servido);
    await pumpView(tester, CocinaState(pedidos: [pedido]));

    await tester.tap(find.text('Anular'));

    verify(() => cubit.updateEstado(pedido, EstadoPedido.anulado)).called(1);
  });

  testWidgets('tapping a filter changes it in the cubit', (tester) async {
    await pumpView(tester, const CocinaState());

    await tester.tap(find.text('Nuevos'));

    verify(() => cubit.changeFiltro(CocinaFiltro.abierto)).called(1);
  });

  testWidgets('only the filtered orders are shown', (tester) async {
    await pumpView(
      tester,
      CocinaState(
        filtro: CocinaFiltro.servido,
        pedidos: [
          _pedido(1, EstadoPedido.abierto),
          _pedido(2, EstadoPedido.servido),
        ],
      ),
    );

    expect(find.text('Pedido #1'), findsNothing);
    expect(find.text('Pedido #2'), findsOneWidget);
    expect(find.text('Todos (2)'), findsOneWidget);
  });

  testWidgets('a wide screen shows three cards per row', (tester) async {
    await pumpView(
      tester,
      CocinaState(
        pedidos: [
          _pedido(1, EstadoPedido.abierto),
          _pedido(2, EstadoPedido.abierto),
          _pedido(3, EstadoPedido.abierto),
        ],
      ),
    );

    final first = tester.getTopLeft(find.text('Pedido #1'));
    final third = tester.getTopLeft(find.text('Pedido #3'));
    expect(third.dy, first.dy);
    expect(third.dx, greaterThan(first.dx));
  });

  testWidgets('a phone stacks the cards in one column', (tester) async {
    await pumpView(
      tester,
      CocinaState(
        pedidos: [
          _pedido(1, EstadoPedido.abierto),
          _pedido(2, EstadoPedido.abierto),
        ],
      ),
      size: TestScreens.phone,
    );

    final first = tester.getTopLeft(find.text('Pedido #1'));
    final second = tester.getTopLeft(find.text('Pedido #2'));
    expect(second.dx, first.dx);
    expect(second.dy, greaterThan(first.dy));
  });

  testWidgets('a new error is shown as an error notification', (tester) async {
    tester.setScreenSize(TestScreens.tabletLandscape);
    whenListen(
      cubit,
      Stream.fromIterable([
        const CocinaState(error: CocinaError(1, 'El pedido ya fue facturado')),
      ]),
      initialState: const CocinaState(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: NotificationsService.messengerKey,
        home: Scaffold(
          body: BlocProvider<CocinaCubit>.value(
            value: cubit,
            child: const CocinaView(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('El pedido ya fue facturado'), findsOneWidget);
  });
}
