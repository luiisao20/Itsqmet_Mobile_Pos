import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/core/core.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/infrastructure.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

void registerDataDependencies(
  GetIt getIt, {
  SessionStorage? storage,
  String? baseUrl,
}) {
  getIt
    ..registerLazySingleton<SessionStorage>(
      () => storage ?? SecureSessionStorage(),
    )
    ..registerLazySingleton<SessionExpiredNotifier>(SessionExpiredNotifier.new)
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        storage: getIt<SessionStorage>(),
        notifier: getIt<SessionExpiredNotifier>(),
        baseUrl: baseUrl,
      ),
    )
    ..registerLazySingleton<Dio>(() => getIt<ApiClient>().dio)
    ..registerLazySingleton<RealtimeService>(StompRealtimeService.new)
    ..registerLazySingleton<AuthDatasource>(
      () => ApiAuthDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<CatalogoDatasource>(
      () => ApiCatalogoDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<MesaDatasource>(
      () => ApiMesaDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<PedidoDatasource>(
      () => ApiPedidoDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<FacturaDatasource>(
      () => ApiFacturaDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<UsuarioDatasource>(
      () => ApiUsuarioDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<ClienteDatasource>(
      () => ApiClienteDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<InsumoDatasource>(
      () => ApiInsumoDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<DistribuidorDatasource>(
      () => ApiDistribuidorDatasource(getIt<Dio>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthDatasource>()),
    )
    ..registerLazySingleton<CatalogoRepository>(
      () => CatalogoRepositoryImpl(getIt<CatalogoDatasource>()),
    )
    ..registerLazySingleton<MesaRepository>(
      () => MesaRepositoryImpl(getIt<MesaDatasource>()),
    )
    ..registerLazySingleton<PedidoRepository>(
      () => PedidoRepositoryImpl(getIt<PedidoDatasource>()),
    )
    ..registerLazySingleton<FacturaRepository>(
      () => FacturaRepositoryImpl(getIt<FacturaDatasource>()),
    )
    ..registerLazySingleton<UsuarioRepository>(
      () => UsuarioRepositoryImpl(getIt<UsuarioDatasource>()),
    )
    ..registerLazySingleton<ClienteRepository>(
      () => ClienteRepositoryImpl(getIt<ClienteDatasource>()),
    )
    ..registerLazySingleton<InsumoRepository>(
      () => InsumoRepositoryImpl(getIt<InsumoDatasource>()),
    )
    ..registerLazySingleton<DistribuidorRepository>(
      () => DistribuidorRepositoryImpl(getIt<DistribuidorDatasource>()),
    );
}
