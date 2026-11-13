import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';

void registerCajaDependencies(GetIt getIt) {
  getIt.registerFactory<CajaCubit>(
    () => CajaCubit(
      pedidoRepository: getIt<PedidoRepository>(),
      facturaRepository: getIt<FacturaRepository>(),
    ),
  );
}
