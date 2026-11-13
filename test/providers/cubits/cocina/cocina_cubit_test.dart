import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _FakeRealtime implements RealtimeService {
  final Map<String, StreamController<Pedido>> controllers = {};
  int connectCalls = 0;
  int disconnectCalls = 0;

  StreamController<Pedido> controllerFor(String topic) =>
      controllers.putIfAbsent(topic, StreamController<Pedido>.broadcast);

  @override
  bool get isConnected => connectCalls > 0;

  @override
  void connect() => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Stream<Pedido> watch(String topic) => controllerFor(topic).stream;

  @override
  Stream<Pedido> get pedidos => watch(RealtimeTopics.pedidos);

  @override
  Stream<Pedido> get cocina => watch(RealtimeTopics.cocina);

  void emit(String topic, Pedido pedido) => controllerFor(topic).add(pedido);
}

class _FakeBell implements KitchenBell {
  int rings = 0;

  @override
  Future<void> ring() async => rings++;
}

Pedido _pedido(int id, EstadoPedido estado) => Pedido(
  id: id,
  estado: estado,
  tipo: TipoPedido.salon,
  numeroMesa: 3,
  detalles: const [],
);

PageResult<Pedido> _page(List<Pedido> content) => PageResult<Pedido>(
  content: content,
  totalElements: content.length,
  totalPages: 1,
  number: 0,
  size: 50,
  first: true,
  last: true,
  empty: content.isEmpty,
);

void main() {
  late _MockPedidoRepository repository;
  late _FakeRealtime realtime;
  late _FakeBell bell;

  CocinaCubit build() =>
      CocinaCubit(pedidoRepository: repository, realtime: realtime, bell: bell);

  setUpAll(() => registerFallbackValue(EstadoPedido.abierto));

  setUp(() {
    repository = _MockPedidoRepository();
    realtime = _FakeRealtime();
    bell = _FakeBell();
  });

  group('load', () {
    blocTest<CocinaCubit, CocinaState>(
      'requests page 0 size 50 and keeps only active orders',
      setUp: () =>
          when(() => repository.getPedidos(page: 0, size: 50)).thenAnswer(
            (_) async => _page([
              _pedido(1, EstadoPedido.abierto),
              _pedido(2, EstadoPedido.facturado),
              _pedido(3, EstadoPedido.enPreparacion),
              _pedido(4, EstadoPedido.anulado),
              _pedido(5, EstadoPedido.servido),
            ]),
          ),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const CocinaState(loading: true),
        CocinaState(
          pedidos: [
            _pedido(1, EstadoPedido.abierto),
            _pedido(3, EstadoPedido.enPreparacion),
            _pedido(5, EstadoPedido.servido),
          ],
        ),
      ],
    );

    blocTest<CocinaCubit, CocinaState>(
      'a load error ends loading with no orders',
      setUp: () =>
          when(() => repository.getPedidos(page: 0, size: 50))
              .thenThrow(const NetworkException()),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [const CocinaState(loading: true), const CocinaState()],
    );

    test('connects once and releases its connection on close', () async {
      when(() => repository.getPedidos(page: 0, size: 50))
          .thenAnswer((_) async => _page([]));
      final cubit = build();

      await cubit.load();
      await cubit.load();
      await cubit.close();

      expect(realtime.connectCalls, 1);
      expect(realtime.disconnectCalls, 1);
    });

    test('closing without loading never disconnects', () async {
      await build().close();

      expect(realtime.disconnectCalls, 0);
    });
  });

  group('realtime', () {
    Future<CocinaCubit> loaded(List<Pedido> initial) async {
      when(() => repository.getPedidos(page: 0, size: 50))
          .thenAnswer((_) async => _page(initial));
      final cubit = build();
      await cubit.load();
      return cubit;
    }

    Future<void> flush() => Future<void>.delayed(Duration.zero);

    test('a new active order goes first and rings the bell', () async {
      final cubit = await loaded([_pedido(1, EstadoPedido.abierto)]);

      realtime.emit(RealtimeTopics.cocina, _pedido(2, EstadoPedido.abierto));
      await flush();

      expect(cubit.state.pedidos.map((p) => p.id), [2, 1]);
      expect(bell.rings, 1);
      await cubit.close();
    });

    test('the same order on both topics rings only once', () async {
      final cubit = await loaded([]);

      realtime
        ..emit(RealtimeTopics.cocina, _pedido(7, EstadoPedido.abierto))
        ..emit(RealtimeTopics.pedidos, _pedido(7, EstadoPedido.abierto));
      await flush();

      expect(cubit.state.pedidos.map((p) => p.id), [7]);
      expect(bell.rings, 1);
      await cubit.close();
    });

    test('an existing order is replaced in place without ringing', () async {
      final cubit = await loaded([
        _pedido(1, EstadoPedido.abierto),
        _pedido(2, EstadoPedido.abierto),
      ]);

      realtime.emit(
        RealtimeTopics.pedidos,
        _pedido(2, EstadoPedido.enPreparacion),
      );
      await flush();

      expect(cubit.state.pedidos, [
        _pedido(1, EstadoPedido.abierto),
        _pedido(2, EstadoPedido.enPreparacion),
      ]);
      expect(bell.rings, 0);
      await cubit.close();
    });

    test('a facturado or anulado order is removed', () async {
      final cubit = await loaded([
        _pedido(1, EstadoPedido.servido),
        _pedido(2, EstadoPedido.abierto),
      ]);

      realtime
        ..emit(RealtimeTopics.pedidos, _pedido(1, EstadoPedido.facturado))
        ..emit(RealtimeTopics.cocina, _pedido(2, EstadoPedido.anulado));
      await flush();

      expect(cubit.state.pedidos, isEmpty);
      await cubit.close();
    });

    test('an unknown closed order is ignored', () async {
      final cubit = await loaded([]);

      realtime.emit(RealtimeTopics.pedidos, _pedido(9, EstadoPedido.anulado));
      await flush();

      expect(cubit.state.pedidos, isEmpty);
      expect(bell.rings, 0);
      await cubit.close();
    });

    test('events after close are ignored', () async {
      final cubit = await loaded([]);
      await cubit.close();

      realtime.emit(RealtimeTopics.cocina, _pedido(3, EstadoPedido.abierto));
      await flush();

      expect(bell.rings, 0);
    });
  });

  group('filter', () {
    final pedidos = [
      _pedido(1, EstadoPedido.abierto),
      _pedido(2, EstadoPedido.enPreparacion),
      _pedido(3, EstadoPedido.servido),
      _pedido(4, EstadoPedido.abierto),
    ];

    test('todos shows every order', () {
      expect(CocinaState(pedidos: pedidos).filteredPedidos, pedidos);
    });

    test('each estado filter keeps only that estado', () {
      final state = CocinaState(pedidos: pedidos);

      expect(
        state
            .copyWith(filtro: CocinaFiltro.abierto)
            .filteredPedidos
            .map((p) => p.id),
        [1, 4],
      );
      expect(
        state
            .copyWith(filtro: CocinaFiltro.enPreparacion)
            .filteredPedidos
            .map((p) => p.id),
        [2],
      );
      expect(
        state
            .copyWith(filtro: CocinaFiltro.servido)
            .filteredPedidos
            .map((p) => p.id),
        [3],
      );
    });

    blocTest<CocinaCubit, CocinaState>(
      'changeFiltro updates the selected filter',
      build: build,
      act: (cubit) => cubit.changeFiltro(CocinaFiltro.servido),
      expect: () => [const CocinaState(filtro: CocinaFiltro.servido)],
    );
  });

  group('updateEstado', () {
    blocTest<CocinaCubit, CocinaState>(
      'applies the updated order like a realtime event',
      setUp: () =>
          when(() => repository.updateEstado(1, EstadoPedido.enPreparacion))
              .thenAnswer((_) async => _pedido(1, EstadoPedido.enPreparacion)),
      build: build,
      seed: () => CocinaState(pedidos: [_pedido(1, EstadoPedido.abierto)]),
      act: (cubit) => cubit.updateEstado(
        _pedido(1, EstadoPedido.abierto),
        EstadoPedido.enPreparacion,
      ),
      expect: () => [
        CocinaState(pedidos: [_pedido(1, EstadoPedido.enPreparacion)]),
      ],
      verify: (_) => expect(bell.rings, 0),
    );

    blocTest<CocinaCubit, CocinaState>(
      'anular removes the order',
      setUp: () =>
          when(() => repository.updateEstado(1, EstadoPedido.anulado))
              .thenAnswer((_) async => _pedido(1, EstadoPedido.anulado)),
      build: build,
      seed: () => CocinaState(pedidos: [_pedido(1, EstadoPedido.abierto)]),
      act: (cubit) => cubit.updateEstado(
        _pedido(1, EstadoPedido.abierto),
        EstadoPedido.anulado,
      ),
      expect: () => [const CocinaState()],
    );

    blocTest<CocinaCubit, CocinaState>(
      'an error with a message exposes that message',
      setUp: () => when(() => repository.updateEstado(1, any()))
          .thenThrow(const BadRequestException('El pedido ya fue facturado')),
      build: build,
      seed: () => CocinaState(pedidos: [_pedido(1, EstadoPedido.abierto)]),
      act: (cubit) => cubit.updateEstado(
        _pedido(1, EstadoPedido.abierto),
        EstadoPedido.servido,
      ),
      expect: () => [
        CocinaState(
          pedidos: [_pedido(1, EstadoPedido.abierto)],
          error: const CocinaError(1, 'El pedido ya fue facturado'),
        ),
      ],
    );

    blocTest<CocinaCubit, CocinaState>(
      'an error without a message uses the web fallback text',
      setUp: () =>
          when(() => repository.updateEstado(1, any()))
              .thenThrow(const BadRequestException('')),
      build: build,
      seed: () => CocinaState(pedidos: [_pedido(1, EstadoPedido.abierto)]),
      act: (cubit) => cubit.updateEstado(
        _pedido(1, EstadoPedido.abierto),
        EstadoPedido.servido,
      ),
      expect: () => [
        CocinaState(
          pedidos: [_pedido(1, EstadoPedido.abierto)],
          error: const CocinaError(1, 'Error al actualizar estado del pedido'),
        ),
      ],
    );
  });
}
