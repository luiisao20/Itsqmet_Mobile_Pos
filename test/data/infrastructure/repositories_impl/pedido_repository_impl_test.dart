import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/pedido_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockPedidoDatasource extends Mock implements PedidoDatasource {}

const _detalleModel = DetallePedidoModel(
  id: 100,
  idPedido: 50,
  idPlato: 10,
  nombrePlato: 'Ceviche',
  cantidad: 2,
  precioUnitario: 8.5,
  subtotal: 17,
  estado: EstadoDetallePedido.pendiente,
);

PedidoModel _model({int id = 50, EstadoPedido estado = EstadoPedido.abierto}) =>
    PedidoModel(
      id: id,
      idMesa: 3,
      numeroMesa: 3,
      idUsuario: 'u-1',
      nombreUsuario: 'Ana Pérez',
      estado: estado,
      tipo: TipoPedido.salon,
      detalles: const [_detalleModel],
    );

PageResult<PedidoModel> _page(List<PedidoModel> content) => PageResult(
  content: content,
  totalElements: 40,
  totalPages: 2,
  number: 1,
  size: 20,
  first: false,
  last: true,
  empty: content.isEmpty,
);

void main() {
  late _MockPedidoDatasource datasource;
  late PedidoRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const PedidoRequest(tipo: TipoPedido.salon, detalles: []),
    );
    registerFallbackValue(const PedidoClienteRequest(detalles: []));
  });

  setUp(() {
    datasource = _MockPedidoDatasource();
    repository = PedidoRepositoryImpl(datasource);
  });

  group('getPedidos', () {
    test('maps the page of models to entities keeping metadata', () async {
      when(() => datasource.getPedidos(page: 1, size: 20))
          .thenAnswer((_) async => _page([_model()]));

      final page = await repository.getPedidos(page: 1, size: 20);

      expect(page.totalElements, 40);
      expect(page.number, 1);
      expect(page.last, isTrue);
      expect(page.content.single, pedidoFixture());
    });

    test('maps a 401 to UnauthorizedException', () async {
      when(
        () => datasource.getPedidos(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(httpError(401, {'message': 'Sesión inválida o expirada'}));

      await expectLater(
        repository.getPedidos(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => datasource.getPedidos(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(connectionFailure());

      await expectLater(
        repository.getPedidos(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getPedido', () {
    test('maps the model', () async {
      when(() => datasource.getPedido(50)).thenAnswer((_) async => _model());

      expect(await repository.getPedido(50), pedidoFixture());
    });

    test('maps a 404 to NotFoundException with the backend message', () async {
      when(() => datasource.getPedido(99)).thenThrow(
        httpError(404, {
          'error': 'No encontrado',
          'message': 'Pedido no existe',
        }),
      );

      await expectLater(
        repository.getPedido(99),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Pedido no existe',
          ),
        ),
      );
    });

    test('maps an unexpected payload to UnknownException', () async {
      when(() => datasource.getPedido(1))
          .thenThrow(const FormatException('bad'));

      await expectLater(
        repository.getPedido(1),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  group('searchPedidos', () {
    test('forwards every filter to the datasource', () async {
      when(
        () => datasource.searchPedidos(
          estado: EstadoPedido.servido,
          tipo: TipoPedido.llevar,
          idMesa: 3,
          size: 10,
        ),
      ).thenAnswer((_) async => _page([_model(estado: EstadoPedido.servido)]));

      final page = await repository.searchPedidos(
        estado: EstadoPedido.servido,
        tipo: TipoPedido.llevar,
        idMesa: 3,
        size: 10,
      );

      expect(page.content.single.estado, EstadoPedido.servido);
    });

    test('forwards null filters as null', () async {
      when(() => datasource.searchPedidos())
          .thenAnswer((_) async => _page(const []));

      final page = await repository.searchPedidos();

      expect(page.content, isEmpty);
      verify(() => datasource.searchPedidos()).called(1);
    });
  });

  group('createPedido', () {
    test('converts the draft into a request and maps the result', () async {
      const draft = PedidoDraft(
        idMesa: 3,
        tipo: TipoPedido.salon,
        observaciones: 'Sin sal',
        detalles: [
          DetallePedidoDraft(
            idPlato: 10,
            cantidad: 2,
            notasPreparacion: 'Sin cebolla',
          ),
        ],
      );
      when(() => datasource.createPedido(any()))
          .thenAnswer((_) async => _model());

      final pedido = await repository.createPedido(draft);

      expect(pedido, pedidoFixture());
      final request =
          verify(() => datasource.createPedido(captureAny())).captured.single
              as PedidoRequest;
      expect(request.toJson(), {
        'idMesa': 3,
        'tipo': 'SALON',
        'observaciones': 'Sin sal',
        'detalles': [
          {'idPlato': 10, 'cantidad': 2, 'notasPreparacion': 'Sin cebolla'},
        ],
      });
    });

    test('maps a 400 validation error', () async {
      when(() => datasource.createPedido(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'detalles': 'Debe tener al menos un plato'},
        }),
      );

      await expectLater(
        repository.createPedido(
          const PedidoDraft(tipo: TipoPedido.llevar, detalles: []),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('createPedidoCliente', () {
    test('converts the draft into a client request', () async {
      const draft = PedidoClienteDraft(
        detalles: [DetallePedidoDraft(idPlato: 10, cantidad: 1)],
      );
      when(() => datasource.createPedidoCliente(any()))
          .thenAnswer((_) async => _model());

      final pedido = await repository.createPedidoCliente(draft);

      expect(pedido.id, 50);
      final request =
          verify(() => datasource.createPedidoCliente(captureAny()))
                  .captured
                  .single
              as PedidoClienteRequest;
      expect(request.toJson(), {
        'detalles': [
          {'idPlato': 10, 'cantidad': 1},
        ],
      });
    });
  });

  group('updateEstado', () {
    test('forwards id and estado and maps the result', () async {
      when(() => datasource.updateEstado(50, EstadoPedido.facturado))
          .thenAnswer((_) async => _model(estado: EstadoPedido.facturado));

      final pedido = await repository.updateEstado(50, EstadoPedido.facturado);

      expect(pedido.estado, EstadoPedido.facturado);
    });

    test('maps a 404 to NotFoundException', () async {
      when(() => datasource.updateEstado(99, EstadoPedido.anulado))
          .thenThrow(httpError(404));

      await expectLater(
        repository.updateEstado(99, EstadoPedido.anulado),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getMisPedidos', () {
    test('maps the client page', () async {
      when(() => datasource.getMisPedidos(page: 0, size: 50))
          .thenAnswer((_) async => _page([_model(), _model(id: 51)]));

      final page = await repository.getMisPedidos();

      expect(page.content.map((p) => p.id), [50, 51]);
    });

    test('maps a 401 to UnauthorizedException', () async {
      when(() => datasource.getMisPedidos(page: 0, size: 50))
          .thenThrow(httpError(401));

      await expectLater(
        repository.getMisPedidos(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
