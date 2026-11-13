import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_catalogo_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_personas_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/auth_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/caja_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/cliente_pedidos_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/cocina_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/data_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/home_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/mesas_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator([GetIt? locator]) async {
  final services = locator ?? getIt;

  registerDataDependencies(services);
  registerRouterDependencies(services);

  registerAuthDependencies(services);
  registerHomeDependencies(services);
  registerClientePedidosDependencies(services);
  registerMesasDependencies(services);
  registerCocinaDependencies(services);
  registerCajaDependencies(services);
  registerAdminCatalogoDependencies(services);
  registerAdminPersonasDependencies(services);
}
