import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/home/home_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/home_locator.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetIt services;

  setUp(() {
    services = GetIt.asNewInstance()
      ..registerSingleton<CatalogoRepository>(_MockCatalogoRepository())
      ..registerSingleton<AuthRepository>(_MockAuthRepository());
  });

  tearDown(() => services.reset());

  test(
    'registers HomeCubit as a factory built from the repositories',
    () async {
      registerHomeDependencies(services);

      final first = services<HomeCubit>();
      final second = services<HomeCubit>();

      expect(first, isNot(same(second)));
      expect(first.state, const HomeState());

      await first.close();
      await second.close();
    },
  );
}
