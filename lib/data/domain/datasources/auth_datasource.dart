import 'package:itsqmet_mobile_pos/data/infrastructure/models/auth_model.dart';

abstract interface class AuthDatasource {
  Future<AuthSessionModel> loginStaff(LoginRequest request);

  Future<AuthSessionModel> loginCliente(ClienteLoginRequest request);

  Future<AuthSessionModel> registerCliente(ClienteRegistrationRequest request);

  Future<AuthResponseModel> me();

  Future<void> logout();
}
