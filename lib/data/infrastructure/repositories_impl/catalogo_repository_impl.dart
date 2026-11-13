import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/catalogo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/categoria_plato.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/categoria_plato_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/plato_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/plato.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/catalogo_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/categoria_plato_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/plato_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/categoria_plato_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/plato_model.dart';

class CatalogoRepositoryImpl implements CatalogoRepository {
  const CatalogoRepositoryImpl(this._datasource);

  final CatalogoDatasource _datasource;

  @override
  Future<List<CategoriaPlato>> getCategorias() => ErrorMapper.guard(() async {
    final models = await _datasource.getCategorias();
    return models.map(CategoriaPlatoMapper.toEntity).toList(growable: false);
  });

  @override
  Future<CategoriaPlato> createCategoria(CategoriaPlatoDraft draft) =>
      ErrorMapper.guard(
        () async => CategoriaPlatoMapper.toEntity(
          await _datasource.createCategoria(
            CategoriaPlatoRequest.fromDraft(draft),
          ),
        ),
      );

  @override
  Future<CategoriaPlato> updateCategoria(int id, CategoriaPlatoDraft draft) =>
      ErrorMapper.guard(
        () async => CategoriaPlatoMapper.toEntity(
          await _datasource.updateCategoria(
            id,
            CategoriaPlatoRequest.fromDraft(draft),
          ),
        ),
      );

  @override
  Future<void> deleteCategoria(int id) =>
      ErrorMapper.guard(() => _datasource.deleteCategoria(id));

  @override
  Future<PageResult<Plato>> getPlatos({int page = 0, int size = 100}) =>
      ErrorMapper.guard(
        () async => (await _datasource.getPlatos(
          page: page,
          size: size,
        )).map(PlatoMapper.toEntity),
      );

  @override
  Future<PageResult<Plato>> getPlatosByCategoria(
    int idCategoria, {
    int page = 0,
    int size = 100,
  }) => ErrorMapper.guard(
    () async => (await _datasource.getPlatosByCategoria(
      idCategoria,
      page: page,
      size: size,
    )).map(PlatoMapper.toEntity),
  );

  @override
  Future<PageResult<Plato>> searchPlatos({
    String? nombre,
    int? idCategoria,
    bool? disponible,
    int size = 50,
  }) => ErrorMapper.guard(
    () async => (await _datasource.searchPlatos(
      nombre: nombre,
      idCategoria: idCategoria,
      disponible: disponible,
      size: size,
    )).map(PlatoMapper.toEntity),
  );

  @override
  Future<Plato> getPlato(int id) => ErrorMapper.guard(
    () async => PlatoMapper.toEntity(await _datasource.getPlato(id)),
  );

  @override
  Future<Plato> createPlato(PlatoDraft draft) => ErrorMapper.guard(
    () async => PlatoMapper.toEntity(
      await _datasource.createPlato(PlatoRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<Plato> updatePlato(int id, PlatoDraft draft) => ErrorMapper.guard(
    () async => PlatoMapper.toEntity(
      await _datasource.updatePlato(id, PlatoRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<void> deletePlato(int id) =>
      ErrorMapper.guard(() => _datasource.deletePlato(id));
}
