import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Pago extends Equatable {
  const Pago({
    required this.id,
    required this.idFactura,
    this.numeroSecuencialFactura,
    required this.metodoPago,
    required this.monto,
    this.referenciaTransaccion,
    this.fechaPago,
  });

  final int id;
  final int idFactura;
  final String? numeroSecuencialFactura;
  final MetodoPago metodoPago;
  final double monto;
  final String? referenciaTransaccion;
  final DateTime? fechaPago;

  @override
  List<Object?> get props => [
    id,
    idFactura,
    numeroSecuencialFactura,
    metodoPago,
    monto,
    referenciaTransaccion,
    fechaPago,
  ];
}
