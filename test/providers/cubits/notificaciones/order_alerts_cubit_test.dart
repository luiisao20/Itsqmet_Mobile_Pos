import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/kitchen_bell.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _FakeRealtime extends RealtimeService {
  final Map<String, StreamController<Pedido>> controllers = {};
  int connectCalls = 0;
  int disconnectCalls = 0;

  StreamController<Pedido> controllerFor(String topic) =>
      controllers.putIfAbsent(topic, StreamController<Pedido>.broadcast);

  bool hasListener(String topic) => controllerFor(topic).hasListener;

  @override
  bool get isConnected => connectCalls > disconnectCalls;

  @override
  void connect() => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Stream<Pedido> watch(String topic) => controllerFor(topic).stream;

  void emit(String topic, Pedido pedido) => controllerFor(topic).add(pedido);
}

class _FakeBell implements KitchenBell {
  int rings = 0;

  @override
  Future<void> ring() async => rings++;
}

class _FakeNotifier implements OrderAlertNotifier {
  final List<String> inApp = [];
  final List<({int id, String title, String body})> system = [];

  @override
  void showInApp(String message) => inApp.add(message);

  @override
  Future<void> showSystem({
    required int id,
    required String title,
    required String body,
  }) async => system.add((id: id, title: title, body: body));
}

PageResult<Pedido> _page(List<Pedido> content) => PageResult.single(content);

AuthState _signedIn(Rol rol, {String uuid = 'u-1'}) =>
    AuthState.authenticated(authUser(rol: rol, uuid: uuid));

void main() {
  late _MockPedidoRepository repository;
  late _FakeRealtime realtime;
  late _FakeBell bell;
  late _FakeNotifier notifier;
  late bool foreground;
  late OrderAlertsCubit cubit;

  setUp(() {
    repository = _MockPedidoRepository();
    realtime = _FakeRealtime();
    bell = _FakeBell();
    notifier = _FakeNotifier();
    foreground = true;
    when(
      () => repository.searchPedidos(
        estado: any(named: 'estado'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => _page(const []));
    cubit = OrderAlertsCubit(
      realtime: realtime,
      pedidoRepository: repository,
      bell: bell,
      notifier: notifier,
      isAppInForeground: () => foreground,
    );
  });

  tearDown(() => cubit.close());

  Future<void> signIn(Rol rol, {String uuid = 'u-1'}) async {
    await cubit.onSessionChanged(_signedIn(rol, uuid: uuid));
    await pumpEventQueue();
  }

  Future<void> receive(String topic, Pedido pedido) async {
    realtime.emit(topic, pedido);
    await pumpEventQueue();
  }

  group('S1 staff session', () {
    for (final rol in [Rol.admin, Rol.cocina, Rol.mesero]) {
      test('${rol.name} listens to pedidos and cocina', () async {
        await signIn(rol);

        expect(realtime.connectCalls, 1);
        expect(realtime.hasListener(RealtimeTopics.pedidos), isTrue);
        expect(realtime.hasListener(RealtimeTopics.cocina), isTrue);
        expect(cubit.state.listening, isTrue);
      });
    }

    final notStaff = <String, AuthState>{
      'cliente': _signedIn(Rol.cliente),
      'guest': const AuthState.unauthenticated(),
      'unknown session': const AuthState.unknown(),
    };
    for (final entry in notStaff.entries) {
      test('${entry.key} gets no staff notifications', () async {
        await cubit.onSessionChanged(entry.value);
        await receive(RealtimeTopics.pedidos, pedidoFixture(id: 1));

        expect(realtime.connectCalls, 0);
        expect(notifier.inApp, isEmpty);
        expect(bell.rings, 0);
        expect(cubit.state, const OrderAlertsState());
      });
    }

    test('logout stops listening and resets the counter', () async {
      await signIn(Rol.cocina);
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 1));
      expect(cubit.state.unseen, 1);

      await cubit.onSessionChanged(const AuthState.unauthenticated());
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 2));

      expect(realtime.disconnectCalls, 1);
      expect(realtime.hasListener(RealtimeTopics.pedidos), isFalse);
      expect(realtime.hasListener(RealtimeTopics.cocina), isFalse);
      expect(notifier.inApp, hasLength(1));
      expect(cubit.state, const OrderAlertsState());
    });

    test('the same staff session emitted again keeps one connection', () async {
      await signIn(Rol.cocina);
      await signIn(Rol.cocina);

      expect(realtime.connectCalls, 1);
      expect(realtime.disconnectCalls, 0);
    });

    test('bindSession follows the session stream', () async {
      final sessions = StreamController<AuthState>.broadcast();
      addTearDown(sessions.close);

      cubit.bindSession(const AuthState.unknown(), sessions.stream);
      await pumpEventQueue();
      expect(realtime.connectCalls, 0);

      sessions.add(_signedIn(Rol.mesero));
      await pumpEventQueue();
      expect(realtime.connectCalls, 1);

      sessions.add(const AuthState.unauthenticated());
      await pumpEventQueue();
      expect(realtime.disconnectCalls, 1);
    });

    test('close releases the connection of an active session', () async {
      await signIn(Rol.admin);

      await cubit.close();

      expect(realtime.disconnectCalls, 1);
      expect(realtime.hasListener(RealtimeTopics.pedidos), isFalse);
    });
  });

  group('S2 new-order rule', () {
    setUp(() => signIn(Rol.cocina));

    test('an unseen ABIERTO pedido is a new order', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));

      expect(notifier.inApp, hasLength(1));
    });

    test('the same pedido on both topics notifies once', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));
      await receive(RealtimeTopics.cocina, pedidoFixture(id: 7));

      expect(notifier.inApp, hasLength(1));
      expect(bell.rings, 1);
      expect(cubit.state.unseen, 1);
    });

    test('updates of an already seen pedido never notify', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));
      await receive(
        RealtimeTopics.cocina,
        pedidoFixture(id: 7, estado: EstadoPedido.enPreparacion),
      );
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));

      expect(notifier.inApp, hasLength(1));
    });

    test('an unseen pedido that is not ABIERTO is not new', () async {
      for (final estado in [
        EstadoPedido.enPreparacion,
        EstadoPedido.servido,
        EstadoPedido.facturado,
        EstadoPedido.anulado,
      ]) {
        await receive(
          RealtimeTopics.pedidos,
          pedidoFixture(id: estado.index + 10, estado: estado),
        );
      }
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 11));

      expect(notifier.inApp, isEmpty);
      expect(bell.rings, 0);
      expect(cubit.state.unseen, 0);
    });

    test('a new session forgets the pedidos seen before', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));
      await cubit.onSessionChanged(const AuthState.unauthenticated());
      await signIn(Rol.mesero, uuid: 'u-2');

      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 7));

      expect(notifier.inApp, hasLength(2));
    });
  });

  group('S2 open pedidos at start', () {
    test('open pedidos listed at start are already known', () async {
      when(
        () => repository.searchPedidos(
          estado: any(named: 'estado'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => _page([pedidoFixture(id: 9)]));
      await signIn(Rol.mesero);

      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 9));
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 10));

      expect(notifier.inApp, hasLength(1));
    });

    for (final rol in [Rol.admin, Rol.mesero]) {
      test('${rol.name} asks for the open pedidos once', () async {
        await signIn(rol);

        verify(
          () => repository.searchPedidos(
            estado: EstadoPedido.abierto,
            size: OrderAlertsCubit.seedSize,
          ),
        ).called(1);
      });
    }

    test('cocina sends no seed request (backend forbids /pedidos)', () async {
      await signIn(Rol.cocina);
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 13));

      verifyNever(
        () => repository.searchPedidos(
          estado: any(named: 'estado'),
          size: any(named: 'size'),
        ),
      );
      expect(notifier.inApp, hasLength(1));
    });

    test('a failed seed still notifies new orders', () async {
      when(
        () => repository.searchPedidos(
          estado: any(named: 'estado'),
          size: any(named: 'size'),
        ),
      ).thenThrow(const NetworkException());
      await signIn(Rol.admin);

      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 12));

      expect(notifier.inApp, hasLength(1));
    });
  });

  group('S3 in-app alert', () {
    setUp(() => signIn(Rol.mesero));

    test(
      'a new order shows a message, rings the bell and raises the counter',
      () async {
        await receive(
          RealtimeTopics.pedidos,
          pedidoFixture(id: 1, numeroMesa: 4),
        );
        await receive(
          RealtimeTopics.cocina,
          pedidoFixture(id: 2, tipo: TipoPedido.llevar, numeroMesa: null),
        );

        expect(notifier.inApp, [
          'Nuevo pedido · Mesa 4',
          'Nuevo pedido para llevar',
        ]);
        expect(bell.rings, 2);
        expect(cubit.state, const OrderAlertsState(unseen: 2, listening: true));
      },
    );
  });

  group('S4 system notification', () {
    setUp(() => signIn(Rol.cocina));

    test('is shown only while the app is not in the foreground', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 1));
      expect(notifier.system, isEmpty);

      foreground = false;
      await receive(
        RealtimeTopics.pedidos,
        pedidoFixture(id: 2, numeroMesa: 4),
      );
      await receive(
        RealtimeTopics.pedidos,
        pedidoFixture(id: 3, tipo: TipoPedido.llevar, numeroMesa: null),
      );

      expect(notifier.system, [
        (id: 2, title: 'Nuevo pedido', body: 'Mesa 4'),
        (id: 3, title: 'Nuevo pedido', body: 'Para llevar'),
      ]);
      expect(notifier.inApp, hasLength(3));
    });
  });

  group('S5 kitchen screen', () {
    setUp(() => signIn(Rol.cocina));

    test('opening the kitchen clears the counter', () async {
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 1));
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 2));
      expect(cubit.state.unseen, 2);

      cubit.kitchenOpened();

      expect(cubit.state.unseen, 0);
    });

    test('while the kitchen is open the counter stays at zero and the kitchen '
        'screen rings its own bell', () async {
      cubit.kitchenOpened();
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 1));

      expect(cubit.state.unseen, 0);
      expect(notifier.inApp, hasLength(1));
      expect(bell.rings, 0);

      cubit.kitchenClosed();
      await receive(RealtimeTopics.pedidos, pedidoFixture(id: 2));

      expect(cubit.state.unseen, 1);
      expect(bell.rings, 1);
    });
  });
}
