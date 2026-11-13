import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

void _expectEnumContract<T extends Enum>({
  required String name,
  required List<T> values,
  required String Function(T) toJson,
  required T Function(String) fromJson,
  required String Function(T) label,
  required List<String> wires,
  required List<String> labels,
}) {
  group(name, () {
    test('wire values', () {
      expect(values.map(toJson).toList(), wires);
    });

    test('labels', () {
      expect(values.map(label).toList(), labels);
    });

    test('fromJson round-trips every value', () {
      for (final value in values) {
        expect(fromJson(toJson(value)), value);
      }
    });

    test('fromJson tolerates case and surrounding whitespace', () {
      expect(fromJson(' ${wires.first.toLowerCase()} '), values.first);
    });

    test('fromJson throws a FormatException for unknown values', () {
      expect(() => fromJson('NO_EXISTE'), throwsFormatException);
      expect(() => fromJson(''), throwsFormatException);
    });
  });
}

void main() {
  _expectEnumContract<Rol>(
    name: 'Rol',
    values: Rol.values,
    toJson: (v) => v.toJson(),
    fromJson: Rol.fromJson,
    label: (v) => v.label,
    wires: ['ADMIN', 'MESERO', 'COCINA', 'CLIENTE'],
    labels: ['Administrador', 'Mesero', 'Cocina', 'Cliente'],
  );
  _expectEnumContract<AreaImpresion>(
    name: 'AreaImpresion',
    values: AreaImpresion.values,
    toJson: (v) => v.toJson(),
    fromJson: AreaImpresion.fromJson,
    label: (v) => v.label,
    wires: ['COCINA', 'BAR', 'CAJA'],
    labels: ['Cocina', 'Bar', 'Caja'],
  );
  _expectEnumContract<EstadoMesa>(
    name: 'EstadoMesa',
    values: EstadoMesa.values,
    toJson: (v) => v.toJson(),
    fromJson: EstadoMesa.fromJson,
    label: (v) => v.label,
    wires: ['LIBRE', 'OCUPADA', 'CUENTA'],
    labels: ['Libre', 'Ocupada', 'Cuenta'],
  );
  _expectEnumContract<EstadoPedido>(
    name: 'EstadoPedido',
    values: EstadoPedido.values,
    toJson: (v) => v.toJson(),
    fromJson: EstadoPedido.fromJson,
    label: (v) => v.label,
    wires: ['ABIERTO', 'EN_PREPARACION', 'SERVIDO', 'FACTURADO', 'ANULADO'],
    labels: ['Abierto', 'En Preparación', 'Servido', 'Facturado', 'Anulado'],
  );
  _expectEnumContract<EstadoDetallePedido>(
    name: 'EstadoDetallePedido',
    values: EstadoDetallePedido.values,
    toJson: (v) => v.toJson(),
    fromJson: EstadoDetallePedido.fromJson,
    label: (v) => v.label,
    wires: ['PENDIENTE', 'IMPRESO', 'LISTO', 'ENTREGADO'],
    labels: ['Pendiente', 'Impreso', 'Listo', 'Entregado'],
  );
  _expectEnumContract<TipoPedido>(
    name: 'TipoPedido',
    values: TipoPedido.values,
    toJson: (v) => v.toJson(),
    fromJson: TipoPedido.fromJson,
    label: (v) => v.label,
    wires: ['SALON', 'LLEVAR'],
    labels: ['Salón', 'Para Llevar'],
  );
  _expectEnumContract<EstadoFactura>(
    name: 'EstadoFactura',
    values: EstadoFactura.values,
    toJson: (v) => v.toJson(),
    fromJson: EstadoFactura.fromJson,
    label: (v) => v.label,
    wires: ['EMITIDA', 'ANULADA'],
    labels: ['Emitida', 'Anulada'],
  );
  _expectEnumContract<MetodoPago>(
    name: 'MetodoPago',
    values: MetodoPago.values,
    toJson: (v) => v.toJson(),
    fromJson: MetodoPago.fromJson,
    label: (v) => v.label,
    wires: ['EFECTIVO', 'TRANSFERENCIA', 'TARJETA'],
    labels: ['Efectivo', 'Transferencia', 'Tarjeta'],
  );
  _expectEnumContract<UnidadMedida>(
    name: 'UnidadMedida',
    values: UnidadMedida.values,
    toJson: (v) => v.toJson(),
    fromJson: UnidadMedida.fromJson,
    label: (v) => v.label,
    wires: ['KG', 'LT', 'UNIDAD'],
    labels: ['KG (Kilogramos)', 'LT (Litros)', 'UNIDAD (Piezas)'],
  );
  _expectEnumContract<TipoIdentificacion>(
    name: 'TipoIdentificacion',
    values: TipoIdentificacion.values,
    toJson: (v) => v.toJson(),
    fromJson: TipoIdentificacion.fromJson,
    label: (v) => v.label,
    wires: ['CEDULA', 'RUC', 'PASAPORTE', 'CONSUMIDOR_FINAL'],
    labels: ['Cédula', 'RUC', 'Pasaporte', 'Consumidor Final'],
  );

  test('FormatException message names the enum and the value', () {
    expect(
      () => EstadoPedido.fromJson('XYZ'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('EstadoPedido'), contains('XYZ')),
        ),
      ),
    );
  });
}
