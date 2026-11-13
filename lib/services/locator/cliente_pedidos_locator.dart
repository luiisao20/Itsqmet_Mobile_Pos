import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

void registerClientePedidosDependencies(GetIt getIt) {
  getIt.registerFactory<ClientePedidosCubit>(
    () => ClientePedidosCubit(
      catalogoRepository: getIt<CatalogoRepository>(),
      pedidoRepository: getIt<PedidoRepository>(),
      facturaRepository: getIt<FacturaRepository>(),
      realtime: getIt<RealtimeService>(),
    ),
  );
}
