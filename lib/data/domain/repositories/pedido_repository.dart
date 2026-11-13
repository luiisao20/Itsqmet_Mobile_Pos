import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pedido_cliente_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pedido_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_pedido.dart';

abstract interface class PedidoRepository {
  Future<PageResult<Pedido>> getPedidos({int page = 0, int size = 50});

  Future<Pedido> getPedido(int id);

  Future<PageResult<Pedido>> searchPedidos({
    EstadoPedido? estado,
    TipoPedido? tipo,
    int? idMesa,
    int size = 50,
  });

  Future<Pedido> createPedido(PedidoDraft draft);

  Future<Pedido> createPedidoCliente(PedidoClienteDraft draft);

  Future<Pedido> updateEstado(int id, EstadoPedido estado);

  Future<PageResult<Pedido>> getMisPedidos({int page = 0, int size = 50});
}
