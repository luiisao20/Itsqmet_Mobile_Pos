import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_error_message.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({AuthCubit Function()? session})
    : _session = session ?? GetIt.instance.get<AuthCubit>,
      super(const LoginState());

  static const String requiredMessage = 'Por favor completa todos los campos';
  static const String staffErrorMessage =
      'Credenciales inválidas de personal. Verifica tus datos.';
  static const String clienteErrorMessage =
      'Credenciales inválidas. Verifica tu correo o cédula y contraseña.';

  final AuthCubit Function() _session;

  void setTab(LoginTab tab) => emit(LoginState(tab: tab));

  Future<void> submitStaff({required String email, required String password}) =>
      _submit(
        identity: email,
        password: password,
        fallback: staffErrorMessage,
        request: (identity) =>
            _session().loginStaff(email: identity, password: password),
      );

  Future<void> submitCliente({
    required String login,
    required String password,
  }) => _submit(
    identity: login,
    password: password,
    fallback: clienteErrorMessage,
    request: (identity) =>
        _session().loginCliente(login: identity, password: password),
  );

  Future<void> _submit({
    required String identity,
    required String password,
    required String fallback,
    required Future<Object?> Function(String identity) request,
  }) async {
    if (state.loading) return;
    final trimmed = identity.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      emit(LoginState(tab: state.tab, errorMessage: requiredMessage));
      return;
    }

    emit(LoginState(tab: state.tab, loading: true));
    try {
      await request(trimmed);
      if (!isClosed) emit(LoginState(tab: state.tab));
    } catch (error) {
      if (!isClosed) {
        emit(
          LoginState(
            tab: state.tab,
            errorMessage: authErrorMessage(error, fallback),
          ),
        );
      }
    }
  }
}
