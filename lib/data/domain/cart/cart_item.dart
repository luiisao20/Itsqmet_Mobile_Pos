import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/plato.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.plato,
    required this.cantidad,
    this.notasPreparacion = '',
  });

  final Plato plato;
  final int cantidad;
  final String notasPreparacion;

  double get subtotal => plato.precioUnitario * cantidad;

  CartItem copyWith({Plato? plato, int? cantidad, String? notasPreparacion}) {
    return CartItem(
      plato: plato ?? this.plato,
      cantidad: cantidad ?? this.cantidad,
      notasPreparacion: notasPreparacion ?? this.notasPreparacion,
    );
  }

  @override
  List<Object?> get props => [plato, cantidad, notasPreparacion];
}
