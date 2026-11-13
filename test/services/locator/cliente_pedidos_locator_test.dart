import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:itsqmet_mobile_pos/services/locator/cliente_pedidos_locator.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

class _MockPedidos extends Mock implements PedidoRepository {}

class _MockFacturas extends Mock implements FacturaRepository {}

class _MockRealtime extends Mock implements RealtimeService {}

void main() {
  test('builds a new cliente pedidos cubit on every request', () async {
    final getIt = GetIt.asNewInstance()
      ..registerSingleton<CatalogoRepository>(_MockCatalogo())
      ..registerSingleton<PedidoRepository>(_MockPedidos())
      ..registerSingleton<FacturaRepository>(_MockFacturas())
      ..registerSingleton<RealtimeService>(_MockRealtime());
    registerClientePedidosDependencies(getIt);

    final first = getIt<ClientePedidosCubit>();
    final second = getIt<ClientePedidosCubit>();

    expect(first, isNot(same(second)));
    await first.close();
    await second.close();
  });
}
