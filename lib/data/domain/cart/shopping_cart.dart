import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/cart/cart_item.dart';
import 'package:itsqmet_mobile_pos/data/domain/cart/cart_totals.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/detalle_pedido_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/plato.dart';

class ShoppingCart extends Equatable {
  const ShoppingCart([List<CartItem> items = const []]) : _items = items;

  final List<CartItem> _items;

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get length => _items.length;

  CartTotals get totals => CartTotals.fromItems(_items);

  ShoppingCart add(Plato plato) {
    final index = _items.indexWhere((item) => item.plato.id == plato.id);
    if (index == -1) {
      return ShoppingCart([..._items, CartItem(plato: plato, cantidad: 1)]);
    }
    return changeQuantity(index, 1);
  }

  ShoppingCart changeQuantity(int index, int delta) {
    if (!_isValid(index)) return this;
    final current = _items[index];
    final cantidad = current.cantidad + delta;
    final next = [..._items];
    if (cantidad <= 0) {
      next.removeAt(index);
    } else {
      next[index] = current.copyWith(cantidad: cantidad);
    }
    return ShoppingCart(next);
  }

  ShoppingCart remove(int index) {
    if (!_isValid(index)) return this;
    return ShoppingCart([..._items]..removeAt(index));
  }

  ShoppingCart updateNotes(int index, String notes) {
    if (!_isValid(index)) return this;
    final next = [..._items];
    next[index] = _items[index].copyWith(notasPreparacion: notes);
    return ShoppingCart(next);
  }

  ShoppingCart clear() => const ShoppingCart();

  List<DetallePedidoDraft> toDetalles() {
    return _items
        .map((item) {
          final notes = item.notasPreparacion.trim();
          return DetallePedidoDraft(
            idPlato: item.plato.id,
            cantidad: item.cantidad,
            notasPreparacion: notes.isEmpty ? null : notes,
          );
        })
        .toList(growable: false);
  }

  bool _isValid(int index) => index >= 0 && index < _items.length;

  @override
  List<Object?> get props => [_items];
}
