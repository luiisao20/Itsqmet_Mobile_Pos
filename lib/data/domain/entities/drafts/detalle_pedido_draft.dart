import 'package:equatable/equatable.dart';

class DetallePedidoDraft extends Equatable {
  const DetallePedidoDraft({
    required this.idPlato,
    required this.cantidad,
    this.notasPreparacion,
  });

  final int idPlato;
  final int cantidad;
  final String? notasPreparacion;

  @override
  List<Object?> get props => [idPlato, cantidad, notasPreparacion];
}
