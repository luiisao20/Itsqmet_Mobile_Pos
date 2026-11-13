import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class PagoDraft extends Equatable {
  const PagoDraft({
    required this.idFactura,
    required this.metodoPago,
    required this.monto,
    this.referenciaTransaccion,
  });

  final int idFactura;
  final MetodoPago metodoPago;
  final double monto;
  final String? referenciaTransaccion;

  @override
  List<Object?> get props => [
    idFactura,
    metodoPago,
    monto,
    referenciaTransaccion,
  ];
}
