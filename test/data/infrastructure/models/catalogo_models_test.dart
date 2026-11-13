import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/categoria_plato_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/mesa_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/plato_model.dart';

void main() {
  group('CategoriaPlatoModel', () {
    test('parses a backend category', () {
      final model = CategoriaPlatoModel.fromJson({
        'id': 1,
        'nombre': 'Entradas',
        'areaImpresion': 'COCINA',
        'ordenVisual': 2,
        'createdAt': '2025-11-12T10:30:00',
      });

      expect(model.id, 1);
      expect(model.nombre, 'Entradas');
      expect(model.areaImpresion, AreaImpresion.cocina);
      expect(model.ordenVisual, 2);
      expect(model.createdAt, DateTime(2025, 11, 12, 10, 30));
    });

    test('is tolerant: string ids, missing optionals, unknown enum', () {
      final model = CategoriaPlatoModel.fromJson({
        'id': '7',
        'nombre': 'Bebidas',
        'areaImpresion': 'DESCONOCIDA',
      });

      expect(model.id, 7);
      expect(model.areaImpresion, AreaImpresion.cocina);
      expect(model.ordenVisual, isNull);
      expect(model.createdAt, isNull);
    });

    test('request serializes the wire enum and omits nulls', () {
      final request = CategoriaPlatoRequest.fromDraft(
        const CategoriaPlatoDraft(
          nombre: 'Bar',
          areaImpresion: AreaImpresion.bar,
        ),
      );

      expect(request.toJson(), {'nombre': 'Bar', 'areaImpresion': 'BAR'});
    });

    test('request keeps ordenVisual when present', () {
      final request = CategoriaPlatoRequest.fromDraft(
        const CategoriaPlatoDraft(
          nombre: 'Bar',
          areaImpresion: AreaImpresion.bar,
          ordenVisual: 3,
        ),
      );

      expect(request.toJson()['ordenVisual'], 3);
    });
  });

  group('PlatoModel', () {
    test('parses a backend dish (BigDecimal as number)', () {
      final model = PlatoModel.fromJson({
        'id': 10,
        'idCategoria': 1,
        'nombreCategoria': 'Entradas',
        'nombre': 'Ceviche',
        'descripcion': 'Con limón',
        'precioUnitario': 8.5,
        'aplicaIva': true,
        'disponible': false,
        'urlImagen': 'https://img/ceviche.png',
        'createdAt': 1731456000.123456789,
      });

      expect(model.id, 10);
      expect(model.idCategoria, 1);
      expect(model.nombreCategoria, 'Entradas');
      expect(model.precioUnitario, 8.5);
      expect(model.aplicaIva, isTrue);
      expect(model.disponible, isFalse);
      expect(model.urlImagen, 'https://img/ceviche.png');
      expect(model.createdAt!.millisecondsSinceEpoch, 1731456000123);
    });

    test('accepts integer and string prices', () {
      expect(
        PlatoModel.fromJson({'id': 1, 'precioUnitario': 3}).precioUnitario,
        3.0,
      );
      expect(
        PlatoModel.fromJson({'id': 1, 'precioUnitario': '4.25'}).precioUnitario,
        4.25,
      );
    });

    test('defaults: not available is false only when sent', () {
      final model = PlatoModel.fromJson({'id': 1, 'nombre': 'X'});

      expect(model.disponible, isTrue);
      expect(model.aplicaIva, isFalse);
      expect(model.precioUnitario, 0);
      expect(model.descripcion, isNull);
    });

    test('request omits null optionals', () {
      final request = PlatoRequest.fromDraft(
        const PlatoDraft(
          idCategoria: 1,
          nombre: 'Ceviche',
          precioUnitario: 8.5,
          aplicaIva: true,
          disponible: true,
        ),
      );

      expect(request.toJson(), {
        'idCategoria': 1,
        'nombre': 'Ceviche',
        'precioUnitario': 8.5,
        'aplicaIva': true,
        'disponible': true,
      });
    });

    test('request keeps description and image when present', () {
      final request = PlatoRequest.fromDraft(
        const PlatoDraft(
          idCategoria: 1,
          nombre: 'Ceviche',
          descripcion: 'Con limón',
          precioUnitario: 8.5,
          aplicaIva: false,
          disponible: false,
          urlImagen: 'http://x/y.png',
        ),
      );

      expect(request.toJson()['descripcion'], 'Con limón');
      expect(request.toJson()['urlImagen'], 'http://x/y.png');
      expect(request.toJson()['disponible'], false);
    });
  });

  group('MesaModel', () {
    test('parses a backend table', () {
      final model = MesaModel.fromJson({
        'id': 3,
        'numeroMesa': 3,
        'capacidad': 4,
        'ubicacion': 'Terraza',
        'estado': 'OCUPADA',
        'createdAt': '2025-11-12T15:30:00Z',
      });

      expect(model.id, 3);
      expect(model.numeroMesa, 3);
      expect(model.capacidad, 4);
      expect(model.ubicacion, 'Terraza');
      expect(model.estado, EstadoMesa.ocupada);
      expect(
        model.createdAt!.isAtSameMomentAs(DateTime.utc(2025, 11, 12, 15, 30)),
        isTrue,
      );
    });

    test('an unknown state falls back to LIBRE', () {
      expect(
        MesaModel.fromJson({'id': 1, 'estado': 'EN_LIMPIEZA'}).estado,
        EstadoMesa.libre,
      );
    });

    test('request omits null ubicacion/estado', () {
      final request = MesaRequest.fromDraft(
        const MesaDraft(numeroMesa: 5, capacidad: 2),
      );

      expect(request.toJson(), {'numeroMesa': 5, 'capacidad': 2});
    });

    test('request serializes estado as wire value', () {
      final request = MesaRequest.fromDraft(
        const MesaDraft(
          numeroMesa: 5,
          capacidad: 2,
          ubicacion: 'Salón',
          estado: EstadoMesa.cuenta,
        ),
      );

      expect(request.toJson(), {
        'numeroMesa': 5,
        'capacidad': 2,
        'ubicacion': 'Salón',
        'estado': 'CUENTA',
      });
    });
  });
}
