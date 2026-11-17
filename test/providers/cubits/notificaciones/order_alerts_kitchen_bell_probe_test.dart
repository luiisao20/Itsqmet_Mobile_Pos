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

void main() {
  test('P8 S3/S6: on the kitchen screen one new order rings once, one STOMP sub per topic', () async {
    final clients = <FakeStompClient>[];
    final service = StompRealtimeService(
      url: 'ws://pos.test/ws-pos',
      clientFactory: (config) {
        final fake = FakeStompClient(config);
        clients.add(fake);
        return fake;
      },
    );
    final repository = _MockPedidoRepository();
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
    final bell = _FakeBell(); // KitchenBell is a lazy singleton shared by both
    final alerts = OrderAlertsCubit(
      realtime: service,
      pedidoRepository: repository,
      bell: bell,
      notifier: _FakeNotifier(),
      isAppInForeground: () => true,
    );
    await alerts.onSessionChanged(
      AuthState.authenticated(authUser(rol: Rol.cocina)),
    );
    clients.single.simulateConnect();
    await pumpEventQueue();
    final cocina = CocinaCubit(
      pedidoRepository: repository,
      realtime: service,
      bell: bell,
    );
    await cocina.load();
    alerts.kitchenOpened();

    clients.single.emit(RealtimeTopics.pedidos, jsonEncode(pedidoJson(id: 70)));
    clients.single.emit(RealtimeTopics.cocina, jsonEncode(pedidoJson(id: 70)));
    await pumpEventQueue();

    printOnFailure('rings=${bell.rings} subs=${clients.single.subscribeCalls}');
    expect(
      clients.single.subscribeCalls.toSet().length,
      clients.single.subscribeCalls.length,
    );
    expect(alerts.state.unseen, 0);
    expect(bell.rings, 1);
    await cocina.close();
    await alerts.close();
  });
}
