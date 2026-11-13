import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:itsqmet_mobile_pos/services/locator/caja_locator.dart';
import 'package:mocktail/mocktail.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

class _MockFacturaRepository extends Mock implements FacturaRepository {}

void main() {
  test('builds a new caja cubit on every request', () async {
    final getIt = GetIt.asNewInstance()
      ..registerSingleton<PedidoRepository>(_MockPedidoRepository())
      ..registerSingleton<FacturaRepository>(_MockFacturaRepository());
    registerCajaDependencies(getIt);

    final first = getIt<CajaCubit>();
    final second = getIt<CajaCubit>();

    expect(first, isNot(same(second)));
    await first.close();
    await second.close();
  });
}
