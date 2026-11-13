import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/home/home_cubit.dart';

void registerHomeDependencies(GetIt getIt) {
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      catalogoRepository: getIt<CatalogoRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
