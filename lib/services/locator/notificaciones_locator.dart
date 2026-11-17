import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/kitchen_bell.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:itsqmet_mobile_pos/services/notifications/app_foreground.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/push_notification_service.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

void registerNotificacionesDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<OrderAlertNotifier>(
      () => DefaultOrderAlertNotifier(getIt<PushNotificationService>()),
    )
    ..registerLazySingleton<OrderAlertsCubit>(() {
      final auth = getIt<AuthCubit>();
      return OrderAlertsCubit(
        realtime: getIt<RealtimeService>(),
        pedidoRepository: getIt<PedidoRepository>(),
        bell: getIt<KitchenBell>(),
        notifier: getIt<OrderAlertNotifier>(),
        isAppInForeground: isAppInForeground,
      )..bindSession(auth.state, auth.stream);
    }, dispose: (cubit) => cubit.close());
}
