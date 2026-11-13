import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';

class SessionUserCodec {
  const SessionUserCodec({required this.encode, required this.decode});

  final String Function(AuthUser user) encode;
  final AuthUser Function(String json) decode;
}
