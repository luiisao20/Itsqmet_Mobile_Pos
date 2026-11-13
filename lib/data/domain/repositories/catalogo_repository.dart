import 'package:itsqmet_mobile_pos/data/domain/entities/categoria_plato.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/categoria_plato_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/plato_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/plato.dart';

abstract interface class CatalogoRepository {
  Future<List<CategoriaPlato>> getCategorias();

  Future<CategoriaPlato> createCategoria(CategoriaPlatoDraft draft);

  Future<CategoriaPlato> updateCategoria(int id, CategoriaPlatoDraft draft);

  Future<void> deleteCategoria(int id);

  Future<PageResult<Plato>> getPlatos({int page = 0, int size = 100});

  Future<PageResult<Plato>> getPlatosByCategoria(
    int idCategoria, {
    int page = 0,
    int size = 100,
  });

  Future<PageResult<Plato>> searchPlatos({
    String? nombre,
    int? idCategoria,
    bool? disponible,
    int size = 50,
  });

  Future<Plato> getPlato(int id);

  Future<Plato> createPlato(PlatoDraft draft);

  Future<Plato> updatePlato(int id, PlatoDraft draft);

  Future<void> deletePlato(int id);
}
