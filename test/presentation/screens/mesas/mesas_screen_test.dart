import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/mesas_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/widgets/mesa_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

class _MockMesaRepository extends Mock implements MesaRepository {}

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _FakeRealtimeService extends RealtimeService {
  final StreamController<Pedido> controller =
      StreamController<Pedido>.broadcast();
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  bool get isConnected => connectCalls > disconnectCalls;

  @override
  void connect() => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Stream<Pedido> watch(String topic) => topic == RealtimeTopics.pedidos
      ? controller.stream
      : const Stream<Pedido>.empty();
}

void main() {
  late _MockMesaRepository mesaRepository;
  late _MockCatalogoRepository catalogoRepository;
  late _MockPedidoRepository pedidoRepository;
  late _FakeRealtimeService realtime;

  final libre = mesaFixture(id: 1, numeroMesa: 1, capacidad: 4);
  final ocupada = mesaFixture(
    id: 2,
    numeroMesa: 2,
    capacidad: 6,
    ubicacion: null,
    estado: EstadoMesa.ocupada,
  );
  final cuenta = mesaFixture(
    id: 3,
    numeroMesa: 3,
    capacidad: 2,
    ubicacion: '',
    estado: EstadoMesa.cuenta,
  );
  final ceviche = platoFixture(id: 10, nombre: 'Ceviche', precioUnitario: 8.5);

  setUpAll(() {
    registerFallbackValue(
      const PedidoDraft(tipo: TipoPedido.salon, detalles: []),
    );
    registerFallbackValue(EstadoMesa.libre);
  });

  setUp(() {
    mesaRepository = _MockMesaRepository();
    catalogoRepository = _MockCatalogoRepository();
    pedidoRepository = _MockPedidoRepository();
    realtime = _FakeRealtimeService();
    when(() => mesaRepository.getMesas())
        .thenAnswer((_) async => PageResult.single([libre, ocupada, cuenta]));
    when(() => catalogoRepository.getPlatos())
        .thenAnswer((_) async => PageResult.single([ceviche]));
  });

  MesasCubit buildCubit() => MesasCubit(
    mesaRepository: mesaRepository,
    catalogoRepository: catalogoRepository,
    pedidoRepository: pedidoRepository,
    realtimeService: realtime,
  );

  Future<MesasCubit> pumpView(
    WidgetTester tester, {
    Size size = TestScreens.phone,
    bool start = true,
  }) async {
    tester.setScreenSize(size);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    if (start) unawaited(cubit.start());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: NotificationsService.messengerKey,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const MesasView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('shows the web header and the estado legend', (tester) async {
    await pumpView(tester);

    final header = tester.widget<PageHeader>(find.byType(PageHeader));
    expect(header.title, 'Mapa de Mesas & Salón');
    expect(
      header.subtitle,
      'Visualiza el estado de las mesas en tiempo real y asigna comandas de salón',
    );
    expect(find.text('Libre'), findsOneWidget);
    expect(find.text('Ocupada'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);
  });

  testWidgets('shows the loading text while mesas load', (tester) async {
    final pending = Completer<PageResult<Mesa>>();
    when(() => mesaRepository.getMesas()).thenAnswer((_) => pending.future);

    await pumpView(tester);

    expect(find.text('Cargando mesas del salón...'), findsOneWidget);
    expect(find.byType(MesaCard), findsNothing);
    pending.complete(PageResult.single([libre]));
    await tester.pumpAndSettle();
    expect(find.text('Cargando mesas del salón...'), findsNothing);
    expect(find.byType(MesaCard), findsOneWidget);
  });

  testWidgets('renders one card per mesa with the web texts', (tester) async {
    await pumpView(tester, size: TestScreens.tabletLandscape);

    expect(find.byType(MesaCard), findsNWidgets(3));
    expect(find.text('Mesa 1'), findsOneWidget);
    expect(find.text('LIBRE'), findsOneWidget);
    expect(find.text('OCUPADA'), findsOneWidget);
    expect(find.text('CUENTA'), findsOneWidget);
    expect(find.text('Terraza'), findsOneWidget);
    expect(find.text('Zona Principal'), findsNWidgets(2));
    expect(find.textContaining('4 personas', findRichText: true), findsOne);
    expect(
      find.textContaining('Capacidad: ', findRichText: true),
      findsNWidgets(3),
    );
    expect(find.text('+ Tomar Comanda'), findsOneWidget);
    expect(find.text('Pedir Cuenta'), findsOneWidget);
    expect(find.text('Liberar'), findsOneWidget);
  });

  testWidgets('badges use the estado variant', (tester) async {
    await pumpView(tester, size: TestScreens.tabletLandscape);

    AppBadge badge(String label) => tester.widget<AppBadge>(
      find.ancestor(of: find.text(label), matching: find.byType(AppBadge)),
    );
    expect(badge('LIBRE').variant, BadgeVariant.success);
    expect(badge('OCUPADA').variant, BadgeVariant.warning);
    expect(badge('CUENTA').variant, BadgeVariant.info);
  });

  for (final (size, columns) in [
    (TestScreens.phone, 2),
    (const Size(700, 1000), 3),
    (TestScreens.tabletPortrait, 4),
    (TestScreens.tabletLandscape, 6),
  ]) {
    testWidgets('grid uses $columns columns at width ${size.width}', (
      tester,
    ) async {
      await pumpView(tester, size: size);

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, columns);
      expect(delegate.mainAxisExtent, 176);
      expect(delegate.crossAxisSpacing, 20);
      expect(delegate.mainAxisSpacing, 20);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Pedir Cuenta and Liberar change the estado without the modal', (
    tester,
  ) async {
    when(() => mesaRepository.updateEstado(any(), any()))
        .thenAnswer((_) async => libre);
    await pumpView(tester, size: TestScreens.tabletLandscape);

    await tester.tap(find.text('Pedir Cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liberar'));
    await tester.pumpAndSettle();

    verify(() => mesaRepository.updateEstado(2, EstadoMesa.cuenta)).called(1);
    verify(() => mesaRepository.updateEstado(3, EstadoMesa.libre)).called(1);
    expect(find.textContaining('Tomar Comanda - Mesa'), findsNothing);
  });

  testWidgets('shows the web error when the estado change fails', (
    tester,
  ) async {
    when(() => mesaRepository.updateEstado(any(), any()))
        .thenThrow(const ServerException());
    final cubit = await pumpView(tester, size: TestScreens.tabletLandscape);

    await tester.tap(find.text('Pedir Cuenta'));
    await tester.pump();

    expect(find.text('Error al cambiar estado de mesa'), findsOneWidget);
    expect(cubit.state.errorMessage, isNull);
  });

  testWidgets('tapping a card opens the comanda modal with the platos', (
    tester,
  ) async {
    final cubit = await pumpView(tester);

    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    expect(cubit.state.selectedMesa, libre);
    expect(find.text('Tomar Comanda - Mesa 1'), findsOneWidget);
    expect(
      find.text('Selecciona los platos para los comensales de la Mesa 1.'),
      findsOneWidget,
    );
    expect(find.text('Ceviche'), findsOneWidget);
    expect(find.text(r'$8.50'), findsOneWidget);
    expect(find.text('+ Agregar'), findsOneWidget);
    final summary = tester.widget<OrderSummary>(find.byType(OrderSummary));
    expect(summary.title, 'Items en Comanda');
    expect(summary.submitLabel, 'Enviar Comanda a Cocina');
    expect(find.text('Cerrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('+ Agregar adds the plato to the comanda summary', (
    tester,
  ) async {
    final cubit = await pumpView(tester);
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Agregar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Agregar'));
    await tester.pumpAndSettle();

    expect(cubit.state.comanda.items.single.cantidad, 2);
    expect(find.text('1 items'), findsOneWidget);
    expect(find.text(r'$19.55'), findsOneWidget);
  });

  testWidgets('submitting sends the comanda and closes the modal', (
    tester,
  ) async {
    when(() => pedidoRepository.createPedido(any()))
        .thenAnswer((_) async => pedidoFixture());
    final cubit = await pumpView(tester);
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Agregar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Enviar Comanda a Cocina'));
    await tester.tap(find.text('Enviar Comanda a Cocina'));
    await tester.pumpAndSettle();

    verify(() => pedidoRepository.createPedido(any())).called(1);
    expect(find.text('Tomar Comanda - Mesa 1'), findsNothing);
    expect(cubit.state.selectedMesa, isNull);
    verify(() => mesaRepository.getMesas()).called(2);
  });

  testWidgets('a failed submit keeps the modal open and shows the error', (
    tester,
  ) async {
    when(() => pedidoRepository.createPedido(any()))
        .thenThrow(const ServerException());
    await pumpView(tester);
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Agregar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Enviar Comanda a Cocina'));
    await tester.tap(find.text('Enviar Comanda a Cocina'));
    await tester.pump();

    expect(find.text('Tomar Comanda - Mesa 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ErrorBanner),
        matching: find.text('Error al enviar la comanda de la mesa'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a submit finishing while the modal closes pops only the modal', (
    tester,
  ) async {
    final pending = Completer<Pedido>();
    when(() => pedidoRepository.createPedido(any()))
        .thenAnswer((_) => pending.future);
    tester.setScreenSize(TestScreens.phone);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    unawaited(cubit.start());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('HOME')),
      ),
    );
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                body: BlocProvider.value(
                  value: cubit,
                  child: const MesasView(),
                ),
              ),
            ),
          ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Agregar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar Comanda a Cocina'));
    await tester.tap(find.text('Enviar Comanda a Cocina'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 50));
    pending.complete(pedidoFixture());
    await tester.pumpAndSettle();

    expect(find.byType(MesasView), findsOneWidget);
    expect(find.text('Tomar Comanda - Mesa 1'), findsNothing);
  });

  testWidgets('Cerrar closes the modal and clears the selected mesa', (
    tester,
  ) async {
    final cubit = await pumpView(tester, size: TestScreens.tabletLandscape);
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.text('Tomar Comanda - Mesa 1'), findsNothing);
    expect(cubit.state.selectedMesa, isNull);
  });

  testWidgets('a realtime pedido event refreshes the cards', (tester) async {
    await pumpView(tester, size: TestScreens.tabletLandscape);
    when(() => mesaRepository.getMesas()).thenAnswer(
      (_) async =>
          PageResult.single([libre.copyWithEstado(EstadoMesa.ocupada)]),
    );

    realtime.controller.add(pedidoFixture());
    await tester.pumpAndSettle();

    expect(find.byType(MesaCard), findsOneWidget);
    expect(find.text('OCUPADA'), findsOneWidget);
    expect(find.text('Cargando mesas del salón...'), findsNothing);
  });

  group('MesasScreen', () {
    tearDown(() => getIt.reset());

    testWidgets('creates the cubit from GetIt, starts it and closes it', (
      tester,
    ) async {
      getIt.registerFactory<MesasCubit>(buildCubit);

      await tester.pumpApp(const MesasScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MesasView), findsOneWidget);
      expect(find.byType(MesaCard), findsNWidgets(3));
      expect(realtime.connectCalls, 1);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(realtime.disconnectCalls, 1);
    });
  });
}

extension on Mesa {
  Mesa copyWithEstado(EstadoMesa estado) => Mesa(
    id: id,
    numeroMesa: numeroMesa,
    capacidad: capacidad,
    ubicacion: ubicacion,
    estado: estado,
    createdAt: createdAt,
  );
}
