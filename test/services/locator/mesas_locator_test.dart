import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/mesas_locator.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

class _MockMesaRepository extends Mock implements MesaRepository {}

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockRealtimeService extends Mock implements RealtimeService {}

void main() {
  late GetIt services;

  setUp(() {
    services = GetIt.asNewInstance()
      ..registerSingleton<MesaRepository>(_MockMesaRepository())
      ..registerSingleton<CatalogoRepository>(_MockCatalogoRepository())
      ..registerSingleton<PedidoRepository>(_MockPedidoRepository())
      ..registerSingleton<RealtimeService>(_MockRealtimeService());
  });

  tearDown(() => services.reset());

  test('registers MesasCubit as a factory with a fresh instance', () async {
    registerMesasDependencies(services);

    final first = services<MesasCubit>();
    final second = services<MesasCubit>();

    expect(first, isA<MesasCubit>());
    expect(identical(first, second), isFalse);
    expect(first.state, const MesasState());
  });

  test('can be called on a GetIt without data dependencies', () {
    expect(
      () => registerMesasDependencies(GetIt.asNewInstance()),
      returnsNormally,
    );
  });
}
