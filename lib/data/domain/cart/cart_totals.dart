import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/cart/cart_item.dart';

class CartTotals extends Equatable {
  const CartTotals({
    required this.subtotal,
    required this.iva,
    required this.total,
  });

  factory CartTotals.fromItems(Iterable<CartItem> items) {
    var subtotal = 0.0;
    var baseIva = 0.0;
    for (final item in items) {
      subtotal += item.subtotal;
      if (item.plato.aplicaIva) baseIva += item.subtotal;
    }
    final iva = _round2(baseIva * ivaRate);
    return CartTotals(
      subtotal: subtotal,
      iva: iva,
      total: _round2(subtotal + iva),
    );
  }

  static const double ivaRate = 0.15;

  final double subtotal;
  final double iva;
  final double total;

  static double _round2(double value) => double.parse(value.toStringAsFixed(2));

  @override
  List<Object?> get props => [subtotal, iva, total];
}
