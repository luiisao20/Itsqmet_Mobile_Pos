import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required CatalogoRepository catalogoRepository,
    required AuthRepository authRepository,
  }) : _catalogo = catalogoRepository,
       _auth = authRepository,
       super(const HomeState());

  static const int pageSize = 50;

  final CatalogoRepository _catalogo;
  final AuthRepository _auth;

  Future<void> load() => Future.wait([loadCategorias(), loadPlatos()]);

  Future<void> loadCategorias() async {
    try {
      final categorias = await _catalogo.getCategorias();
      _emit(state.copyWith(categorias: categorias));
    } catch (_) {}
  }

  Future<void> loadPlatos() => _fetchPlatos(state);

  Future<void> filterByCategoria(int? idCategoria) => _fetchPlatos(
    state.copyWith(selectedCategoriaId: () => idCategoria, searchTerm: ''),
  );

  void searchTermChanged(String term) {
    _emit(state.copyWith(searchTerm: term));
  }

  Future<void> search() {
    final term = state.searchTerm.trim();
    if (term.isEmpty) return loadPlatos();
    final idCategoria = state.selectedCategoriaId;
    return _request(
      state,
      () => idCategoria != null
          ? _catalogo.searchPlatos(nombre: term, idCategoria: idCategoria)
          : _catalogo.searchPlatos(nombre: term),
    );
  }

  Future<String?> addToCartDestination() async {
    final rol = await _currentRol();
    return switch (rol) {
      null => Uri(
        path: AppRoutes.login.path,
        queryParameters: {'returnUrl': AppRoutes.clientePedidos.path},
      ).toString(),
      Rol.cliente => AppRoutes.clientePedidos.path,
      Rol.mesero || Rol.admin => AppRoutes.mesas.path,
      Rol.cocina => null,
    };
  }

  Future<String> orderDestination() async {
    final rol = await _currentRol();
    return switch (rol) {
      null => AppRoutes.login.path,
      Rol.cliente => AppRoutes.clientePedidos.path,
      _ => AppRoutes.mesas.path,
    };
  }

  Future<Rol?> _currentRol() async {
    try {
      final user = await _auth.me();
      return user.rol;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchPlatos(HomeState from) {
    final idCategoria = from.selectedCategoriaId;
    return _request(
      from,
      () => idCategoria != null
          ? _catalogo.getPlatosByCategoria(idCategoria, size: pageSize)
          : _catalogo.getPlatos(size: pageSize),
    );
  }

  Future<void> _request(
    HomeState from,
    Future<PageResult<Plato>> Function() request,
  ) async {
    _emit(from.copyWith(loading: true));
    try {
      final page = await request();
      _emit(state.copyWith(platos: page.content, loading: false));
    } catch (_) {
      _emit(state.copyWith(loading: false));
    }
  }

  void _emit(HomeState next) {
    if (!isClosed) emit(next);
  }
}
