import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/login_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/register_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';
import '../../../providers/cubits/auth/auth_fixtures.dart';
import 'auth_test_app.dart';

void main() {
  late AuthTestServices services;

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

  setUp(() async => services = await AuthTestServices.register());

  tearDown(() => GetIt.instance.reset());

  Future<void> fillRequired(
    WidgetTester tester, {
    String password = 'abc123',
  }) async {
    await tester.enterField(RegisterScreen.identificacionKey, '1718293041');
    await tester.enterField(RegisterScreen.razonSocialKey, 'Juan Pérez');
    await tester.enterField(RegisterScreen.emailKey, 'Juan@X.com');
    await tester.enterField(RegisterScreen.passwordKey, password);
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Registrar y Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar y Continuar'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the header and every field', (tester) async {
    await tester.pumpAuthRouter('/register');

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byIcon(Icons.edit_note), findsOneWidget);
    expect(find.text('Registro de Cliente'), findsOneWidget);
    expect(
      find.text(
        'Crea tu cuenta para realizar pedidos para llevar y gestionar tus facturas',
      ),
      findsOneWidget,
    );
    expect(find.text('Tipo de Identificación *'), findsOneWidget);
    expect(find.text('Cédula'), findsOneWidget);
    expect(find.text('Número de Documento *'), findsOneWidget);
    expect(find.text('ej: 1718293041'), findsOneWidget);
    expect(find.text('Nombres Completos o Razón Social *'), findsOneWidget);
    expect(find.text('ej: Juan Fernando Pérez'), findsOneWidget);
    expect(find.text('Correo Electrónico *'), findsOneWidget);
    expect(find.text('juan.perez@gmail.com'), findsOneWidget);
    expect(find.text('Teléfono Móvil'), findsOneWidget);
    expect(find.text('0998765432'), findsOneWidget);
    expect(find.text('Dirección Domiciliaria'), findsOneWidget);
    expect(find.text('Av. Amazonas y República'), findsOneWidget);
    expect(find.text('Contraseña (mínimo 6 caracteres) *'), findsOneWidget);
    expect(find.text('Registrar y Continuar'), findsOneWidget);
    expect(find.text('¿Ya tienes cuenta?'), findsOneWidget);
    expect(find.text('Inicia sesión aquí'), findsOneWidget);
  });

  testWidgets('a short password shows the length message', (tester) async {
    await tester.pumpAuthRouter('/register');

    await fillRequired(tester, password: '123');
    await tapSubmit(tester);

    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );
    verifyZeroInteractions(services.repository);
  });

  testWidgets('missing fields show the required message', (tester) async {
    await tester.pumpAuthRouter('/register');

    await tapSubmit(tester);

    expect(
      find.text('Por favor completa todos los campos requeridos'),
      findsOneWidget,
    );
  });

  testWidgets('a failure shows the web message', (tester) async {
    when(() => services.repository.registerCliente(any()))
        .thenThrow(const BadRequestException());
    await tester.pumpAuthRouter('/register');

    await fillRequired(tester);
    await tapSubmit(tester);

    expect(
      find.text(
        'Error al registrar la cuenta. Verifica que la cédula y correo no estén registrados.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('registers with the chosen type and opens the pedidos panel', (
    tester,
  ) async {
    when(() => services.repository.registerCliente(any())).thenAnswer(
      (_) async => AuthResult(
        user: authUser(rol: Rol.cliente),
        token: validJwt(),
      ),
    );
    final router = await tester.pumpAuthRouter('/register');

    await tester.tap(find.text('Cédula'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RUC').last);
    await tester.pumpAndSettle();
    await fillRequired(tester);
    await tester.enterField(RegisterScreen.telefonoKey, ' 0998765432 ');
    await tapSubmit(tester);

    final draft =
        verify(() => services.repository.registerCliente(captureAny()))
                .captured
                .single
            as ClienteRegistrationDraft;
    expect(draft.tipoIdentificacion, TipoIdentificacion.ruc);
    expect(draft.email, 'juan@x.com');
    expect(draft.telefono, '0998765432');
    expect(draft.direccion, isNull);
    expect(currentPath(router), '/cliente/pedidos');
  });

  testWidgets('the login link opens the login screen', (tester) async {
    final router = await tester.pumpAuthRouter('/register');

    await tester.ensureVisible(find.text('Inicia sesión aquí'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inicia sesión aquí'));
    await tester.pumpAndSettle();

    expect(currentPath(router), '/login');
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('fits phone and tablet without overflow', (tester) async {
    for (final size in [
      TestScreens.phone,
      TestScreens.tabletPortrait,
      TestScreens.tabletLandscape,
    ]) {
      await tester.pumpAuthRouter('/register', size: size);
      expect(tester.takeException(), isNull);
    }
  });
}
