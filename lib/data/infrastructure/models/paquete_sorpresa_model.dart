import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';

class PaqueteSorpresaModel {
  const PaqueteSorpresaModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.precioEstimadoOriginal,
    required this.precioRescate,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.unidadesVendidas,
    required this.porcentajeDescuento,
    required this.fechaDisponible,
    required this.horaInicioVisibilidad,
    required this.horaFinRecogida,
    required this.estado,
    this.urlImagen,
    required this.disponibleAhora,
    required this.segundosParaApertura,
    this.createdAt,
  });

  factory PaqueteSorpresaModel.fromJson(Map<String, dynamic> json) {
    return PaqueteSorpresaModel(
      id: parseInt(json['id']) ?? 0,
      titulo: parseString(json['titulo']) ?? '',
      descripcion: parseString(json['descripcion']),
      precioEstimadoOriginal: parseDouble(json['precioEstimadoOriginal']) ?? 0.0,
      precioRescate: parseDouble(json['precioRescate']) ?? 0.0,
      cantidadTotal: parseInt(json['cantidadTotal']) ?? 0,
      cantidadDisponible: parseInt(json['cantidadDisponible']) ?? 0,
      unidadesVendidas: parseInt(json['unidadesVendidas']) ?? 0,
      porcentajeDescuento: parseInt(json['porcentajeDescuento']) ?? 0,
      fechaDisponible: parseString(json['fechaDisponible']) ?? '',
      horaInicioVisibilidad: parseString(json['horaInicioVisibilidad']) ?? '',
      horaFinRecogida: parseString(json['horaFinRecogida']) ?? '',
      estado: parseString(json['estado']) ?? 'ACTIVO',
      urlImagen: parseString(json['urlImagen']),
      disponibleAhora: parseBool(json['disponibleAhora']) ?? false,
      segundosParaApertura: parseInt(json['segundosParaApertura']) ?? 0,
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String titulo;
  final String? descripcion;
  final double precioEstimadoOriginal;
  final double precioRescate;
  final int cantidadTotal;
  final int cantidadDisponible;
  final int unidadesVendidas;
  final int porcentajeDescuento;
  final String fechaDisponible;
  final String horaInicioVisibilidad;
  final String horaFinRecogida;
  final String estado;
  final String? urlImagen;
  final bool disponibleAhora;
  final int segundosParaApertura;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'precioEstimadoOriginal': precioEstimadoOriginal,
    'precioRescate': precioRescate,
    'cantidadTotal': cantidadTotal,
    'cantidadDisponible': cantidadDisponible,
    'unidadesVendidas': unidadesVendidas,
    'porcentajeDescuento': porcentajeDescuento,
    'fechaDisponible': fechaDisponible,
    'horaInicioVisibilidad': horaInicioVisibilidad,
    'horaFinRecogida': horaFinRecogida,
    'estado': estado,
    'urlImagen': urlImagen,
    'disponibleAhora': disponibleAhora,
    'segundosParaApertura': segundosParaApertura,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class RescateResultModel {
  const RescateResultModel({
    required this.idPedido,
    required this.idPaquete,
    required this.tituloPaquete,
    required this.cantidadRescatada,
    required this.totalPagar,
    this.horaFinRecogida,
    required this.estadoPedido,
    required this.mensaje,
  });

  factory RescateResultModel.fromJson(Map<String, dynamic> json) {
    return RescateResultModel(
      idPedido: parseInt(json['idPedido']) ?? 0,
      idPaquete: parseInt(json['idPaquete']) ?? 0,
      tituloPaquete: parseString(json['tituloPaquete']) ?? '',
      cantidadRescatada: parseInt(json['cantidadRescatada']) ?? 1,
      totalPagar: parseDouble(json['totalPagar']) ?? 0.0,
      horaFinRecogida: parseString(json['horaFinRecogida']),
      estadoPedido: parseString(json['estadoPedido']) ?? 'ABIERTO',
      mensaje: parseString(json['mensaje']) ?? '',
    );
  }

  final int idPedido;
  final int idPaquete;
  final String tituloPaquete;
  final int cantidadRescatada;
  final double totalPagar;
  final String? horaFinRecogida;
  final String estadoPedido;
  final String mensaje;

  Map<String, dynamic> toJson() => {
    'idPedido': idPedido,
    'idPaquete': idPaquete,
    'tituloPaquete': tituloPaquete,
    'cantidadRescatada': cantidadRescatada,
    'totalPagar': totalPagar,
    'horaFinRecogida': horaFinRecogida,
    'estadoPedido': estadoPedido,
    'mensaje': mensaje,
  };
}
