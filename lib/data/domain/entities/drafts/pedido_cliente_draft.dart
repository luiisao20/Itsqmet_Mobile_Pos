import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/detalle_pedido_draft.dart';

class PedidoClienteDraft extends Equatable {
  const PedidoClienteDraft({this.observaciones, required this.detalles});

  final String? observaciones;
  final List<DetallePedidoDraft> detalles;

  @override
  List<Object?> get props => [observaciones, detalles];
}
