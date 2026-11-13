import 'dart:convert';

import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

String jwtWithExp(DateTime? exp) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final payload = <String, Object?>{'sub': 'ana@itsqmet.edu.ec'};
  if (exp != null) payload['exp'] = exp.millisecondsSinceEpoch ~/ 1000;
  return '${part({'alg': 'HS256'})}.${part(payload)}.firma';
}

String validJwt() => jwtWithExp(DateTime.now().add(const Duration(hours: 2)));

final SessionUserCodec testCodec = SessionUserCodec(
  encode: (user) => jsonEncode({
    'uuid': user.uuid,
    'nombre': user.nombre,
    'apellido': user.apellido,
    'email': user.email,
    'rol': user.rol.toJson(),
    'activo': user.activo,
  }),
  decode: (json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AuthUser(
      uuid: map['uuid'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      email: map['email'] as String,
      rol: Rol.fromJson(map['rol'] as String),
      activo: map['activo'] as bool,
    );
  },
);
