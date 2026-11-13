import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final ceviche = platoFixture(id: 1, precioUnitario: 8.5, aplicaIva: true);
  final agua = platoFixture(
    id: 2,
    nombre: 'Agua',
    precioUnitario: 1.25,
    aplicaIva: false,
  );

  group('CartItem', () {
    test('subtotal is precioUnitario times cantidad', () {
      final item = CartItem(plato: ceviche, cantidad: 3);

      expect(item.subtotal, closeTo(25.5, 1e-9));
      expect(item.notasPreparacion, '');
    });

    test('copyWith replaces only the given fields', () {
      final item = CartItem(plato: ceviche, cantidad: 1);

      final updated = item.copyWith(cantidad: 4, notasPreparacion: 'sin sal');

      expect(updated.plato, ceviche);
      expect(updated.cantidad, 4);
      expect(updated.notasPreparacion, 'sin sal');
      expect(item.cantidad, 1);
    });

    test('items with the same values are equal', () {
      expect(
        CartItem(plato: ceviche, cantidad: 2, notasPreparacion: 'x'),
        CartItem(plato: ceviche, cantidad: 2, notasPreparacion: 'x'),
      );
    });
  });

  group('CartTotals', () {
    test('empty cart has zero totals', () {
      final totals = CartTotals.fromItems(const []);

      expect(totals, const CartTotals(subtotal: 0, iva: 0, total: 0));
    });

    test('IVA 15% applies only to items whose plato has aplicaIva', () {
      final totals = CartTotals.fromItems([
        CartItem(plato: ceviche, cantidad: 2),
        CartItem(plato: agua, cantidad: 4),
      ]);

      expect(totals.subtotal, closeTo(22, 1e-9));
      expect(totals.iva, 2.55);
      expect(totals.total, 24.55);
    });

    test('no IVA when no plato applies it', () {
      final totals = CartTotals.fromItems([CartItem(plato: agua, cantidad: 3)]);

      expect(totals.iva, 0);
      expect(totals.total, 3.75);
    });

    test('IVA and total are rounded to 2 decimals like toFixed(2)', () {
      final plato = platoFixture(id: 3, precioUnitario: 1.11, aplicaIva: true);

      final totals = CartTotals.fromItems([
        CartItem(plato: plato, cantidad: 1),
      ]);

      expect(totals.iva, 0.17);
      expect(totals.total, 1.28);
    });

    test('subtotal is not rounded, matching the web', () {
      final plato = platoFixture(id: 4, precioUnitario: 0.1, aplicaIva: false);

      final totals = CartTotals.fromItems([
        CartItem(plato: plato, cantidad: 3),
      ]);

      expect(totals.subtotal, 0.1 * 3);
      expect(totals.total, 0.3);
    });

    test('ivaRate is 0.15', () {
      expect(CartTotals.ivaRate, 0.15);
    });
  });

  group('ShoppingCart', () {
    test('starts empty', () {
      const cart = ShoppingCart();

      expect(cart.items, isEmpty);
      expect(cart.isEmpty, isTrue);
      expect(cart.length, 0);
      expect(cart.totals, const CartTotals(subtotal: 0, iva: 0, total: 0));
    });

    test('add appends a new plato with cantidad 1 and empty notes', () {
      final cart = const ShoppingCart().add(ceviche);

      expect(cart.items, [CartItem(plato: ceviche, cantidad: 1)]);
    });

    test('add increments cantidad when the plato is already in the cart', () {
      final cart = const ShoppingCart().add(ceviche).add(agua).add(ceviche);

      expect(cart.items, [
        CartItem(plato: ceviche, cantidad: 2),
        CartItem(plato: agua, cantidad: 1),
      ]);
      expect(cart.length, 2);
    });

    test('add does not mutate the previous cart', () {
      final first = const ShoppingCart().add(ceviche);

      first.add(ceviche);

      expect(first.items.single.cantidad, 1);
    });

    test('changeQuantity adds delta to the item at index', () {
      final cart = const ShoppingCart().add(ceviche).changeQuantity(0, 2);

      expect(cart.items.single.cantidad, 3);
    });

    test('changeQuantity removes the item when cantidad reaches 0', () {
      final cart = const ShoppingCart()
          .add(ceviche)
          .add(agua)
          .changeQuantity(0, -1);

      expect(cart.items, [CartItem(plato: agua, cantidad: 1)]);
    });

    test('changeQuantity with an invalid index returns an equal cart', () {
      final cart = const ShoppingCart().add(ceviche);

      expect(cart.changeQuantity(5, 1), cart);
      expect(cart.changeQuantity(-1, 1), cart);
    });

    test('remove deletes the item at index', () {
      final cart = const ShoppingCart().add(ceviche).add(agua).remove(0);

      expect(cart.items, [CartItem(plato: agua, cantidad: 1)]);
    });

    test('remove with an invalid index returns an equal cart', () {
      final cart = const ShoppingCart().add(ceviche);

      expect(cart.remove(3), cart);
    });

    test('updateNotes sets notasPreparacion of the item at index', () {
      final cart = const ShoppingCart()
          .add(ceviche)
          .updateNotes(0, 'sin cebolla');

      expect(cart.items.single.notasPreparacion, 'sin cebolla');
    });

    test('updateNotes with an invalid index returns an equal cart', () {
      final cart = const ShoppingCart().add(ceviche);

      expect(cart.updateNotes(2, 'x'), cart);
    });

    test('clear empties the cart', () {
      final cart = const ShoppingCart().add(ceviche).clear();

      expect(cart.isEmpty, isTrue);
    });

    test('totals are computed from the items', () {
      final cart = const ShoppingCart().add(ceviche).add(ceviche).add(agua);

      expect(cart.totals.subtotal, closeTo(18.25, 1e-9));
      expect(cart.totals.iva, 2.55);
      expect(cart.totals.total, 20.8);
    });

    test('toDetalles maps items to drafts with trimmed notes or null', () {
      final cart = const ShoppingCart()
          .add(ceviche)
          .add(ceviche)
          .add(agua)
          .updateNotes(0, '  sin sal  ')
          .updateNotes(1, '   ');

      expect(cart.toDetalles(), const [
        DetallePedidoDraft(
          idPlato: 1,
          cantidad: 2,
          notasPreparacion: 'sin sal',
        ),
        DetallePedidoDraft(idPlato: 2, cantidad: 1),
      ]);
    });

    test('items list cannot be modified from outside', () {
      final cart = const ShoppingCart().add(ceviche);

      expect(
        () => cart.items.add(CartItem(plato: agua, cantidad: 1)),
        throwsUnsupportedError,
      );
    });
  });
}
