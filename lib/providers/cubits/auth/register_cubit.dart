import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_registration_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_identificacion.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_error_message.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({AuthCubit Function()? session})
    : _session = session ?? GetIt.instance.get<AuthCubit>,
      super(const RegisterState());

  static const String requiredMessage =
      'Por favor completa todos los campos requeridos';
  static const String passwordLengthMessage =
      'La contraseña debe tener al menos 6 caracteres';
  static const String errorMessage =
      'Error al registrar la cuenta. Verifica que la cédula y correo no estén registrados.';
  static const int minPasswordLength = 6;

  final AuthCubit Function() _session;

  void setTipoIdentificacion(TipoIdentificacion tipo) => emit(
    RegisterState(tipoIdentificacion: tipo, errorMessage: state.errorMessage),
  );

  Future<void> submit({
    required String identificacion,
    required String razonSocial,
    required String direccion,
    required String telefono,
    required String email,
    required String password,
  }) async {
    if (state.loading) return;
    final tipo = state.tipoIdentificacion;

    if (identificacion.trim().isEmpty ||
        razonSocial.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      emit(
        RegisterState(tipoIdentificacion: tipo, errorMessage: requiredMessage),
      );
      return;
    }
    if (password.length < minPasswordLength) {
      emit(
        RegisterState(
          tipoIdentificacion: tipo,
          errorMessage: passwordLengthMessage,
        ),
      );
      return;
    }

    emit(RegisterState(tipoIdentificacion: tipo, loading: true));
    try {
      await _session().registerCliente(
        ClienteRegistrationDraft(
          tipoIdentificacion: tipo,
          identificacion: identificacion.trim(),
          razonSocial: razonSocial.trim(),
          direccion: _optional(direccion),
          telefono: _optional(telefono),
          email: email.trim().toLowerCase(),
          password: password,
        ),
      );
      if (!isClosed) emit(RegisterState(tipoIdentificacion: tipo));
    } catch (error) {
      if (!isClosed) {
        emit(
          RegisterState(
            tipoIdentificacion: tipo,
            errorMessage: authErrorMessage(error, errorMessage),
          ),
        );
      }
    }
  }

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
