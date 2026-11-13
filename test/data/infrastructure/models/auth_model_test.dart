import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/auth_model.dart';

void main() {
  group('AuthResponseModel.fromJson', () {
    test('parses a staff login response', () {
      final model = AuthResponseModel.fromJson({
        'uuid': 'u-1',
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'email': 'ana@itsqmet.edu.ec',
        'rol': 'MESERO',
        'activo': true,
        'message': 'Login exitoso',
      });

      expect(model.uuid, 'u-1');
      expect(model.nombre, 'Ana');
      expect(model.apellido, 'Pérez');
      expect(model.email, 'ana@itsqmet.edu.ec');
      expect(model.rol, Rol.mesero);
      expect(model.activo, isTrue);
      expect(model.message, 'Login exitoso');
    });

    test('a client response has no apellido', () {
      final model = AuthResponseModel.fromJson({
        'uuid': 'c-1',
        'nombre': 'Juan Cliente',
        'apellido': null,
        'email': 'juan@x.com',
        'rol': 'CLIENTE',
        'activo': true,
      });

      expect(model.apellido, '');
      expect(model.rol, Rol.cliente);
      expect(model.message, isNull);
    });

    test('an unknown role falls back to the least privileged role', () {
      final model = AuthResponseModel.fromJson({
        'uuid': 'u-9',
        'nombre': 'X',
        'email': 'x@x.com',
        'rol': 'SUPER_ADMIN',
      });

      expect(model.rol, Rol.cliente);
      expect(model.activo, isTrue);
    });

    test('toJson mirrors the backend shape and round-trips', () {
      final model = AuthResponseModel.fromJson({
        'uuid': 'u-1',
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'email': 'ana@x.com',
        'rol': 'ADMIN',
        'activo': false,
      });

      final json = model.toJson();

      expect(json, {
        'uuid': 'u-1',
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'email': 'ana@x.com',
        'rol': 'ADMIN',
        'activo': false,
      });
      expect(AuthResponseModel.fromJson(json).rol, Rol.admin);
    });
  });

  group('requests', () {
    test('LoginRequest', () {
      expect(const LoginRequest(email: 'a@b.c', password: 'pw').toJson(), {
        'email': 'a@b.c',
        'password': 'pw',
      });
    });

    test('ClienteLoginRequest', () {
      expect(
        const ClienteLoginRequest(login: '1712345678', password: 'pw').toJson(),
        {'login': '1712345678', 'password': 'pw'},
      );
    });

    test('ClienteRegistrationRequest omits null optionals', () {
      final request = ClienteRegistrationRequest.fromDraft(
        const ClienteRegistrationDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '1712345678',
          razonSocial: 'Juan Cliente',
          email: 'juan@x.com',
          password: 'secreto',
        ),
      );

      expect(request.toJson(), {
        'tipoIdentificacion': 'CEDULA',
        'identificacion': '1712345678',
        'razonSocial': 'Juan Cliente',
        'email': 'juan@x.com',
        'password': 'secreto',
      });
    });

    test('ClienteRegistrationRequest keeps provided optionals', () {
      final request = ClienteRegistrationRequest.fromDraft(
        const ClienteRegistrationDraft(
          tipoIdentificacion: TipoIdentificacion.ruc,
          identificacion: '1790012345001',
          razonSocial: 'Empresa',
          direccion: 'Av. Siempre Viva',
          telefono: '0991234567',
          email: 'e@x.com',
          password: 'secreto',
        ),
      );

      expect(request.toJson()['direccion'], 'Av. Siempre Viva');
      expect(request.toJson()['telefono'], '0991234567');
      expect(request.toJson()['tipoIdentificacion'], 'RUC');
    });
  });
}
