import 'package:itsqmet_mobile_pos/data/domain/entities/paquete_sorpresa.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/paquete_sorpresa_model.dart';

abstract final class PaqueteSorpresaMapper {
  static PaqueteSorpresa toEntity(PaqueteSorpresaModel model) => PaqueteSorpresa(
    id: model.id,
    titulo: model.titulo,
    descripcion: model.descripcion,
    precioEstimadoOriginal: model.precioEstimadoOriginal,
    precioRescate: model.precioRescate,
    cantidadTotal: model.cantidadTotal,
    cantidadDisponible: model.cantidadDisponible,
    unidadesVendidas: model.unidadesVendidas,
    porcentajeDescuento: model.porcentajeDescuento,
    fechaDisponible: model.fechaDisponible,
    horaInicioVisibilidad: model.horaInicioVisibilidad,
    horaFinRecogida: model.horaFinRecogida,
    estado: model.estado,
    urlImagen: model.urlImagen,
    disponibleAhora: model.disponibleAhora,
    segundosParaApertura: model.segundosParaApertura,
    createdAt: model.createdAt,
  );

  static RescateResult rescateToEntity(RescateResultModel model) =>
      RescateResult(
        idPedido: model.idPedido,
        idPaquete: model.idPaquete,
        tituloPaquete: model.tituloPaquete,
        cantidadRescatada: model.cantidadRescatada,
        totalPagar: model.totalPagar,
        horaFinRecogida: model.horaFinRecogida,
        estadoPedido: model.estadoPedido,
        mensaje: model.mensaje,
      );
}
