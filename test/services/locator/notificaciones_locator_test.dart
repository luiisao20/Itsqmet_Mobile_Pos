import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/kitchen_bell.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:itsqmet_mobile_pos/services/locator/notificaciones_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/push_notification_service.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockRealtime extends Mock implements RealtimeService {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

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

class _FakeBell implements KitchenBell {
  @override
  Future<void> ring() async {}
}

void main() {
  late GetIt getIt;
  late _MockAuthCubit auth;
  late StreamController<AuthState> sessions;
  late StreamController<Pedido> pedidos;
  late _MockRealtime realtime;
  late _FakeNotifier notifier;

  setUp(() {
    sessions = StreamController<AuthState>.broadcast();
    pedidos = StreamController<Pedido>.broadcast();
    notifier = _FakeNotifier();
    auth = _MockAuthCubit();
    whenListen(
      auth,
      sessions.stream,
      initialState: const AuthState.unauthenticated(),
    );
    realtime = _MockRealtime();
    when(() => realtime.pedidos).thenAnswer((_) => pedidos.stream);
    when(() => realtime.cocina).thenAnswer((_) => const Stream.empty());
    when(() => realtime.disconnect()).thenAnswer((_) async {});
    final repository = _MockPedidoRepository();
    when(
      () => repository.searchPedidos(
        estado: any(named: 'estado'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single(const []));

    getIt = GetIt.asNewInstance()
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<RealtimeService>(realtime)
      ..registerSingleton<PedidoRepository>(repository)
      ..registerSingleton<KitchenBell>(_FakeBell());
    registerNotificacionesDependencies(getIt);
    getIt
      ..unregister<OrderAlertNotifier>()
      ..registerSingleton<OrderAlertNotifier>(notifier);
  });

  tearDown(() async {
    await getIt.reset();
    await sessions.close();
    await pedidos.close();
  });

  test('the system notification is shown only in background', () async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    Future<void> lifecycle(AppLifecycleState state) =>
        binding.defaultBinaryMessenger.handlePlatformMessage(
          SystemChannels.lifecycle.name,
          SystemChannels.lifecycle.codec.encodeMessage(state.toString()),
          (_) {},
        );
    addTearDown(() => lifecycle(AppLifecycleState.resumed));
    getIt<OrderAlertsCubit>();
    sessions.add(AuthState.authenticated(authUser(rol: Rol.admin)));
    await pumpEventQueue();

    await lifecycle(AppLifecycleState.inactive);
    pedidos.add(pedidoFixture(id: 1));
    await pumpEventQueue();

    expect(notifier.inApp, hasLength(1));
    expect(notifier.system, isEmpty);

    await lifecycle(AppLifecycleState.paused);
    pedidos.add(pedidoFixture(id: 2));
    await pumpEventQueue();

    expect(notifier.system, [2]);
  });

  test('registers one order alerts cubit that follows the session', () async {
    final cubit = getIt<OrderAlertsCubit>();
    expect(getIt<OrderAlertsCubit>(), same(cubit));
    await pumpEventQueue();
    verifyNever(() => realtime.connect());

    sessions.add(AuthState.authenticated(authUser(rol: Rol.cocina)));
    await pumpEventQueue();
    verify(() => realtime.connect()).called(1);

    sessions.add(const AuthState.unauthenticated());
    await pumpEventQueue();
    verify(() => realtime.disconnect()).called(1);
  });

  test('resetting the locator closes the cubit', () async {
    final cubit = getIt<OrderAlertsCubit>();

    await getIt.reset();

    expect(cubit.isClosed, isTrue);
  });

  test('the default notifier reuses the push notification service', () {
    final services = GetIt.asNewInstance()
      ..registerLazySingleton<PushNotificationService>(
        PushNotificationService.new,
      );
    registerNotificacionesDependencies(services);
    addTearDown(services.reset);

    expect(services<OrderAlertNotifier>(), isA<DefaultOrderAlertNotifier>());
  });
}
