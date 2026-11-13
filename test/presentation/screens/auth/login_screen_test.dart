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

  setUp(() async => services = await AuthTestServices.register());

  tearDown(() => GetIt.instance.reset());

  testWidgets('renders the header, tabs and cliente form', (tester) async {
    await tester.pumpAuthRouter('/login');

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsWidgets);
    expect(
      find.text('Ingresa con tu cuenta de cliente o credenciales de personal'),
      findsOneWidget,
    );
    expect(find.text('Soy Cliente'), findsOneWidget);
    expect(find.text('Personal / Staff'), findsOneWidget);
    expect(find.text('Correo Electrónico o Cédula / RUC'), findsOneWidget);
    expect(find.text('ej: juan.perez@gmail.com o 1718293041'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión como Cliente'), findsOneWidget);
    expect(find.text('¿No tienes cuenta?'), findsOneWidget);
    expect(find.text('Regístrate aquí'), findsOneWidget);
  });

  testWidgets('the staff tab shows the staff form', (tester) async {
    await tester.pumpAuthRouter('/login');

    await tester.tap(find.text('Personal / Staff'));
    await tester.pumpAndSettle();

    expect(find.text('Correo Corporativo'), findsOneWidget);
    expect(find.text('admin@restaurant.com'), findsOneWidget);
    expect(find.text('Contraseña de Acceso'), findsOneWidget);
    expect(find.text('Acceder al Sistema POS'), findsOneWidget);
    expect(find.text('Regístrate aquí'), findsNothing);
  });

  testWidgets('empty fields show the required message', (tester) async {
    await tester.pumpAuthRouter('/login');

    await tester.tap(find.text('Iniciar Sesión como Cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Por favor completa todos los campos'), findsOneWidget);
    verifyZeroInteractions(services.repository);
  });

  testWidgets('invalid staff credentials show the web message', (tester) async {
    when(
      () => services.repository.loginStaff(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const InvalidCredentialsException());
    await tester.pumpAuthRouter('/login');
    await tester.tap(find.text('Personal / Staff'));
    await tester.pumpAndSettle();

    await tester.enterField(LoginScreen.staffEmailKey, 'admin@x.com');
    await tester.enterField(LoginScreen.staffPasswordKey, 'mal');
    await tester.tap(find.text('Acceder al Sistema POS'));
    await tester.pumpAndSettle();

    expect(
      find.text('Credenciales inválidas de personal. Verifica tus datos.'),
      findsOneWidget,
    );
  });

  testWidgets('a staff login redirects to the role home', (tester) async {
    final admin = authUser(rol: Rol.admin);
    when(
      () => services.repository.loginStaff(
        email: 'admin@x.com',
        password: 'secreto',
      ),
    ).thenAnswer((_) async => AuthResult(user: admin, token: validJwt()));
    final router = await tester.pumpAuthRouter('/login');
    await tester.tap(find.text('Personal / Staff'));
    await tester.pumpAndSettle();

    await tester.enterField(LoginScreen.staffEmailKey, ' admin@x.com ');
    await tester.enterField(LoginScreen.staffPasswordKey, 'secreto');
    await tester.tap(find.text('Acceder al Sistema POS'));
    await tester.pumpAndSettle();

    expect(currentPath(router), '/admin');
    expect(find.byType(LoginScreen), findsNothing);
    expect(await services.storage.readToken(), isNotNull);
  });

  testWidgets('a cliente login redirects to the pedidos panel', (tester) async {
    final cliente = authUser(rol: Rol.cliente);
    when(
      () => services.repository.loginCliente(
        login: '1718293041',
        password: 'abc123',
      ),
    ).thenAnswer((_) async => AuthResult(user: cliente, token: validJwt()));
    final router = await tester.pumpAuthRouter('/login');

    await tester.enterField(LoginScreen.clienteLoginKey, '1718293041');
    await tester.enterField(LoginScreen.clientePasswordKey, 'abc123');
    await tester.tap(find.text('Iniciar Sesión como Cliente'));
    await tester.pumpAndSettle();

    expect(currentPath(router), '/cliente/pedidos');
  });

  testWidgets('the register link opens the register screen', (tester) async {
    final router = await tester.pumpAuthRouter('/login');

    await tester.ensureVisible(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();

    expect(currentPath(router), '/register');
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('a restored session never shows the login', (tester) async {
    await services.signIn(authUser(rol: Rol.cocina));

    final router = await tester.pumpAuthRouter('/login');

    expect(currentPath(router), '/cocina');
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('protected routes without session open the login', (
    tester,
  ) async {
    final router = await tester.pumpAuthRouter('/caja');

    expect(currentPath(router), '/login');
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('fits phone and tablet without overflow', (tester) async {
    for (final size in [
      TestScreens.phone,
      TestScreens.tabletPortrait,
      TestScreens.tabletLandscape,
    ]) {
      await tester.pumpAuthRouter('/login', size: size);
      await tester.tap(find.text('Personal / Staff'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
