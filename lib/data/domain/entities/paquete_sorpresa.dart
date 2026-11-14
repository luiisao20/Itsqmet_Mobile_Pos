import 'package:equatable/equatable.dart';

class PaqueteSorpresa extends Equatable {
  const PaqueteSorpresa({
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

  PaqueteSorpresa copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    double? precioEstimadoOriginal,
    double? precioRescate,
    int? cantidadTotal,
    int? cantidadDisponible,
    int? unidadesVendidas,
    int? porcentajeDescuento,
    String? fechaDisponible,
    String? horaInicioVisibilidad,
    String? horaFinRecogida,
    String? estado,
    String? urlImagen,
    bool? disponibleAhora,
    int? segundosParaApertura,
    DateTime? createdAt,
  }) {
    return PaqueteSorpresa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precioEstimadoOriginal:
          precioEstimadoOriginal ?? this.precioEstimadoOriginal,
      precioRescate: precioRescate ?? this.precioRescate,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      unidadesVendidas: unidadesVendidas ?? this.unidadesVendidas,
      porcentajeDescuento: porcentajeDescuento ?? this.porcentajeDescuento,
      fechaDisponible: fechaDisponible ?? this.fechaDisponible,
      horaInicioVisibilidad:
          horaInicioVisibilidad ?? this.horaInicioVisibilidad,
      horaFinRecogida: horaFinRecogida ?? this.horaFinRecogida,
      estado: estado ?? this.estado,
      urlImagen: urlImagen ?? this.urlImagen,
      disponibleAhora: disponibleAhora ?? this.disponibleAhora,
      segundosParaApertura: segundosParaApertura ?? this.segundosParaApertura,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    precioEstimadoOriginal,
    precioRescate,
    cantidadTotal,
    cantidadDisponible,
    unidadesVendidas,
    porcentajeDescuento,
    fechaDisponible,
    horaInicioVisibilidad,
    horaFinRecogida,
    estado,
    urlImagen,
    disponibleAhora,
    segundosParaApertura,
    createdAt,
  ];
}

class RescateResult extends Equatable {
  const RescateResult({
    required this.idPedido,
    required this.idPaquete,
    required this.tituloPaquete,
    required this.cantidadRescatada,
    required this.totalPagar,
    this.horaFinRecogida,
    required this.estadoPedido,
    required this.mensaje,
  });

  final int idPedido;
  final int idPaquete;
  final String tituloPaquete;
  final int cantidadRescatada;
  final double totalPagar;
  final String? horaFinRecogida;
  final String estadoPedido;
  final String mensaje;

  @override
  List<Object?> get props => [
    idPedido,
    idPaquete,
    tituloPaquete,
    cantidadRescatada,
    totalPagar,
    horaFinRecogida,
    estadoPedido,
    mensaje,
  ];
}
