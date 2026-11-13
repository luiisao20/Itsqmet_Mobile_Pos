import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

class MesasState extends Equatable {
  const MesasState({
    this.loadingMesas = true,
    this.mesas = const [],
    this.platos = const [],
    this.selectedMesa,
    this.comanda = const ShoppingCart(),
    this.observaciones = '',
    this.loadingOrder = false,
    this.errorMessage,
    this.comandaError,
  });

  final bool loadingMesas;
  final List<Mesa> mesas;
  final List<Plato> platos;
  final Mesa? selectedMesa;
  final ShoppingCart comanda;
  final String observaciones;
  final bool loadingOrder;
  final String? errorMessage;
  final String? comandaError;

  MesasState copyWith({
    bool? loadingMesas,
    List<Mesa>? mesas,
    List<Plato>? platos,
    Mesa? selectedMesa,
    bool clearSelectedMesa = false,
    ShoppingCart? comanda,
    String? observaciones,
    bool? loadingOrder,
    String? errorMessage,
    bool clearError = false,
    String? comandaError,
    bool clearComandaError = false,
  }) {
    return MesasState(
      loadingMesas: loadingMesas ?? this.loadingMesas,
      mesas: mesas ?? this.mesas,
      platos: platos ?? this.platos,
      selectedMesa: clearSelectedMesa
          ? null
          : selectedMesa ?? this.selectedMesa,
      comanda: comanda ?? this.comanda,
      observaciones: observaciones ?? this.observaciones,
      loadingOrder: loadingOrder ?? this.loadingOrder,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      comandaError: clearComandaError
          ? null
          : comandaError ?? this.comandaError,
    );
  }

  @override
  List<Object?> get props => [
    loadingMesas,
    mesas,
    platos,
    selectedMesa,
    comanda,
    observaciones,
    loadingOrder,
    errorMessage,
    comandaError,
  ];
}
