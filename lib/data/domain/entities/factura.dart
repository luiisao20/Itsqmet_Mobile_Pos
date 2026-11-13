import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Factura extends Equatable {
  const Factura({
    required this.id,
    required this.idPedido,
    this.idCliente,
    this.razonSocialCliente,
    this.identificacionCliente,
    this.idUsuario,
    this.nombreUsuario,
    required this.numeroSecuencial,
    this.claveAccesoSri,
    this.fechaEmision,
    required this.subtotal,
    required this.subtotalIva,
    required this.propina,
    required this.total,
    required this.estado,
    this.createdAt,
  });

  final int id;
  final int idPedido;
  final String? idCliente;
  final String? razonSocialCliente;
  final String? identificacionCliente;
  final String? idUsuario;
  final String? nombreUsuario;
  final String numeroSecuencial;
  final String? claveAccesoSri;
  final DateTime? fechaEmision;
  final double subtotal;
  final double subtotalIva;
  final double propina;
  final double total;
  final EstadoFactura estado;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    idPedido,
    idCliente,
    razonSocialCliente,
    identificacionCliente,
    idUsuario,
    nombreUsuario,
    numeroSecuencial,
    claveAccesoSri,
    fechaEmision,
    subtotal,
    subtotalIva,
    propina,
    total,
    estado,
    createdAt,
  ];
}
