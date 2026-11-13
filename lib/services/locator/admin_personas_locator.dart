import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_personas.dart';

void registerAdminPersonasDependencies(GetIt getIt) {
  if (!getIt.isRegistered<AdminChanges>()) {
    getIt.registerLazySingleton<AdminChanges>(AdminChanges.new);
  }
  getIt
    ..registerFactory<AdminUsuariosCubit>(
      () => AdminUsuariosCubit(
        usuarioRepository: getIt<UsuarioRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<DistribuidoresCubit>(
      () => DistribuidoresCubit(
        distribuidorRepository: getIt<DistribuidorRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<AdminClientesCubit>(
      () => AdminClientesCubit(
        clienteRepository: getIt<ClienteRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    );
}
