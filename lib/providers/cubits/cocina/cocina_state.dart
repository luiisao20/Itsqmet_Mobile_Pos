import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

enum CocinaFiltro {
  todos(null),
  abierto(EstadoPedido.abierto),
  enPreparacion(EstadoPedido.enPreparacion),
  servido(EstadoPedido.servido);

  const CocinaFiltro(this.estado);

  final EstadoPedido? estado;
}

class CocinaError extends Equatable {
  const CocinaError(this.id, this.message);

  final int id;
  final String message;

  @override
  List<Object?> get props => [id, message];
}

class CocinaState extends Equatable {
  const CocinaState({
    this.loading = false,
    this.pedidos = const [],
    this.filtro = CocinaFiltro.todos,
    this.error,
  });

  final bool loading;
  final List<Pedido> pedidos;
  final CocinaFiltro filtro;
  final CocinaError? error;

  List<Pedido> get filteredPedidos {
    final estado = filtro.estado;
    if (estado == null) return pedidos;
    return pedidos.where((pedido) => pedido.estado == estado).toList();
  }

  CocinaState copyWith({
    bool? loading,
    List<Pedido>? pedidos,
    CocinaFiltro? filtro,
    CocinaError? error,
  }) {
    return CocinaState(
      loading: loading ?? this.loading,
      pedidos: pedidos ?? this.pedidos,
      filtro: filtro ?? this.filtro,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loading, pedidos, filtro, error];
}
