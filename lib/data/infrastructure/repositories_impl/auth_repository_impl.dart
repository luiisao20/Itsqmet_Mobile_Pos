import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/auth_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_registration_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/auth_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/auth_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<AuthResult> loginStaff({
    required String email,
    required String password,
  }) => ErrorMapper.guard(() async {
    final session = await _datasource.loginStaff(
      LoginRequest(email: email, password: password),
    );
    return _toResult(session);
  });

  @override
  Future<AuthResult> loginCliente({
    required String login,
    required String password,
  }) => ErrorMapper.guard(() async {
    final session = await _datasource.loginCliente(
      ClienteLoginRequest(login: login, password: password),
    );
    return _toResult(session);
  });

  @override
  Future<AuthResult> registerCliente(ClienteRegistrationDraft draft) =>
      ErrorMapper.guard(() async {
        final session = await _datasource.registerCliente(
          ClienteRegistrationRequest.fromDraft(draft),
        );
        return _toResult(session);
      });

  @override
  Future<AuthUser> me() => ErrorMapper.guard(
    () async => AuthMapper.toEntity(await _datasource.me()),
  );

  @override
  Future<void> logout() => ErrorMapper.guard(_datasource.logout);

  static AuthResult _toResult(AuthSessionModel session) =>
      AuthResult(user: AuthMapper.toEntity(session.user), token: session.token);
}
