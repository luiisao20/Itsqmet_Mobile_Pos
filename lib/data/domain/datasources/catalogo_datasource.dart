import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/categoria_plato_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/plato_model.dart';

abstract interface class CatalogoDatasource {
  Future<List<CategoriaPlatoModel>> getCategorias();

  Future<CategoriaPlatoModel> createCategoria(CategoriaPlatoRequest request);

  Future<CategoriaPlatoModel> updateCategoria(
    int id,
    CategoriaPlatoRequest request,
  );

  Future<void> deleteCategoria(int id);

  Future<PageResult<PlatoModel>> getPlatos({int page = 0, int size = 100});

  Future<PageResult<PlatoModel>> getPlatosByCategoria(
    int idCategoria, {
    int page = 0,
    int size = 100,
  });

  Future<PageResult<PlatoModel>> searchPlatos({
    String? nombre,
    int? idCategoria,
    bool? disponible,
    int size = 50,
  });

  Future<PlatoModel> getPlato(int id);

  Future<PlatoModel> createPlato(PlatoRequest request);

  Future<PlatoModel> updatePlato(int id, PlatoRequest request);

  Future<void> deletePlato(int id);
}
