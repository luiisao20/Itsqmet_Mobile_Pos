import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class FacturaModel {
  const FacturaModel({
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

  factory FacturaModel.fromJson(Map<String, dynamic> json) {
    return FacturaModel(
      id: parseInt(json['id']) ?? 0,
      idPedido: parseInt(json['idPedido']) ?? 0,
      idCliente: parseString(json['idCliente']),
      razonSocialCliente: parseString(json['razonSocialCliente']),
      identificacionCliente: parseString(json['identificacionCliente']),
      idUsuario: parseString(json['idUsuario']),
      nombreUsuario: parseString(json['nombreUsuario']),
      numeroSecuencial: parseString(json['numeroSecuencial']) ?? '',
      claveAccesoSri: parseString(json['claveAccesoSri']),
      fechaEmision: parseDateTime(json['fechaEmision']),
      subtotal: parseDouble(json['subtotal']) ?? 0,
      subtotalIva: parseDouble(json['subtotalIva']) ?? 0,
      propina: parseDouble(json['propina']) ?? 0,
      total: parseDouble(json['total']) ?? 0,
      estado: parseEnum(
        json['estado'],
        EstadoFactura.fromJson,
        orElse: EstadoFactura.emitida,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

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
}

class FacturaRequest {
  const FacturaRequest({
    required this.idPedido,
    required this.idCliente,
    required this.numeroSecuencial,
    this.claveAccesoSri,
    this.propina,
  });

  factory FacturaRequest.fromDraft(FacturaDraft draft) => FacturaRequest(
    idPedido: draft.idPedido,
    idCliente: draft.idCliente,
    numeroSecuencial: draft.numeroSecuencial,
    claveAccesoSri: draft.claveAccesoSri,
    propina: draft.propina,
  );

  final int idPedido;
  final String idCliente;
  final String numeroSecuencial;
  final String? claveAccesoSri;
  final double? propina;

  Map<String, dynamic> toJson() => {
    'idPedido': idPedido,
    'idCliente': idCliente,
    'numeroSecuencial': numeroSecuencial,
    if (claveAccesoSri != null) 'claveAccesoSri': claveAccesoSri,
    if (propina != null) 'propina': propina,
  };
}
