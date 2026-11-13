import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class DetallePedidoModel {
  const DetallePedidoModel({
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

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    final cantidad = parseInt(json['cantidad']) ?? 0;
    final precioUnitario = parseDouble(json['precioUnitario']) ?? 0;
    return DetallePedidoModel(
      id: parseInt(json['id']),
      idPedido: parseInt(json['idPedido']),
      idPlato: parseInt(json['idPlato']) ?? 0,
      nombrePlato: parseString(json['nombrePlato']) ?? '',
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: parseDouble(json['subtotal']) ?? cantidad * precioUnitario,
      notasPreparacion: parseString(json['notasPreparacion']),
      estado: parseEnum(
        json['estado'],
        EstadoDetallePedido.fromJson,
        orElse: EstadoDetallePedido.pendiente,
      ),
    );
  }

  final int? id;
  final int? idPedido;
  final int idPlato;
  final String nombrePlato;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notasPreparacion;
  final EstadoDetallePedido estado;
}

class DetallePedidoRequest {
  const DetallePedidoRequest({
    required this.idPlato,
    required this.cantidad,
    this.notasPreparacion,
  });

  factory DetallePedidoRequest.fromDraft(DetallePedidoDraft draft) =>
      DetallePedidoRequest(
        idPlato: draft.idPlato,
        cantidad: draft.cantidad,
        notasPreparacion: draft.notasPreparacion,
      );

  final int idPlato;
  final int cantidad;
  final String? notasPreparacion;

  Map<String, dynamic> toJson() => {
    'idPlato': idPlato,
    'cantidad': cantidad,
    if (notasPreparacion != null) 'notasPreparacion': notasPreparacion,
  };
}
