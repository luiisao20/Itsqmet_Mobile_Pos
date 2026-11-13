import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class DetallePedido extends Equatable {
  const DetallePedido({
    this.id,
    this.idPedido,
    required this.idPlato,
    required this.nombrePlato,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.notasPreparacion,
    required this.estado,
  });

  final int? id;
  final int? idPedido;
  final int idPlato;
  final String nombrePlato;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notasPreparacion;
  final EstadoDetallePedido estado;

  @override
  List<Object?> get props => [
    id,
    idPedido,
    idPlato,
    nombrePlato,
    cantidad,
    precioUnitario,
    subtotal,
    notasPreparacion,
    estado,
  ];
}
