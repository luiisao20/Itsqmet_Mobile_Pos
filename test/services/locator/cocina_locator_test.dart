import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/services/locator/cocina_locator.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockRealtime extends Mock implements RealtimeService {}

class _FakeBell implements KitchenBell {
  @override
  Future<void> ring() async {}
}

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerSingleton<PedidoRepository>(_MockPedidoRepository())
      ..registerSingleton<RealtimeService>(_MockRealtime());
    registerCocinaDependencies(getIt);
  });

  test('registers the audioplayers kitchen bell lazily', () {
    expect(getIt.isRegistered<KitchenBell>(), isTrue);
  });

  test('builds a new cocina cubit on every request', () async {
    getIt
      ..unregister<KitchenBell>()
      ..registerSingleton<KitchenBell>(_FakeBell());

    final first = getIt<CocinaCubit>();
    final second = getIt<CocinaCubit>();

    expect(first, isNot(same(second)));
    await first.close();
    await second.close();
  });
}
