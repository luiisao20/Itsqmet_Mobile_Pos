import 'package:itsqmet_mobile_pos/data/domain/entities/auth_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_registration_draft.dart';

abstract interface class AuthRepository {
  Future<AuthResult> loginStaff({
    required String email,
    required String password,
  });

  Future<AuthResult> loginCliente({
    required String login,
    required String password,
  });

  Future<AuthResult> registerCliente(ClienteRegistrationDraft draft);

  Future<AuthUser> me();

  Future<void> logout();
}
