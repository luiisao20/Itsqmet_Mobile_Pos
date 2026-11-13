import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/detalle_pedido_draft.dart';

class PedidoDraft extends Equatable {
  const PedidoDraft({
    this.idMesa,
    this.idCliente,
    required this.tipo,
    this.observaciones,
    required this.detalles,
  });

  final int? idMesa;
  final String? idCliente;
  final TipoPedido tipo;
  final String? observaciones;
  final List<DetallePedidoDraft> detalles;

  @override
  List<Object?> get props => [idMesa, idCliente, tipo, observaciones, detalles];
}
