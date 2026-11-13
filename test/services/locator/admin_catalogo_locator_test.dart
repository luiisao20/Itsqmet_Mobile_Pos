import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_catalogo_locator.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

class _MockMesas extends Mock implements MesaRepository {}

class _MockUsuarios extends Mock implements UsuarioRepository {}

class _MockInsumos extends Mock implements InsumoRepository {}

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerSingleton<CatalogoRepository>(_MockCatalogo())
      ..registerSingleton<MesaRepository>(_MockMesas())
      ..registerSingleton<UsuarioRepository>(_MockUsuarios())
      ..registerSingleton<InsumoRepository>(_MockInsumos());
    registerAdminCatalogoDependencies(getIt);
  });

  test('shares one AdminChanges bus', () {
    expect(getIt<AdminChanges>(), same(getIt<AdminChanges>()));
  });

  test('keeps an AdminChanges bus registered by another feature', () {
    final other = GetIt.asNewInstance()
      ..registerSingleton<AdminChanges>(AdminChanges());
    final existing = other<AdminChanges>();

    registerAdminCatalogoDependencies(other);

    expect(other<AdminChanges>(), same(existing));
  });

  test('builds new cubits on every request', () async {
    final cubits = [
      getIt<AdminMetricsCubit>(),
      getIt<AdminMetricsCubit>(),
      getIt<PlatosCubit>(),
      getIt<PlatosCubit>(),
      getIt<CategoriasCubit>(),
      getIt<CategoriasCubit>(),
      getIt<AdminMesasCubit>(),
      getIt<AdminMesasCubit>(),
      getIt<InsumosCubit>(),
      getIt<InsumosCubit>(),
    ];

    for (var i = 0; i < cubits.length; i += 2) {
      expect(cubits[i], isNot(same(cubits[i + 1])));
    }
    for (final cubit in cubits) {
      await cubit.close();
    }
  });
}
