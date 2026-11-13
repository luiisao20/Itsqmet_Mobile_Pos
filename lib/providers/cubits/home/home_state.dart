part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.categorias = const [],
    this.platos = const [],
    this.loading = true,
    this.selectedCategoriaId,
    this.searchTerm = '',
  });

  final List<CategoriaPlato> categorias;
  final List<Plato> platos;
  final bool loading;
  final int? selectedCategoriaId;
  final String searchTerm;

  HomeState copyWith({
    List<CategoriaPlato>? categorias,
    List<Plato>? platos,
    bool? loading,
    int? Function()? selectedCategoriaId,
    String? searchTerm,
  }) {
    return HomeState(
      categorias: categorias ?? this.categorias,
      platos: platos ?? this.platos,
      loading: loading ?? this.loading,
      selectedCategoriaId: selectedCategoriaId != null
          ? selectedCategoriaId()
          : this.selectedCategoriaId,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [
    categorias,
    platos,
    loading,
    selectedCategoriaId,
    searchTerm,
  ];
}
