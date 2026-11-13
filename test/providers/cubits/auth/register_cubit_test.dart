import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import 'auth_fixtures.dart';

void main() {
  late MockAuthRepository repository;
  late AuthCubit auth;

  setUpAll(() {
    registerFallbackValue(
      const ClienteRegistrationDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '1',
        razonSocial: 'x',
        email: 'x@x.com',
        password: '123456',
      ),
    );
  });

  setUp(() {
    repository = MockAuthRepository();
    auth = AuthCubit(
      repository: repository,
      storage: InMemorySessionStorage(),
      userCodec: testCodec,
    );
  });

  tearDown(() => auth.close());

  RegisterCubit build() => RegisterCubit(session: () => auth);

  Future<void> submit(
    RegisterCubit cubit, {
    String identificacion = '1718293041',
    String razonSocial = 'Juan Pérez',
    String direccion = '',
    String telefono = '',
    String email = 'juan@x.com',
    String password = 'abc123',
  }) => cubit.submit(
    identificacion: identificacion,
    razonSocial: razonSocial,
    direccion: direccion,
    telefono: telefono,
    email: email,
    password: password,
  );

  test('starts with CEDULA, not loading and without error', () {
    final cubit = build();
    addTearDown(cubit.close);

    expect(cubit.state, const RegisterState());
    expect(cubit.state.tipoIdentificacion, TipoIdentificacion.cedula);
  });

  test('changes the identification type', () {
    final cubit = build();
    addTearDown(cubit.close);

    cubit.setTipoIdentificacion(TipoIdentificacion.ruc);

    expect(cubit.state.tipoIdentificacion, TipoIdentificacion.ruc);
  });

  group('validation', () {
    for (final field in [
      'identificacion',
      'razonSocial',
      'email',
      'password',
    ]) {
      test('$field is required', () async {
        final cubit = build();
        addTearDown(cubit.close);

        await switch (field) {
          'identificacion' => submit(cubit, identificacion: '  '),
          'razonSocial' => submit(cubit, razonSocial: ''),
          'email' => submit(cubit, email: ' '),
          _ => submit(cubit, password: ''),
        };

        expect(
          cubit.state.errorMessage,
          'Por favor completa todos los campos requeridos',
        );
        verifyZeroInteractions(repository);
      });
    }

    test('password needs at least 6 characters', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await submit(cubit, password: '12345');

      expect(
        cubit.state.errorMessage,
        'La contraseña debe tener al menos 6 caracteres',
      );
      verifyZeroInteractions(repository);
    });
  });

  test('sends the normalized draft and authenticates', () async {
    final cliente = authUser(rol: Rol.cliente);
    when(() => repository.registerCliente(any()))
        .thenAnswer((_) async => AuthResult(user: cliente, token: validJwt()));
    final cubit = build();
    addTearDown(cubit.close);
    cubit.setTipoIdentificacion(TipoIdentificacion.pasaporte);

    await submit(
      cubit,
      identificacion: ' AB123 ',
      razonSocial: ' Juan Pérez ',
      direccion: '  Av. Amazonas ',
      telefono: '   ',
      email: ' Juan@X.COM ',
      password: ' abc123',
    );

    final draft =
        verify(() => repository.registerCliente(captureAny())).captured.single
            as ClienteRegistrationDraft;
    expect(
      draft,
      const ClienteRegistrationDraft(
        tipoIdentificacion: TipoIdentificacion.pasaporte,
        identificacion: 'AB123',
        razonSocial: 'Juan Pérez',
        direccion: 'Av. Amazonas',
        email: 'juan@x.com',
        password: ' abc123',
      ),
    );
    expect(auth.state, AuthState.authenticated(cliente));
    expect(cubit.state.loading, isFalse);
  });

  test('a failure shows the web fallback message', () async {
    when(() => repository.registerCliente(any()))
        .thenThrow(const BadRequestException('duplicado'));
    final cubit = build();
    addTearDown(cubit.close);

    await submit(cubit);

    expect(
      cubit.state.errorMessage,
      'Error al registrar la cuenta. Verifica que la cédula y correo no estén registrados.',
    );
    expect(cubit.state.loading, isFalse);
  });

  test('a timeout shows the timeout message', () async {
    when(() => repository.registerCliente(any()))
        .thenThrow(const RequestTimeoutException());
    final cubit = build();
    addTearDown(cubit.close);

    await submit(cubit);

    expect(
      cubit.state.errorMessage,
      'El servidor tardó demasiado en responder',
    );
  });
}
