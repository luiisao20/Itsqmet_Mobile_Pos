import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

void registerMesasDependencies(GetIt getIt) {
  getIt.registerFactory<MesasCubit>(
    () => MesasCubit(
      mesaRepository: getIt<MesaRepository>(),
      catalogoRepository: getIt<CatalogoRepository>(),
      pedidoRepository: getIt<PedidoRepository>(),
      realtimeService: getIt<RealtimeService>(),
    ),
  );
}
