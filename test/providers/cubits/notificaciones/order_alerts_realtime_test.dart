import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_stomp_client.dart';
import '../../../helpers/fixtures.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _FakeBell implements KitchenBell {
  int rings = 0;

  @override
  Future<void> ring() async => rings++;
}

class _FakeNotifier implements OrderAlertNotifier {
  final List<String> inApp = [];

  @override
  void showInApp(String message) => inApp.add(message);

  @override
  Future<void> showSystem({
    required int id,
    required String title,
    required String body,
  }) async {}
}

/// The global listener and the screen cubits share one STOMP connection.
void main() {
  late List<FakeStompClient> clients;
  late StompRealtimeService service;
  late _MockPedidoRepository repository;
  late _FakeNotifier notifier;
  late OrderAlertsCubit alerts;

  setUp(() {
    clients = [];
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
    ).thenAnswer((_) async => PageResult.single(const []));
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
    await alerts.close();
    await service.disconnect();
  });

  Future<void> signInStaff() async {
    await alerts.onSessionChanged(
      AuthState.authenticated(authUser(rol: Rol.cocina)),
    );
    clients.single.simulateConnect();
    await pumpEventQueue();
  }

  Future<void> openAndCloseKitchenScreen() async {
    final cocina = CocinaCubit(
      pedidoRepository: repository,
      realtime: service,
      bell: _FakeBell(),
    );
    await cocina.load();
    await cocina.close();
  }

  test('a screen cubit closing does not stop the global listener', () async {
    await signInStaff();

    await openAndCloseKitchenScreen();
    clients.single.emit(
      RealtimeTopics.pedidos,
      jsonEncode(pedidoJson(id: 21, numeroMesa: 4)),
    );
    await pumpEventQueue();

    expect(clients, hasLength(1));
    expect(clients.single.deactivateCalls, 0);
    expect(service.isConnected, isTrue);
    expect(notifier.inApp, ['Nuevo pedido · Mesa 4']);
  });

  test('logging out after the screens closed closes the socket', () async {
    await signInStaff();
    await openAndCloseKitchenScreen();

    await alerts.onSessionChanged(const AuthState.unauthenticated());

    expect(clients.single.deactivateCalls, 1);
    expect(service.isConnected, isFalse);
  });

  test('a screen opened during the session keeps its own updates', () async {
    await signInStaff();
    final cocina = CocinaCubit(
      pedidoRepository: repository,
      realtime: service,
      bell: _FakeBell(),
    );
    addTearDown(cocina.close);
    await cocina.load();

    clients.single.emit(RealtimeTopics.cocina, jsonEncode(pedidoJson(id: 22)));
    await pumpEventQueue();

    expect(cocina.state.pedidos.map((p) => p.id), [22]);
    expect(notifier.inApp, hasLength(1));
    expect(clients, hasLength(1));
  });
}
