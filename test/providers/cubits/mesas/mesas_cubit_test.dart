import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockMesaRepository extends Mock implements MesaRepository {}

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _FakeRealtimeService extends RealtimeService {
  final Map<String, StreamController<Pedido>> controllers = {};
  int connectCalls = 0;
  int disconnectCalls = 0;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  void connect() {
    connectCalls++;
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _connected = false;
    final current = [...controllers.values];
    controllers.clear();
    for (final controller in current) {
      await controller.close();
    }
  }

  @override
  Stream<Pedido> watch(String topic) =>
      controllers.putIfAbsent(topic, StreamController<Pedido>.broadcast).stream;

  void emit(String topic, Pedido pedido) => controllers[topic]?.add(pedido);

  bool hasListener(String topic) => controllers[topic]?.hasListener ?? false;
}

PageResult<Mesa> _mesasPage(List<Mesa> mesas) => PageResult.single(mesas);

PageResult<Plato> _platosPage(List<Plato> platos) => PageResult.single(platos);

void main() {
  late _MockMesaRepository mesaRepository;
  late _MockCatalogoRepository catalogoRepository;
  late _MockPedidoRepository pedidoRepository;
  late _FakeRealtimeService realtime;

  final libre = mesaFixture(id: 1, numeroMesa: 1);
  final ocupada = mesaFixture(id: 2, numeroMesa: 2, estado: EstadoMesa.ocupada);
  final ceviche = platoFixture(id: 10, nombre: 'Ceviche');
  final sopa = platoFixture(id: 11, nombre: 'Sopa', precioUnitario: 4);

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
        .thenAnswer((_) async => _mesasPage([libre, ocupada]));
    when(() => catalogoRepository.getPlatos())
        .thenAnswer((_) async => _platosPage([ceviche, sopa]));
  });

  MesasCubit build() => MesasCubit(
    mesaRepository: mesaRepository,
    catalogoRepository: catalogoRepository,
    pedidoRepository: pedidoRepository,
    realtimeService: realtime,
  );

  MesasState openedWith(List<CartItem> items) => MesasState(
    loadingMesas: false,
    mesas: [libre, ocupada],
    platos: [ceviche, sopa],
    selectedMesa: libre,
    comanda: ShoppingCart(items),
  );

  test('initial state is loading with empty data', () {
    final cubit = build();
    addTearDown(cubit.close);

    expect(cubit.state, const MesasState());
    expect(cubit.state.loadingMesas, isTrue);
    expect(cubit.state.mesas, isEmpty);
    expect(cubit.state.platos, isEmpty);
    expect(cubit.state.selectedMesa, isNull);
    expect(cubit.state.comanda.isEmpty, isTrue);
    expect(cubit.state.observaciones, '');
    expect(cubit.state.loadingOrder, isFalse);
    expect(cubit.state.errorMessage, isNull);
  });

  group('start', () {
    test('loads mesas and platos and stops loading', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.start();

      expect(cubit.state.loadingMesas, isFalse);
      expect(cubit.state.mesas, [libre, ocupada]);
      expect(cubit.state.platos, [ceviche, sopa]);
      verify(() => mesaRepository.getMesas()).called(1);
      verify(() => catalogoRepository.getPlatos()).called(1);
      verifyNever(() => catalogoRepository.getCategorias());
    });

    test('stops loading and keeps no mesas when the request fails', () async {
      when(() => mesaRepository.getMesas()).thenThrow(const NetworkException());
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.start();

      expect(cubit.state.loadingMesas, isFalse);
      expect(cubit.state.mesas, isEmpty);
      expect(cubit.state.platos, [ceviche, sopa]);
      expect(cubit.state.errorMessage, isNull);
    });

    test('keeps platos empty when the catalog request fails', () async {
      when(() => catalogoRepository.getPlatos())
          .thenThrow(const ServerException());
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.start();

      expect(cubit.state.platos, isEmpty);
      expect(cubit.state.mesas, [libre, ocupada]);
    });

    test('connects the realtime service and listens to pedidos', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.start();

      expect(realtime.connectCalls, 1);
      expect(realtime.hasListener(RealtimeTopics.pedidos), isTrue);
      expect(realtime.hasListener(RealtimeTopics.cocina), isFalse);
    });
  });

  group('realtime', () {
    test(
      'reloads mesas silently on every pedidos event without loading',
      () async {
        final cubit = build();
        addTearDown(cubit.close);
        await cubit.start();
        final updated = mesaFixture(
          id: 1,
          numeroMesa: 1,
          estado: EstadoMesa.ocupada,
        );
        when(() => mesaRepository.getMesas())
            .thenAnswer((_) async => _mesasPage([updated, ocupada]));
        final states = <MesasState>[];
        final sub = cubit.stream.listen(states.add);
        addTearDown(sub.cancel);

        realtime.emit(RealtimeTopics.pedidos, pedidoFixture());
        await pumpEventQueue();

        expect(states, hasLength(1));
        expect(states.single.loadingMesas, isFalse);
        expect(states.single.mesas, [updated, ocupada]);
        verify(() => mesaRepository.getMesas()).called(2);
      },
    );

    test('ignores cocina events', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.start();

      realtime.emit(RealtimeTopics.cocina, pedidoFixture());
      await pumpEventQueue();

      verify(() => mesaRepository.getMesas()).called(1);
    });

    test('close cancels the subscription and disconnects', () async {
      final cubit = build();
      await cubit.start();

      await cubit.close();

      expect(realtime.disconnectCalls, 1);
      expect(realtime.hasListener(RealtimeTopics.pedidos), isFalse);
    });

    test('listens again when the stream is closed by someone else', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.start();

      await realtime.disconnect();
      await pumpEventQueue();

      expect(realtime.connectCalls, 2);
      expect(realtime.hasListener(RealtimeTopics.pedidos), isTrue);
      realtime.emit(RealtimeTopics.pedidos, pedidoFixture());
      await pumpEventQueue();
      verify(() => mesaRepository.getMesas()).called(2);
    });

    test('does not emit after close when a reload resolves late', () async {
      final pending = Completer<PageResult<Mesa>>();
      final cubit = build();
      await cubit.start();
      when(() => mesaRepository.getMesas()).thenAnswer((_) => pending.future);

      realtime.emit(RealtimeTopics.pedidos, pedidoFixture());
      await pumpEventQueue();
      await cubit.close();
      pending.complete(_mesasPage([libre]));
      await pumpEventQueue();

      expect(cubit.state.mesas, [libre, ocupada]);
    });

    test('a stale response does not overwrite a newer one', () async {
      final slow = Completer<PageResult<Mesa>>();
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.start();
      when(() => mesaRepository.getMesas()).thenAnswer((_) => slow.future);
      final first = cubit.refreshMesas();
      when(() => mesaRepository.getMesas())
          .thenAnswer((_) async => _mesasPage([ocupada]));

      await cubit.refreshMesas();
      slow.complete(_mesasPage([libre]));
      await first;

      expect(cubit.state.mesas, [ocupada]);
    });
  });

  group('comanda', () {
    blocTest<MesasCubit, MesasState>(
      'openComanda selects the mesa and resets the comanda',
      build: build,
      seed: () =>
          openedWith([CartItem(plato: ceviche, cantidad: 2)])
              .copyWith(observaciones: 'old', selectedMesa: ocupada),
      act: (cubit) => cubit.openComanda(libre),
      expect: () => [openedWith(const [])],
    );

    blocTest<MesasCubit, MesasState>(
      'closeComanda clears the selected mesa',
      build: build,
      seed: () => openedWith(const []),
      act: (cubit) => cubit.closeComanda(),
      expect: () => [
        MesasState(
          loadingMesas: false,
          mesas: [libre, ocupada],
          platos: [ceviche, sopa],
        ),
      ],
    );

    blocTest<MesasCubit, MesasState>(
      'addPlato adds a new line and increments an existing one',
      build: build,
      seed: () => openedWith(const []),
      act: (cubit) => cubit
        ..addPlato(ceviche)
        ..addPlato(sopa)
        ..addPlato(ceviche),
      expect: () => [
        openedWith([CartItem(plato: ceviche, cantidad: 1)]),
        openedWith([
          CartItem(plato: ceviche, cantidad: 1),
          CartItem(plato: sopa, cantidad: 1),
        ]),
        openedWith([
          CartItem(plato: ceviche, cantidad: 2),
          CartItem(plato: sopa, cantidad: 1),
        ]),
      ],
    );

    blocTest<MesasCubit, MesasState>(
      'changeQuantity updates and removes the line when it reaches zero',
      build: build,
      seed: () => openedWith([
        CartItem(plato: ceviche, cantidad: 1),
        CartItem(plato: sopa, cantidad: 1),
      ]),
      act: (cubit) => cubit
        ..changeQuantity(1, 1)
        ..changeQuantity(0, -1),
      expect: () => [
        openedWith([
          CartItem(plato: ceviche, cantidad: 1),
          CartItem(plato: sopa, cantidad: 2),
        ]),
        openedWith([CartItem(plato: sopa, cantidad: 2)]),
      ],
    );

    blocTest<MesasCubit, MesasState>(
      'removeItem, updateNotes and updateObservaciones edit the comanda',
      build: build,
      seed: () => openedWith([
        CartItem(plato: ceviche, cantidad: 1),
        CartItem(plato: sopa, cantidad: 1),
      ]),
      act: (cubit) => cubit
        ..removeItem(0)
        ..updateNotes(0, 'sin sal')
        ..updateObservaciones('rapido'),
      expect: () => [
        openedWith([CartItem(plato: sopa, cantidad: 1)]),
        openedWith([
          CartItem(plato: sopa, cantidad: 1, notasPreparacion: 'sin sal'),
        ]),
        openedWith([
          CartItem(plato: sopa, cantidad: 1, notasPreparacion: 'sin sal'),
        ]).copyWith(observaciones: 'rapido'),
      ],
    );
  });

  group('submitComanda', () {
    test('does nothing without a selected mesa or items', () async {
      final cubit = build();
      addTearDown(cubit.close);
      cubit.emit(openedWith(const []));

      expect(await cubit.submitComanda(), isFalse);
      cubit.closeComanda();
      cubit.addPlato(ceviche);
      expect(await cubit.submitComanda(), isFalse);

      verifyNever(() => pedidoRepository.createPedido(any()));
    });

    test(
      'creates a SALON pedido, closes the comanda and reloads mesas',
      () async {
        when(() => pedidoRepository.createPedido(any()))
            .thenAnswer((_) async => pedidoFixture());
        final cubit = build();
        addTearDown(cubit.close);
        cubit.emit(
          openedWith([
            CartItem(
              plato: ceviche,
              cantidad: 2,
              notasPreparacion: ' sin ají ',
            ),
            CartItem(plato: sopa, cantidad: 1, notasPreparacion: '   '),
          ]).copyWith(observaciones: '  rápido  '),
        );
        final states = <MesasState>[];
        final sub = cubit.stream.listen(states.add);
        addTearDown(sub.cancel);

        final result = await cubit.submitComanda();
        await pumpEventQueue();

        expect(result, isTrue);
        verify(
          () => pedidoRepository.createPedido(
            const PedidoDraft(
              idMesa: 1,
              tipo: TipoPedido.salon,
              observaciones: 'rápido',
              detalles: [
                DetallePedidoDraft(
                  idPlato: 10,
                  cantidad: 2,
                  notasPreparacion: 'sin ají',
                ),
                DetallePedidoDraft(idPlato: 11, cantidad: 1),
              ],
            ),
          ),
        ).called(1);
        expect(states.first.loadingOrder, isTrue);
        expect(states[1].loadingOrder, isFalse);
        expect(states[1].selectedMesa, isNull);
        expect(states.any((s) => s.loadingMesas), isTrue);
        expect(cubit.state.loadingMesas, isFalse);
        expect(cubit.state.errorMessage, isNull);
        verify(() => mesaRepository.getMesas()).called(1);
      },
    );

    test('sends null observaciones when they are blank', () async {
      when(() => pedidoRepository.createPedido(any()))
          .thenAnswer((_) async => pedidoFixture());
      final cubit = build();
      addTearDown(cubit.close);
      cubit.emit(
        openedWith([CartItem(plato: ceviche, cantidad: 1)])
            .copyWith(observaciones: '   '),
      );

      await cubit.submitComanda();

      final draft =
          verify(() => pedidoRepository.createPedido(captureAny()))
                  .captured
                  .single
              as PedidoDraft;
      expect(draft.observaciones, isNull);
    });

    test('keeps the comanda and reports the web error on failure', () async {
      when(() => pedidoRepository.createPedido(any()))
          .thenThrow(const ServerException('boom'));
      final cubit = build();
      addTearDown(cubit.close);
      final opened = openedWith([CartItem(plato: ceviche, cantidad: 1)]);
      cubit.emit(opened);

      final result = await cubit.submitComanda();

      expect(result, isFalse);
      expect(
        cubit.state,
        opened.copyWith(comandaError: 'Error al enviar la comanda de la mesa'),
      );
      expect(cubit.state.errorMessage, isNull);
      verifyNever(() => mesaRepository.getMesas());
    });

    test('a new submit clears the previous comanda error', () async {
      final pending = Completer<Pedido>();
      when(() => pedidoRepository.createPedido(any()))
          .thenAnswer((_) => pending.future);
      final cubit = build();
      addTearDown(cubit.close);
      cubit.emit(
        openedWith([CartItem(plato: ceviche, cantidad: 1)])
            .copyWith(comandaError: 'Error al enviar la comanda de la mesa'),
      );

      final result = cubit.submitComanda();

      expect(cubit.state.loadingOrder, isTrue);
      expect(cubit.state.comandaError, isNull);
      pending.complete(pedidoFixture());
      expect(await result, isTrue);
    });

    test(
      'a late result of a closed comanda does not touch a newly opened one',
      () async {
        final pending = Completer<Pedido>();
        when(() => pedidoRepository.createPedido(any()))
            .thenAnswer((_) => pending.future);
        final cubit = build();
        addTearDown(cubit.close);
        cubit.emit(openedWith([CartItem(plato: ceviche, cantidad: 1)]));

        final result = cubit.submitComanda();
        cubit
          ..closeComanda()
          ..openComanda(ocupada);
        expect(cubit.state.loadingOrder, isFalse);
        pending.complete(pedidoFixture());

        expect(await result, isFalse);
        expect(cubit.state.selectedMesa, ocupada);
        expect(cubit.state.loadingOrder, isFalse);
      },
    );

    test('a late failure of a closed comanda shows no error', () async {
      final pending = Completer<Pedido>();
      when(() => pedidoRepository.createPedido(any()))
          .thenAnswer((_) => pending.future);
      final cubit = build();
      addTearDown(cubit.close);
      cubit.emit(openedWith([CartItem(plato: ceviche, cantidad: 1)]));

      final result = cubit.submitComanda();
      cubit.closeComanda();
      pending.completeError(const ServerException());

      expect(await result, isFalse);
      expect(cubit.state.comandaError, isNull);
      expect(cubit.state.loadingOrder, isFalse);
    });

    test('opening or closing the comanda clears the comanda error', () {
      final cubit = build();
      addTearDown(cubit.close);
      const error = 'Error al enviar la comanda de la mesa';
      cubit.emit(openedWith(const []).copyWith(comandaError: error));

      cubit.closeComanda();
      expect(cubit.state.comandaError, isNull);

      cubit.emit(cubit.state.copyWith(comandaError: error));
      cubit.openComanda(libre);
      expect(cubit.state.comandaError, isNull);
    });
  });

  group('cambiarEstadoMesa', () {
    test('updates the estado and reloads mesas', () async {
      when(() => mesaRepository.updateEstado(2, EstadoMesa.cuenta))
          .thenAnswer((_) async => ocupada);
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.cambiarEstadoMesa(ocupada, EstadoMesa.cuenta);

      verify(() => mesaRepository.updateEstado(2, EstadoMesa.cuenta)).called(1);
      verify(() => mesaRepository.getMesas()).called(1);
      expect(cubit.state.mesas, [libre, ocupada]);
      expect(cubit.state.errorMessage, isNull);
    });

    test('reports the web error and does not reload on failure', () async {
      when(() => mesaRepository.updateEstado(any(), any()))
          .thenThrow(const BadRequestException());
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.cambiarEstadoMesa(ocupada, EstadoMesa.cuenta);

      expect(cubit.state.errorMessage, 'Error al cambiar estado de mesa');
      verifyNever(() => mesaRepository.getMesas());
    });

    test('clearError removes the error message', () async {
      when(() => mesaRepository.updateEstado(any(), any()))
          .thenThrow(const BadRequestException());
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.cambiarEstadoMesa(ocupada, EstadoMesa.libre);

      cubit.clearError();

      expect(cubit.state.errorMessage, isNull);
    });
  });
}
