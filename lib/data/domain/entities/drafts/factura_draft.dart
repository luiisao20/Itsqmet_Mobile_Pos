import 'package:equatable/equatable.dart';

class FacturaDraft extends Equatable {
  const FacturaDraft({
    required this.idPedido,
    required this.idCliente,
    required this.numeroSecuencial,
    this.claveAccesoSri,
    this.propina,
  });

  final int idPedido;
  final String idCliente;
  final String numeroSecuencial;
  final String? claveAccesoSri;
  final double? propina;

  @override
  List<Object?> get props => [
    idPedido,
    idCliente,
    numeroSecuencial,
    claveAccesoSri,
    propina,
  ];
}
