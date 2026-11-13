import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/core/core.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/infrastructure.dart';
import 'package:itsqmet_mobile_pos/services/locator/data_locator.dart';

void main() {
  late GetIt getIt;
  late InMemorySessionStorage storage;

  setUp(() {
    getIt = GetIt.asNewInstance();
    storage = InMemorySessionStorage();
    registerDataDependencies(
      getIt,
      storage: storage,
      baseUrl: 'http://localhost:8080/api',
    );
  });

  test('registers the core singletons', () {
    expect(getIt<SessionStorage>(), same(storage));
    expect(getIt<SessionExpiredNotifier>(), isA<SessionExpiredNotifier>());
    expect(
      getIt<SessionExpiredNotifier>(),
      same(getIt<SessionExpiredNotifier>()),
    );
  });

  test('exposes a single shared Dio instance with the given base URL', () {
    final dio = getIt<Dio>();
    expect(dio, same(getIt<ApiClient>().dio));
    expect(dio.options.baseUrl, 'http://localhost:8080/api');
    expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
  });

  test('resolves every abstract repository to its implementation', () {
    expect(getIt<AuthRepository>(), isA<AuthRepositoryImpl>());
    expect(getIt<CatalogoRepository>(), isA<CatalogoRepositoryImpl>());
    expect(getIt<MesaRepository>(), isA<MesaRepositoryImpl>());
    expect(getIt<PedidoRepository>(), isA<PedidoRepositoryImpl>());
    expect(getIt<FacturaRepository>(), isA<FacturaRepositoryImpl>());
    expect(getIt<UsuarioRepository>(), isA<UsuarioRepositoryImpl>());
    expect(getIt<ClienteRepository>(), isA<ClienteRepositoryImpl>());
    expect(getIt<InsumoRepository>(), isA<InsumoRepositoryImpl>());
    expect(getIt<DistribuidorRepository>(), isA<DistribuidorRepositoryImpl>());
  });

  test('resolves every abstract datasource to its Dio implementation', () {
    expect(getIt<AuthDatasource>(), isA<ApiAuthDatasource>());
    expect(getIt<CatalogoDatasource>(), isA<ApiCatalogoDatasource>());
    expect(getIt<MesaDatasource>(), isA<ApiMesaDatasource>());
    expect(getIt<PedidoDatasource>(), isA<ApiPedidoDatasource>());
    expect(getIt<FacturaDatasource>(), isA<ApiFacturaDatasource>());
    expect(getIt<UsuarioDatasource>(), isA<ApiUsuarioDatasource>());
    expect(getIt<ClienteDatasource>(), isA<ApiClienteDatasource>());
    expect(getIt<InsumoDatasource>(), isA<ApiInsumoDatasource>());
    expect(getIt<DistribuidorDatasource>(), isA<ApiDistribuidorDatasource>());
  });

  test('repositories are lazy singletons', () {
    expect(getIt<PedidoRepository>(), same(getIt<PedidoRepository>()));
  });
}
