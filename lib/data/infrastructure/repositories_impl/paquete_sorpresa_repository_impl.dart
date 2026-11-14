import 'package:itsqmet_mobile_pos/data/domain/datasources/paquete_sorpresa_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/paquete_sorpresa.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/paquete_sorpresa_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/paquete_sorpresa_mapper.dart';

class PaqueteSorpresaRepositoryImpl implements PaqueteSorpresaRepository {
  const PaqueteSorpresaRepositoryImpl(this._datasource);

  final PaqueteSorpresaDatasource _datasource;

  @override
  Future<List<PaqueteSorpresa>> getDisponibles() async {
    final models = await _datasource.getDisponibles();
    return models.map(PaqueteSorpresaMapper.toEntity).toList(growable: false);
  }

  @override
  Future<RescateResult> rescatar(
    int id, {
    int cantidad = 1,
    String? observaciones,
  }) async {
    final model = await _datasource.rescatar(
      id,
      cantidad: cantidad,
      observaciones: observaciones,
    );
    return PaqueteSorpresaMapper.rescateToEntity(model);
  }
}
