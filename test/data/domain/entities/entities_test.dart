import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('AuthUser', () {
    test('fullName joins nombre and apellido and trims', () {
      expect(authUser().fullName, 'Ana Pérez');
      expect(authUser(apellido: '').fullName, 'Ana');
    });

    test('initial is the uppercase first letter of the name', () {
      expect(authUser(nombre: 'ana').initial, 'A');
    });

    test('initial falls back to the email, then to ?', () {
      expect(authUser(nombre: ' ', email: 'zeta@x.com').initial, 'Z');
      expect(authUser(nombre: '', email: '').initial, '?');
    });

    test('has value equality', () {
      expect(authUser(), authUser());
      expect(authUser(), isNot(authUser(activo: false)));
    });
  });

  group('AuthResult', () {
    test('has value equality', () {
      expect(
        AuthResult(user: authUser(), token: 't'),
        AuthResult(user: authUser(), token: 't'),
      );
      expect(
        AuthResult(user: authUser(), token: 't'),
        isNot(AuthResult(user: authUser(), token: 'other')),
      );
    });

    test('never prints the token in toString', () {
      final text = AuthResult(user: authUser(), token: 'secret.jwt').toString();

      expect(text, isNot(contains('secret.jwt')));
    });
  });

  group('Pedido', () {
    test('total sums the subtotals and itemsCount sums the quantities', () {
      final pedido = pedidoFixture(
        detalles: [
          detalleFixture(cantidad: 2, precioUnitario: 5, subtotal: 10),
          detalleFixture(
            idPlato: 8,
            cantidad: 3,
            precioUnitario: 2.5,
            subtotal: 7.5,
          ),
        ],
      );

      expect(pedido.total, 17.5);
      expect(pedido.itemsCount, 5);
    });

    test('an empty order has zero total and zero items', () {
      final pedido = pedidoFixture(detalles: const []);

      expect(pedido.total, 0);
      expect(pedido.itemsCount, 0);
    });

    test('has value equality including the details', () {
      expect(pedidoFixture(), pedidoFixture());
      expect(
        pedidoFixture(),
        isNot(pedidoFixture(detalles: [detalleFixture(cantidad: 9)])),
      );
    });
  });

  group('value equality', () {
    test('catalog and operation entities', () {
      expect(categoriaFixture(), categoriaFixture());
      expect(categoriaFixture(), isNot(categoriaFixture(nombre: 'Otra')));
      expect(platoFixture(), platoFixture());
      expect(platoFixture(), isNot(platoFixture(disponible: false)));
      expect(mesaFixture(), mesaFixture());
      expect(mesaFixture(), isNot(mesaFixture(estado: EstadoMesa.ocupada)));
      expect(detalleFixture(), detalleFixture());
      expect(facturaFixture(), facturaFixture());
      expect(facturaFixture(), isNot(facturaFixture(total: 1)));
      expect(pagoFixture(), pagoFixture());
      expect(pagoFixture(), isNot(pagoFixture(monto: 1)));
    });

    test('people and inventory entities', () {
      expect(usuarioFixture(), usuarioFixture());
      expect(usuarioFixture(), isNot(usuarioFixture(activo: false)));
      expect(clienteFixture(), clienteFixture());
      expect(clienteFixture(), isNot(clienteFixture(razonSocial: 'Otro')));
      expect(insumoFixture(), insumoFixture());
      expect(insumoFixture(), isNot(insumoFixture(stockActual: 1)));
      expect(distribuidorFixture(), distribuidorFixture());
      expect(distribuidorFixture(), isNot(distribuidorFixture(ruc: '0')));
    });
  });

  group('PageResult', () {
    test('single wraps a list as one page', () {
      final page = PageResult<int>.single([1, 2, 3]);

      expect(page.content, [1, 2, 3]);
      expect(page.totalElements, 3);
      expect(page.totalPages, 1);
      expect(page.number, 0);
      expect(page.size, 3);
      expect(page.first, isTrue);
      expect(page.last, isTrue);
      expect(page.empty, isFalse);
      expect(page.hasNext, isFalse);
    });

    test('single with no items is an empty page', () {
      final page = PageResult<int>.single(const []);

      expect(page.empty, isTrue);
      expect(page.totalPages, 0);
      expect(page.totalElements, 0);
    });

    test('map transforms the content and keeps the paging metadata', () {
      const page = PageResult<int>(
        content: [1, 2],
        totalElements: 10,
        totalPages: 5,
        number: 1,
        size: 2,
        first: false,
        last: false,
        empty: false,
      );

      final mapped = page.map((value) => 'n$value');

      expect(mapped.content, ['n1', 'n2']);
      expect(mapped.totalElements, 10);
      expect(mapped.totalPages, 5);
      expect(mapped.number, 1);
      expect(mapped.hasNext, isTrue);
    });

    test('has value equality', () {
      expect(PageResult<int>.single([1]), PageResult<int>.single([1]));
      expect(PageResult<int>.single([1]), isNot(PageResult<int>.single([2])));
    });
  });

  group('drafts', () {
    test('are value objects', () {
      expect(
        const MesaDraft(numeroMesa: 1, capacidad: 4),
        const MesaDraft(numeroMesa: 1, capacidad: 4),
      );
      expect(
        const DetallePedidoDraft(idPlato: 1, cantidad: 2),
        isNot(const DetallePedidoDraft(idPlato: 1, cantidad: 3)),
      );
      expect(
        const PedidoDraft(
          tipo: TipoPedido.salon,
          detalles: [DetallePedidoDraft(idPlato: 1, cantidad: 2)],
        ),
        const PedidoDraft(
          tipo: TipoPedido.salon,
          detalles: [DetallePedidoDraft(idPlato: 1, cantidad: 2)],
        ),
      );
      expect(
        const PagoDraft(
          idFactura: 1,
          metodoPago: MetodoPago.efectivo,
          monto: 5,
        ),
        isNot(
          const PagoDraft(
            idFactura: 1,
            metodoPago: MetodoPago.tarjeta,
            monto: 5,
          ),
        ),
      );
    });
  });
}
