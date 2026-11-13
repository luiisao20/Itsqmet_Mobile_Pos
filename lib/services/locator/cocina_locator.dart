import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

void registerCocinaDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<KitchenBell>(AudioplayersKitchenBell.new)
    ..registerFactory<CocinaCubit>(
      () => CocinaCubit(
        pedidoRepository: getIt<PedidoRepository>(),
        realtime: getIt<RealtimeService>(),
        bell: getIt<KitchenBell>(),
      ),
    );
}
