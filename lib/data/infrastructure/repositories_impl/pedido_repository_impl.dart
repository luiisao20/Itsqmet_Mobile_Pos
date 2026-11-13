import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/pedido_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pedido_cliente_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pedido_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/pedido_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/pedido_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  PedidoRepositoryImpl(this._datasource);

  final PedidoDatasource _datasource;

  @override
  Future<PageResult<Pedido>> getPedidos({int page = 0, int size = 50}) =>
      ErrorMapper.guard(() async {
        final result = await _datasource.getPedidos(page: page, size: size);
        return result.map(PedidoMapper.toEntity);
      });

  @override
  Future<Pedido> getPedido(int id) => ErrorMapper.guard(
    () async => PedidoMapper.toEntity(await _datasource.getPedido(id)),
  );

  @override
  Future<PageResult<Pedido>> searchPedidos({
    EstadoPedido? estado,
    TipoPedido? tipo,
    int? idMesa,
    int size = 50,
  }) => ErrorMapper.guard(() async {
    final result = await _datasource.searchPedidos(
      estado: estado,
      tipo: tipo,
      idMesa: idMesa,
      size: size,
    );
    return result.map(PedidoMapper.toEntity);
  });

  @override
  Future<Pedido> createPedido(PedidoDraft draft) => ErrorMapper.guard(
    () async => PedidoMapper.toEntity(
      await _datasource.createPedido(PedidoRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<Pedido> createPedidoCliente(PedidoClienteDraft draft) =>
      ErrorMapper.guard(
        () async => PedidoMapper.toEntity(
          await _datasource.createPedidoCliente(
            PedidoClienteRequest.fromDraft(draft),
          ),
        ),
      );

  @override
  Future<Pedido> updateEstado(int id, EstadoPedido estado) => ErrorMapper.guard(
    () async =>
        PedidoMapper.toEntity(await _datasource.updateEstado(id, estado)),
  );

  @override
  Future<PageResult<Pedido>> getMisPedidos({int page = 0, int size = 50}) =>
      ErrorMapper.guard(() async {
        final result = await _datasource.getMisPedidos(page: page, size: size);
        return result.map(PedidoMapper.toEntity);
      });
}
