import 'package:itsqmet_mobile_pos/data/domain/entities/paquete_sorpresa.dart';

abstract interface class PaqueteSorpresaRepository {
  Future<List<PaqueteSorpresa>> getDisponibles();

  Future<RescateResult> rescatar(
    int id, {
    int cantidad = 1,
    String? observaciones,
  });
}
