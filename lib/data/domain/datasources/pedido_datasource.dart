import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_pedido.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';

abstract interface class PedidoDatasource {
  Future<PageResult<PedidoModel>> getPedidos({int page = 0, int size = 50});

  Future<PedidoModel> getPedido(int id);

  Future<PageResult<PedidoModel>> searchPedidos({
    EstadoPedido? estado,
    TipoPedido? tipo,
    int? idMesa,
    int size = 50,
  });

  Future<PedidoModel> createPedido(PedidoRequest request);

  Future<PedidoModel> createPedidoCliente(PedidoClienteRequest request);

  Future<PedidoModel> updateEstado(int id, EstadoPedido estado);

  Future<PageResult<PedidoModel>> getMisPedidos({int page = 0, int size = 50});
}
