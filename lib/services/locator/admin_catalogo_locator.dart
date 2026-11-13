import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';

void registerAdminCatalogoDependencies(GetIt getIt) {
  if (!getIt.isRegistered<AdminChanges>()) {
    getIt.registerLazySingleton<AdminChanges>(AdminChanges.new);
  }
  getIt
    ..registerFactory<AdminMetricsCubit>(
      () => AdminMetricsCubit(
        catalogoRepository: getIt<CatalogoRepository>(),
        mesaRepository: getIt<MesaRepository>(),
        usuarioRepository: getIt<UsuarioRepository>(),
        insumoRepository: getIt<InsumoRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<PlatosCubit>(
      () => PlatosCubit(
        catalogoRepository: getIt<CatalogoRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<CategoriasCubit>(
      () => CategoriasCubit(
        catalogoRepository: getIt<CatalogoRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<AdminMesasCubit>(
      () => AdminMesasCubit(
        mesaRepository: getIt<MesaRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    )
    ..registerFactory<InsumosCubit>(
      () => InsumosCubit(
        insumoRepository: getIt<InsumoRepository>(),
        changes: getIt<AdminChanges>(),
      ),
    );
}
