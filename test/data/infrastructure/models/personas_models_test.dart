import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/cliente_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/distribuidor_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/insumo_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/usuario_model.dart';

void main() {
  group('UsuarioModel', () {
    test('parses a backend user', () {
      final model = UsuarioModel.fromJson({
        'uuid': 'u-1',
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'cedula': '1712345678',
        'email': 'ana@itsqmet.edu.ec',
        'rol': 'COCINA',
        'activo': true,
        'createdAt': '2025-11-12T10:30:00',
      });

      expect(model.uuid, 'u-1');
      expect(model.cedula, '1712345678');
      expect(model.rol, Rol.cocina);
      expect(model.activo, isTrue);
      expect(model.createdAt, DateTime(2025, 11, 12, 10, 30));
    });

    test('an unknown role falls back to CLIENTE', () {
      expect(
        UsuarioModel.fromJson({'uuid': 'u', 'rol': 'GERENTE'}).rol,
        Rol.cliente,
      );
    });

    test('request omits a null password and keeps the wire role', () {
      final request = UsuarioRequest.fromDraft(
        const UsuarioDraft(
          nombre: 'Ana',
          apellido: 'Pérez',
          cedula: '1712345678',
          email: 'ana@x.com',
          rol: Rol.mesero,
          activo: true,
        ),
      );

      expect(request.toJson(), {
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'cedula': '1712345678',
        'email': 'ana@x.com',
        'rol': 'MESERO',
        'activo': true,
      });
    });

    test('request keeps the password when present', () {
      final request = UsuarioRequest.fromDraft(
        const UsuarioDraft(
          nombre: 'Ana',
          apellido: 'Pérez',
          cedula: '1',
          email: 'a@x.com',
          password: 'secreto',
          rol: Rol.admin,
          activo: false,
        ),
      );

      expect(request.toJson()['password'], 'secreto');
      expect(request.toJson()['activo'], false);
    });
  });

  group('ClienteModel', () {
    test('parses a backend client', () {
      final model = ClienteModel.fromJson({
        'uuid': 'c-1',
        'tipoIdentificacion': 'CONSUMIDOR_FINAL',
        'identificacion': '9999999999',
        'razonSocial': 'Consumidor Final',
        'direccion': 'N/A',
        'telefono': '0990000000',
        'email': 'cf@x.com',
        'activo': true,
        'createdAt': 1731456000,
      });

      expect(model.uuid, 'c-1');
      expect(model.tipoIdentificacion, TipoIdentificacion.consumidorFinal);
      expect(model.razonSocial, 'Consumidor Final');
      expect(model.activo, isTrue);
      expect(model.createdAt!.millisecondsSinceEpoch, 1731456000000);
    });

    test('optionals stay null and unknown id type falls back to CEDULA', () {
      final model = ClienteModel.fromJson({
        'uuid': 'c-2',
        'tipoIdentificacion': 'DNI',
        'identificacion': '1',
        'razonSocial': 'X',
      });

      expect(model.tipoIdentificacion, TipoIdentificacion.cedula);
      expect(model.direccion, isNull);
      expect(model.telefono, isNull);
      expect(model.email, isNull);
      expect(model.activo, isNull);
    });

    test('request omits every null optional', () {
      final request = ClienteRequest.fromDraft(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.pasaporte,
          identificacion: 'AB123',
          razonSocial: 'John Doe',
        ),
      );

      expect(request.toJson(), {
        'tipoIdentificacion': 'PASAPORTE',
        'identificacion': 'AB123',
        'razonSocial': 'John Doe',
      });
    });

    test('request keeps provided optionals', () {
      final request = ClienteRequest.fromDraft(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '1',
          razonSocial: 'X',
          direccion: 'Calle 1',
          telefono: '099',
          email: 'x@x.com',
          password: 'pw',
          activo: false,
        ),
      );

      expect(request.toJson(), {
        'tipoIdentificacion': 'CEDULA',
        'identificacion': '1',
        'razonSocial': 'X',
        'direccion': 'Calle 1',
        'telefono': '099',
        'email': 'x@x.com',
        'password': 'pw',
        'activo': false,
      });
    });
  });

  group('InsumoModel', () {
    test('parses a backend ingredient', () {
      final model = InsumoModel.fromJson({
        'id': 4,
        'nombre': 'Arroz',
        'unidadMedida': 'KG',
        'stockActual': 10.5,
        'stockMinimo': 5,
        'costoPromedio': 1.2,
        'stockBajo': false,
        'createdAt': '2025-11-12T10:30:00',
      });

      expect(model.id, 4);
      expect(model.unidadMedida, UnidadMedida.kg);
      expect(model.stockActual, 10.5);
      expect(model.stockMinimo, 5.0);
      expect(model.costoPromedio, 1.2);
      expect(model.stockBajo, isFalse);
    });

    test('stockBajo stays null when the backend omits it', () {
      final model = InsumoModel.fromJson({
        'id': 4,
        'nombre': 'Arroz',
        'unidadMedida': 'LT',
        'stockActual': 1,
        'stockMinimo': 5,
        'costoPromedio': 1,
      });

      expect(model.stockBajo, isNull);
      expect(model.unidadMedida, UnidadMedida.lt);
    });

    test('an unknown unit falls back to UNIDAD', () {
      expect(
        InsumoModel.fromJson({'id': 1, 'unidadMedida': 'GR'}).unidadMedida,
        UnidadMedida.unidad,
      );
    });

    test('request has all five fields', () {
      final request = InsumoRequest.fromDraft(
        const InsumoDraft(
          nombre: 'Leche',
          unidadMedida: UnidadMedida.lt,
          stockActual: 12,
          stockMinimo: 4,
          costoPromedio: 0.9,
        ),
      );

      expect(request.toJson(), {
        'nombre': 'Leche',
        'unidadMedida': 'LT',
        'stockActual': 12.0,
        'stockMinimo': 4.0,
        'costoPromedio': 0.9,
      });
    });
  });

  group('DistribuidorModel', () {
    test('parses a backend supplier', () {
      final model = DistribuidorModel.fromJson({
        'id': 2,
        'ruc': '1790012345001',
        'razonSocial': 'Distribuidora S.A.',
        'nombreContacto': 'Luis',
        'telefono': '022345678',
        'email': 'ventas@dist.com',
        'direccion': 'Av. Principal',
        'categoriaProveedor': 'Lácteos',
        'createdAt': '2025-11-12T10:30:00',
      });

      expect(model.id, 2);
      expect(model.ruc, '1790012345001');
      expect(model.nombreContacto, 'Luis');
      expect(model.categoriaProveedor, 'Lácteos');
    });

    test('optionals stay null', () {
      final model = DistribuidorModel.fromJson({
        'id': 2,
        'ruc': '1',
        'razonSocial': 'X',
      });

      expect(model.nombreContacto, isNull);
      expect(model.telefono, isNull);
      expect(model.email, isNull);
      expect(model.direccion, isNull);
      expect(model.categoriaProveedor, isNull);
    });

    test('request omits null optionals', () {
      final request = DistribuidorRequest.fromDraft(
        const DistribuidorDraft(ruc: '1', razonSocial: 'X'),
      );

      expect(request.toJson(), {'ruc': '1', 'razonSocial': 'X'});
    });

    test('request keeps provided optionals', () {
      final request = DistribuidorRequest.fromDraft(
        const DistribuidorDraft(
          ruc: '1',
          razonSocial: 'X',
          nombreContacto: 'Luis',
          telefono: '099',
          email: 'e@x.com',
          direccion: 'Calle',
          categoriaProveedor: 'Carnes',
        ),
      );

      expect(request.toJson().keys, hasLength(7));
      expect(request.toJson()['categoriaProveedor'], 'Carnes');
    });
  });
}
