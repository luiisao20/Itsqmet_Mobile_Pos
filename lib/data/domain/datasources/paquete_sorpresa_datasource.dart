import 'package:itsqmet_mobile_pos/data/infrastructure/models/paquete_sorpresa_model.dart';

abstract interface class PaqueteSorpresaDatasource {
  Future<List<PaqueteSorpresaModel>> getDisponibles();

  Future<RescateResultModel> rescatar(
    int id, {
    int cantidad = 1,
    String? observaciones,
  });
}
