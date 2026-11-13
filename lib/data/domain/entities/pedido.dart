import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/detalle_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Pedido extends Equatable {
  const Pedido({
    required this.id,
    this.idMesa,
    this.numeroMesa,
    this.idUsuario,
    this.nombreUsuario,
    this.idCliente,
    this.razonSocialCliente,
    this.fechaApertura,
    this.fechaCierre,
    required this.estado,
    required this.tipo,
    this.observaciones,
    required this.detalles,
    this.createdAt,
  });

  final int id;
  final int? idMesa;
  final int? numeroMesa;
  final String? idUsuario;
  final String? nombreUsuario;
  final String? idCliente;
  final String? razonSocialCliente;
  final DateTime? fechaApertura;
  final DateTime? fechaCierre;
  final EstadoPedido estado;
  final TipoPedido tipo;
  final String? observaciones;
  final List<DetallePedido> detalles;
  final DateTime? createdAt;

  double get total => detalles.fold(0, (sum, line) => sum + line.subtotal);

  int get itemsCount => detalles.fold(0, (sum, line) => sum + line.cantidad);

  @override
  List<Object?> get props => [
    id,
    idMesa,
    numeroMesa,
    idUsuario,
    nombreUsuario,
    idCliente,
    razonSocialCliente,
    fechaApertura,
    fechaCierre,
    estado,
    tipo,
    observaciones,
    detalles,
    createdAt,
  ];
}
