import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

class _MockPedidos extends Mock implements PedidoRepository {}

class _MockFacturas extends Mock implements FacturaRepository {}

class _FakeRealtime implements RealtimeService {
  final StreamController<Pedido> controller = StreamController.broadcast();
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  bool get isConnected => connectCalls > disconnectCalls;

  @override
  void connect() => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Stream<Pedido> watch(String topic) => topic == RealtimeTopics.pedidos
      ? controller.stream
      : const Stream.empty();

  @override
  Stream<Pedido> get pedidos => watch(RealtimeTopics.pedidos);

  @override
  Stream<Pedido> get cocina => watch(RealtimeTopics.cocina);
}

Plato _plato(int id, {double precio = 10}) => Plato(
  id: id,
  idCategoria: 1,
  nombre: 'Plato $id',
  precioUnitario: precio,
  aplicaIva: true,
  disponible: true,
);

const _categoria = CategoriaPlato(
  id: 3,
  nombre: 'Bebidas',
  areaImpresion: AreaImpresion.bar,
);

Pedido _pedido(int id, {EstadoPedido estado = EstadoPedido.abierto}) =>
    Pedido(id: id, estado: estado, tipo: TipoPedido.llevar, detalles: const []);

Factura _factura(int id) => Factura(
  id: id,
  idPedido: 1,
  numeroSecuencial: '001-001-000000$id',
  subtotal: 10,
  subtotalIva: 1.5,
  propina: 0,
  total: 11.5,
  estado: EstadoFactura.values.first,
);

void main() {
  late _MockCatalogo catalogo;
  late _MockPedidos pedidos;
  late _MockFacturas facturas;
  late _FakeRealtime realtime;

  ClientePedidosCubit build({Duration successDelay = Duration.zero}) =>
      ClientePedidosCubit(
        catalogoRepository: catalogo,
        pedidoRepository: pedidos,
        facturaRepository: facturas,
        realtime: realtime,
        successDelay: successDelay,
      );

  setUpAll(() {
    registerFallbackValue(const PedidoClienteDraft(detalles: []));
  });

  setUp(() {
    catalogo = _MockCatalogo();
    pedidos = _MockPedidos();
    facturas = _MockFacturas();
    realtime = _FakeRealtime();
    when(() => catalogo.getCategorias()).thenAnswer((_) async => [_categoria]);
    when(
      () => catalogo.getPlatos(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single([_plato(1), _plato(2)]));
    when(
      () => catalogo.getPlatosByCategoria(
        any(),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single([_plato(9)]));
    when(
      () => pedidos.getMisPedidos(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single([_pedido(5)]));
    when(
      () => facturas.getMisFacturas(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => PageResult.single([_factura(1)]));
  });

  group('load', () {
    test('loads categories, dishes, my orders and my invoices', () async {
      final cubit = build();

      await cubit.load();

      expect(cubit.state.categorias, [_categoria]);
      expect(cubit.state.platos.map((p) => p.id), [1, 2]);
      expect(cubit.state.misPedidos.map((p) => p.id), [5]);
      expect(cubit.state.misFacturas.map((f) => f.id), [1]);
      expect(cubit.state.loadingList, isFalse);
      expect(cubit.state.tab, ClienteTab.nuevo);
      verify(() => catalogo.getPlatos(page: 0, size: 50)).called(1);
      verify(() => pedidos.getMisPedidos(page: 0, size: 20)).called(1);
      verify(() => facturas.getMisFacturas(page: 0, size: 20)).called(1);
      await cubit.close();
    });

    test('is loading the list while my orders are pending', () async {
      final completer = Completer<PageResult<Pedido>>();
      when(() => pedidos.getMisPedidos(page: 0, size: 20))
          .thenAnswer((_) => completer.future);
      final cubit = build();

      final future = cubit.load();
      expect(cubit.state.loadingList, isTrue);

      completer.complete(PageResult.single(const []));
      await future;
      expect(cubit.state.loadingList, isFalse);
      await cubit.close();
    });

    test('errors end loading and keep the other data', () async {
      when(() => catalogo.getCategorias()).thenThrow(const NetworkException());
      when(() => pedidos.getMisPedidos(page: 0, size: 20))
          .thenThrow(const ServerException());
      when(() => facturas.getMisFacturas(page: 0, size: 20))
          .thenThrow(const ServerException());
      final cubit = build();

      await cubit.load();

      expect(cubit.state.loadingList, isFalse);
      expect(cubit.state.categorias, isEmpty);
      expect(cubit.state.misPedidos, isEmpty);
      expect(cubit.state.misFacturas, isEmpty);
      expect(cubit.state.platos.map((p) => p.id), [1, 2]);
      expect(cubit.state.error, isNull);
      await cubit.close();
    });
  });

  group('catalog', () {
    test('filtering by category loads its dishes', () async {
      final cubit = build();

      await cubit.filterCategoria(3);

      expect(cubit.state.selectedCategoriaId, 3);
      expect(cubit.state.platos.map((p) => p.id), [9]);
      verify(() => catalogo.getPlatosByCategoria(3, page: 0, size: 50))
          .called(1);
      await cubit.close();
    });

    test('clearing the filter loads every dish again', () async {
      final cubit = build();
      await cubit.filterCategoria(3);

      await cubit.filterCategoria(null);

      expect(cubit.state.selectedCategoriaId, isNull);
      expect(cubit.state.platos.map((p) => p.id), [1, 2]);
      await cubit.close();
    });
  });

  group('cart', () {
    test('adding the same dish twice increments its quantity', () async {
      final cubit = build()
        ..addPlato(_plato(1))
        ..addPlato(_plato(1))
        ..addPlato(_plato(2));

      final items = cubit.state.cart.items;
      expect(items.map((i) => (i.plato.id, i.cantidad)), [(1, 2), (2, 1)]);
      await cubit.close();
    });

    test('quantity changes, removal, notes and observaciones', () async {
      final cubit = build()
        ..addPlato(_plato(1))
        ..addPlato(_plato(2))
        ..changeQuantity(0, 2)
        ..updateNotes(0, 'Sin hielo')
        ..updateObservaciones('Rápido');

      expect(cubit.state.cart.items.first.cantidad, 3);
      expect(cubit.state.cart.items.first.notasPreparacion, 'Sin hielo');
      expect(cubit.state.observaciones, 'Rápido');

      cubit.changeQuantity(1, -1);
      expect(cubit.state.cart.length, 1);

      cubit.removeItem(0);
      expect(cubit.state.cart.isEmpty, isTrue);
      await cubit.close();
    });
  });

  group('submit', () {
    test('an empty cart does nothing', () async {
      final cubit = build();

      expect(await cubit.submitOrder(), isFalse);
      verifyNever(() => pedidos.createPedidoCliente(any()));
      await cubit.close();
    });

    test('sends trimmed observaciones and notes, clears the cart, '
        'shows the banner and reloads my orders', () async {
      when(() => pedidos.createPedidoCliente(any()))
          .thenAnswer((_) async => _pedido(42));
      final cubit = build(successDelay: const Duration(hours: 1))
        ..addPlato(_plato(1))
        ..addPlato(_plato(1))
        ..addPlato(_plato(2))
        ..updateNotes(0, '  Sin sal  ')
        ..updateNotes(1, '   ')
        ..updateObservaciones('  Paso a las 8  ');

      final ok = await cubit.submitOrder();

      expect(ok, isTrue);
      verify(
        () => pedidos.createPedidoCliente(
          const PedidoClienteDraft(
            observaciones: 'Paso a las 8',
            detalles: [
              DetallePedidoDraft(
                idPlato: 1,
                cantidad: 2,
                notasPreparacion: 'Sin sal',
              ),
              DetallePedidoDraft(idPlato: 2, cantidad: 1),
            ],
          ),
        ),
      ).called(1);
      expect(cubit.state.cart.isEmpty, isTrue);
      expect(cubit.state.observaciones, '');
      expect(cubit.state.loadingOrder, isFalse);
      expect(
        cubit.state.successMessage,
        '¡Pedido #42 enviado exitosamente a la cocina!',
      );
      expect(cubit.state.tab, ClienteTab.nuevo);
      verify(() => pedidos.getMisPedidos(page: 0, size: 20)).called(1);
      await cubit.close();
    });

    test('blank observaciones are omitted', () async {
      when(() => pedidos.createPedidoCliente(any()))
          .thenAnswer((_) async => _pedido(42));
      final cubit = build()
        ..addPlato(_plato(1))
        ..updateObservaciones('   ');

      await cubit.submitOrder();

      final draft =
          verify(() => pedidos.createPedidoCliente(captureAny()))
                  .captured
                  .single
              as PedidoClienteDraft;
      expect(draft.observaciones, isNull);
      await cubit.close();
    });

    test(
      'after the delay it switches to my orders and hides the banner',
      () async {
        when(() => pedidos.createPedidoCliente(any()))
            .thenAnswer((_) async => _pedido(42));
        final cubit = build(successDelay: const Duration(milliseconds: 10))
          ..addPlato(_plato(1));

        await cubit.submitOrder();
        expect(cubit.state.successMessage, isNotNull);
        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(cubit.state.tab, ClienteTab.historial);
        expect(cubit.state.successMessage, isNull);
        await cubit.close();
      },
    );

    test('the web delay is 1800 ms', () {
      expect(
        ClientePedidosCubit.defaultSuccessDelay,
        const Duration(milliseconds: 1800),
      );
    });

    test(
      'is loading while the order is pending and ignores a second submit',
      () async {
        final completer = Completer<Pedido>();
        when(() => pedidos.createPedidoCliente(any()))
            .thenAnswer((_) => completer.future);
        final cubit = build()..addPlato(_plato(1));

        final future = cubit.submitOrder();
        expect(cubit.state.loadingOrder, isTrue);
        expect(await cubit.submitOrder(), isFalse);

        completer.complete(_pedido(42));
        await future;
        verify(() => pedidos.createPedidoCliente(any())).called(1);
        await cubit.close();
      },
    );

    test('an error keeps the cart and reports the backend message', () async {
      when(() => pedidos.createPedidoCliente(any()))
          .thenThrow(const BadRequestException('Plato agotado'));
      final cubit = build()..addPlato(_plato(1));

      final ok = await cubit.submitOrder();

      expect(ok, isFalse);
      expect(cubit.state.loadingOrder, isFalse);
      expect(cubit.state.cart.length, 1);
      expect(cubit.state.error!.message, 'Plato agotado');
      await cubit.close();
    });

    test('an error without message uses the fallback', () async {
      when(() => pedidos.createPedidoCliente(any()))
          .thenThrow(const BadRequestException(' '));
      final cubit = build()..addPlato(_plato(1));

      await cubit.submitOrder();

      expect(
        cubit.state.error!.message,
        'Error al procesar el pedido para llevar.',
      );
      await cubit.close();
    });

    test('closing before the delay cancels the tab switch', () async {
      when(() => pedidos.createPedidoCliente(any()))
          .thenAnswer((_) async => _pedido(42));
      final cubit = build(successDelay: const Duration(milliseconds: 10))
        ..addPlato(_plato(1));

      await cubit.submitOrder();
      await cubit.close();

      await expectLater(
        Future<void>.delayed(const Duration(milliseconds: 30)),
        completes,
      );
    });
  });

  group('tabs', () {
    test('opening my orders reloads them', () async {
      final cubit = build();

      await cubit.changeTab(ClienteTab.historial);

      expect(cubit.state.tab, ClienteTab.historial);
      verify(() => pedidos.getMisPedidos(page: 0, size: 20)).called(1);
      verifyNever(() => facturas.getMisFacturas(page: 0, size: 20));
      await cubit.close();
    });

    test('opening my invoices reloads them', () async {
      final cubit = build();

      await cubit.changeTab(ClienteTab.facturas);

      expect(cubit.state.tab, ClienteTab.facturas);
      verify(() => facturas.getMisFacturas(page: 0, size: 20)).called(1);
      await cubit.close();
    });

    test('opening the new order tab reloads nothing', () async {
      final cubit = build();

      await cubit.changeTab(ClienteTab.nuevo);

      expect(cubit.state.tab, ClienteTab.nuevo);
      verifyNever(() => pedidos.getMisPedidos(page: 0, size: 20));
      await cubit.close();
    });
  });

  group('realtime', () {
    test('replaces a listed order and ignores unknown ones', () async {
      final cubit = build();
      await cubit.load();

      realtime.controller
        ..add(_pedido(5, estado: EstadoPedido.servido))
        ..add(_pedido(99));
      await pumpEventQueue();

      expect(cubit.state.misPedidos, [
        _pedido(5, estado: EstadoPedido.servido),
      ]);
      await cubit.close();
    });

    test('connects once and releases its connection on close', () async {
      final cubit = build();
      await cubit.load();
      await cubit.load();

      await cubit.close();

      expect(realtime.connectCalls, 1);
      expect(realtime.disconnectCalls, 1);
    });

    test('closing without loading never disconnects', () async {
      final cubit = build();

      await cubit.close();

      expect(realtime.disconnectCalls, 0);
    });
  });
}
