import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_stomp_client.dart';
import '../../../helpers/fixtures.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockMesaRepository extends Mock implements MesaRepository {}

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _FakeBell implements KitchenBell {
  int rings = 0;
  @override
  Future<void> ring() async => rings++;
}

class _FakeNotifier implements OrderAlertNotifier {
  final List<String> inApp = [];
  final List<int> system = [];
  @override
  void showInApp(String message) => inApp.add(message);
  @override
  Future<void> showSystem({
    required int id,
    required String title,
    required String body,
  }) async => system.add(id);
}

AuthState _staff(String uuid, [Rol rol = Rol.cocina]) =>
    AuthState.authenticated(authUser(rol: rol, uuid: uuid));

/// Session and shared-socket regression probes from the independent review.
void main() {
  late List<FakeStompClient> clients;
  late StompRealtimeService service;
  late _MockPedidoRepository repository;
  late _FakeNotifier notifier;
  late OrderAlertsCubit alerts;
  late List<Completer<PageResult<Pedido>>> seeds;
  bool manualSeed = false;

  setUp(() {
    clients = [];
    seeds = [];
    manualSeed = false;
    service = StompRealtimeService(
      url: 'ws://pos.test/ws-pos',
      clientFactory: (config) {
        final fake = FakeStompClient(config);
        clients.add(fake);
        return fake;
      },
    );
    repository = _MockPedidoRepository();
    notifier = _FakeNotifier();
    when(
      () => repository.searchPedidos(
        estado: any(named: 'estado'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) {
      if (!manualSeed) return Future.value(PageResult.single(const []));
      final c = Completer<PageResult<Pedido>>();
      seeds.add(c);
      return c.future;
    });
    when(
      () => repository.getPedidos(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single(const []));
    alerts = OrderAlertsCubit(
      realtime: service,
      pedidoRepository: repository,
      bell: _FakeBell(),
      notifier: notifier,
      isAppInForeground: () => true,
    );
  });

  tearDown(() async {
    if (!alerts.isClosed) await alerts.close();
  });

  void emitOn(
    FakeStompClient client,
    String topic,
    int id, {
    String estado = 'ABIERTO',
  }) {
    client.emit(topic, jsonEncode(pedidoJson(id: id, estado: estado)));
  }

  // MESERO instead of the probe's COCINA: COCINA sends no seed request.
  test(
    'P1 S2: logout then new staff while A seed pending ignores A seed',
    () async {
      manualSeed = true;
      await alerts.onSessionChanged(_staff('A', Rol.mesero));
      clients.last.simulateConnect();
      await alerts.onSessionChanged(const AuthState.unauthenticated());
      await alerts.onSessionChanged(_staff('B', Rol.mesero));
      clients.last.simulateConnect();
      // B seed: nothing open. A seed (stale) completes with pedido 5 open.
      seeds[1].complete(PageResult.single(const []));
      seeds[0].complete(PageResult.single([pedidoFixture(id: 5)]));
      await pumpEventQueue();

      emitOn(clients.last, RealtimeTopics.pedidos, 5);
      await pumpEventQueue();

      expect(notifier.inApp, hasLength(1));
      expect(clients, hasLength(2));
      expect(clients.first.deactivateCalls, 1);
    },
  );

  test('P3 S6: MesasCubit open/close keeps the global listener', () async {
    await alerts.onSessionChanged(_staff('A', Rol.mesero));
    clients.single.simulateConnect();
    await pumpEventQueue();
    final mesaRepo = _MockMesaRepository();
    final catalogo = _MockCatalogoRepository();
    when(mesaRepo.getMesas)
        .thenAnswer((_) async => PageResult.single(const []));
    when(catalogo.getPlatos)
        .thenAnswer((_) async => PageResult.single(const []));
    final mesas = MesasCubit(
      mesaRepository: mesaRepo,
      catalogoRepository: catalogo,
      pedidoRepository: repository,
      realtimeService: service,
    );
    await mesas.start();
    await mesas.close();

    emitOn(clients.single, RealtimeTopics.pedidos, 31);
    await pumpEventQueue();

    expect(clients.single.deactivateCalls, 0);
    expect(notifier.inApp, hasLength(1));
  });

  test(
    'P4 S1/S6: logout with Cocina open, close Cocina, re-login works',
    () async {
      await alerts.onSessionChanged(_staff('A'));
      clients.single.simulateConnect();
      await pumpEventQueue();
      final cocina = CocinaCubit(
        pedidoRepository: repository,
        realtime: service,
        bell: _FakeBell(),
      );
      await cocina.load();

      await alerts.onSessionChanged(const AuthState.unauthenticated());
      expect(clients.single.deactivateCalls, 0, reason: 'cocina still open');
      emitOn(clients.single, RealtimeTopics.cocina, 40);
      await pumpEventQueue();
      expect(cocina.state.pedidos.map((p) => p.id), [40]);
      expect(notifier.inApp, isEmpty, reason: 'no alerts after logout');

      await cocina.close();
      expect(clients.single.deactivateCalls, 1);

      await alerts.onSessionChanged(_staff('B'));
      expect(clients, hasLength(2));
      clients.last.simulateConnect();
      await pumpEventQueue();
      emitOn(clients.last, RealtimeTopics.cocina, 41);
      await pumpEventQueue();
      expect(notifier.inApp, hasLength(1));

      await alerts.onSessionChanged(const AuthState.unauthenticated());
      expect(clients.last.deactivateCalls, 1);
    },
  );

  test('P5 S1: rapid stream of session changes stays balanced', () async {
    final changes = StreamController<AuthState>.broadcast(sync: true);
    alerts.bindSession(const AuthState.unknown(), changes.stream);
    changes
      ..add(_staff('A'))
      ..add(_staff('A'))
      ..add(const AuthState.unauthenticated())
      ..add(_staff('A'))
      ..add(_staff('A'));
    await pumpEventQueue();
    clients.last.simulateConnect();
    await pumpEventQueue();

    emitOn(clients.last, RealtimeTopics.pedidos, 50);
    await pumpEventQueue();
    expect(notifier.inApp, hasLength(1), reason: 'no duplicate listeners');

    changes.add(const AuthState.unauthenticated());
    await pumpEventQueue();
    expect(clients.every((c) => c.deactivateCalls == 1), isTrue);
    expect(service.isConnected, isFalse);
    await changes.close();
  });

  // ADMIN instead of the probe's COCINA: COCINA sends no seed request.
  test('P6 S1: close() while seed pending neither throws nor alerts', () async {
    manualSeed = true;
    await alerts.onSessionChanged(_staff('A', Rol.admin));
    clients.single.simulateConnect();
    await alerts.close();
    seeds.single.complete(PageResult.single([pedidoFixture(id: 1)]));
    await pumpEventQueue();
    expect(clients.single.deactivateCalls, 1);
    expect(alerts.isClosed, isTrue);
  });

  test('P7 S2: CLIENTE login after staff stops and ignores orders', () async {
    await alerts.onSessionChanged(_staff('A'));
    clients.single.simulateConnect();
    await alerts.onSessionChanged(_staff('C', Rol.cliente));
    expect(clients.single.deactivateCalls, 1);
    expect(alerts.state.listening, isFalse);
  });
}
