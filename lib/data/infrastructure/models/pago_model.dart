import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class PagoModel {
  const PagoModel({
    required this.id,
    required this.idFactura,
    this.numeroSecuencialFactura,
    required this.metodoPago,
    required this.monto,
    this.referenciaTransaccion,
    this.fechaPago,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: parseInt(json['id']) ?? 0,
      idFactura: parseInt(json['idFactura']) ?? 0,
      numeroSecuencialFactura: parseString(json['numeroSecuencialFactura']),
      metodoPago: parseEnum(
        json['metodoPago'],
        MetodoPago.fromJson,
        orElse: MetodoPago.efectivo,
      ),
      monto: parseDouble(json['monto']) ?? 0,
      referenciaTransaccion: parseString(json['referenciaTransaccion']),
      fechaPago: parseDateTime(json['fechaPago']),
    );
  }

  final int id;
  final int idFactura;
  final String? numeroSecuencialFactura;
  final MetodoPago metodoPago;
  final double monto;
  final String? referenciaTransaccion;
  final DateTime? fechaPago;
}

class PagoRequest {
  const PagoRequest({
    required this.idFactura,
    required this.metodoPago,
    required this.monto,
    this.referenciaTransaccion,
  });

  factory PagoRequest.fromDraft(PagoDraft draft) => PagoRequest(
    idFactura: draft.idFactura,
    metodoPago: draft.metodoPago,
    monto: draft.monto,
    referenciaTransaccion: draft.referenciaTransaccion,
  );

  final int idFactura;
  final MetodoPago metodoPago;
  final double monto;
  final String? referenciaTransaccion;

  Map<String, dynamic> toJson() => {
    'idFactura': idFactura,
    'metodoPago': metodoPago.toJson(),
    'monto': monto,
    if (referenciaTransaccion != null)
      'referenciaTransaccion': referenciaTransaccion,
  };
}
