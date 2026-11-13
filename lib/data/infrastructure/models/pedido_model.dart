import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/detalle_pedido_model.dart';

class PedidoModel {
  const PedidoModel({
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

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: parseInt(json['id']) ?? 0,
      idMesa: parseInt(json['idMesa']),
      numeroMesa: parseInt(json['numeroMesa']),
      idUsuario: parseString(json['idUsuario']),
      nombreUsuario: parseString(json['nombreUsuario']),
      idCliente: parseString(json['idCliente']),
      razonSocialCliente: parseString(json['razonSocialCliente']),
      fechaApertura: parseDateTime(json['fechaApertura']),
      fechaCierre: parseDateTime(json['fechaCierre']),
      estado: parseEnum(
        json['estado'],
        EstadoPedido.fromJson,
        orElse: EstadoPedido.abierto,
      ),
      tipo: parseEnum(
        json['tipo'],
        TipoPedido.fromJson,
        orElse: TipoPedido.salon,
      ),
      observaciones: parseString(json['observaciones']),
      detalles: asJsonMapList(json['detalles'])
          .map(DetallePedidoModel.fromJson)
          .toList(growable: false),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

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
  final List<DetallePedidoModel> detalles;
  final DateTime? createdAt;
}

class PedidoRequest {
  const PedidoRequest({
    this.idMesa,
    this.idCliente,
    required this.tipo,
    this.observaciones,
    required this.detalles,
  });

  factory PedidoRequest.fromDraft(PedidoDraft draft) => PedidoRequest(
    idMesa: draft.idMesa,
    idCliente: draft.idCliente,
    tipo: draft.tipo,
    observaciones: draft.observaciones,
    detalles: draft.detalles
        .map(DetallePedidoRequest.fromDraft)
        .toList(growable: false),
  );

  final int? idMesa;
  final String? idCliente;
  final TipoPedido tipo;
  final String? observaciones;
  final List<DetallePedidoRequest> detalles;

  Map<String, dynamic> toJson() => {
    if (idMesa != null) 'idMesa': idMesa,
    if (idCliente != null) 'idCliente': idCliente,
    'tipo': tipo.toJson(),
    if (observaciones != null) 'observaciones': observaciones,
    'detalles': detalles.map((line) => line.toJson()).toList(),
  };
}

class PedidoClienteRequest {
  const PedidoClienteRequest({this.observaciones, required this.detalles});

  factory PedidoClienteRequest.fromDraft(PedidoClienteDraft draft) =>
      PedidoClienteRequest(
        observaciones: draft.observaciones,
        detalles: draft.detalles
            .map(DetallePedidoRequest.fromDraft)
            .toList(growable: false),
      );

  final String? observaciones;
  final List<DetallePedidoRequest> detalles;

  Map<String, dynamic> toJson() => {
    if (observaciones != null) 'observaciones': observaciones,
    'detalles': detalles.map((line) => line.toJson()).toList(),
  };
}
