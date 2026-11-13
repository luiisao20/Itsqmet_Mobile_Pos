import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_personas.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_catalogo_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_personas_locator.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

class _MockMesas extends Mock implements MesaRepository {}

class _MockInsumos extends Mock implements InsumoRepository {}

class _MockUsuarios extends Mock implements UsuarioRepository {}

class _MockDistribuidores extends Mock implements DistribuidorRepository {}

class _MockClientes extends Mock implements ClienteRepository {}

GetIt _withRepositories() => GetIt.asNewInstance()
  ..registerSingleton<CatalogoRepository>(_MockCatalogo())
  ..registerSingleton<MesaRepository>(_MockMesas())
  ..registerSingleton<InsumoRepository>(_MockInsumos())
  ..registerSingleton<UsuarioRepository>(_MockUsuarios())
  ..registerSingleton<DistribuidorRepository>(_MockDistribuidores())
  ..registerSingleton<ClienteRepository>(_MockClientes());

void main() {
  test('builds new personas cubits on every request', () async {
    final getIt = _withRepositories();
    registerAdminPersonasDependencies(getIt);

    final cubits = [
      getIt<AdminUsuariosCubit>(),
      getIt<AdminUsuariosCubit>(),
      getIt<DistribuidoresCubit>(),
      getIt<DistribuidoresCubit>(),
      getIt<AdminClientesCubit>(),
      getIt<AdminClientesCubit>(),
    ];

    for (var i = 0; i < cubits.length; i += 2) {
      expect(cubits[i], isNot(same(cubits[i + 1])));
    }
    for (final cubit in cubits) {
      await cubit.close();
    }
  });

  test('catalogo and personas share one AdminChanges bus in any order', () {
    final catalogoFirst = _withRepositories();
    registerAdminCatalogoDependencies(catalogoFirst);
    final busA = catalogoFirst<AdminChanges>();
    registerAdminPersonasDependencies(catalogoFirst);
    expect(catalogoFirst<AdminChanges>(), same(busA));

    final personasFirst = _withRepositories();
    registerAdminPersonasDependencies(personasFirst);
    final busB = personasFirst<AdminChanges>();
    registerAdminCatalogoDependencies(personasFirst);
    expect(personasFirst<AdminChanges>(), same(busB));
  });
}
