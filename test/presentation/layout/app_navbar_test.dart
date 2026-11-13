import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_navbar.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/login_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../screens/auth/auth_test_app.dart';

const List<String> allLinks = [
  'Menú Digital',
  'Para Llevar / Mis Pedidos',
  'Mesas & Salón',
  'Caja & Facturación',
  'Monitor Cocina',
  'Administración',
];

final Map<Rol?, List<String>> linksByRol = {
  null: ['Menú Digital'],
  Rol.cliente: ['Menú Digital', 'Para Llevar / Mis Pedidos'],
  Rol.mesero: [
    'Menú Digital',
    'Mesas & Salón',
    'Caja & Facturación',
    'Monitor Cocina',
  ],
  Rol.cocina: ['Menú Digital', 'Monitor Cocina'],
  Rol.admin: [
    'Menú Digital',
    'Mesas & Salón',
    'Caja & Facturación',
    'Monitor Cocina',
    'Administración',
  ],
};

Finder inNavbar(Finder finder) =>
    find.descendant(of: find.byType(AppNavbar), matching: finder);

Finder inMobileMenu(Finder finder) =>
    find.descendant(of: find.byKey(AppNavbar.mobileMenuKey), matching: finder);

void main() {
  late AuthTestServices services;

  setUp(() async => services = await AuthTestServices.register());

  tearDown(() => GetIt.instance.reset());

  group('tablet', () {
    for (final entry in linksByRol.entries) {
      testWidgets('links for ${entry.key?.name ?? 'guest'}', (tester) async {
        if (entry.key != null) {
          await services.signIn(authUser(rol: entry.key!));
        }

        await tester.pumpAuthRouter('/', size: TestScreens.tabletLandscape);

        for (final link in allLinks) {
          expect(
            inNavbar(find.text(link)),
            entry.value.contains(link) ? findsOneWidget : findsNothing,
            reason: link,
          );
        }
        expect(inNavbar(find.byIcon(Icons.menu)), findsNothing);
      });
    }

    testWidgets('role links use Material icons', (tester) async {
      await services.signIn(authUser(rol: Rol.admin));

      await tester.pumpAuthRouter('/', size: TestScreens.tabletLandscape);

      expect(inNavbar(find.byIcon(Icons.table_restaurant_outlined)), findsOne);
      expect(inNavbar(find.byIcon(Icons.credit_card)), findsOneWidget);
      expect(inNavbar(find.byIcon(Icons.soup_kitchen_outlined)), findsOne);
      expect(inNavbar(find.byIcon(Icons.settings_outlined)), findsOneWidget);
    });

    testWidgets('guest buttons open login and register', (tester) async {
      final router = await tester.pumpAuthRouter(
        '/',
        size: TestScreens.tabletLandscape,
      );

      expect(inNavbar(find.text('Iniciar Sesión')), findsOneWidget);
      await tester.tap(inNavbar(find.text('Crear Cuenta Cliente')));
      await tester.pumpAndSettle();
      expect(currentPath(router), '/register');

      await tester.tap(inNavbar(find.text('Iniciar Sesión')));
      await tester.pumpAndSettle();
      expect(currentPath(router), '/login');
    });

    testWidgets('a link navigates and is highlighted when active', (
      tester,
    ) async {
      await services.signIn(authUser(rol: Rol.mesero));
      final router = await tester.pumpAuthRouter(
        '/',
        size: TestScreens.tabletLandscape,
      );

      await tester.ensureVisible(inNavbar(find.text('Caja & Facturación')));
      await tester.pumpAndSettle();
      await tester.tap(inNavbar(find.text('Caja & Facturación')));
      await tester.pumpAndSettle();

      expect(currentPath(router), '/caja');
      final active = tester.widget<Text>(
        inNavbar(find.text('Caja & Facturación')),
      );
      final inactive = tester.widget<Text>(inNavbar(find.text('Menú Digital')));
      expect(active.style?.color, AppColors.emerald800);
      expect(inactive.style?.color, AppColors.gray600);
    });

    testWidgets('the user menu shows the profile and logs out', (tester) async {
      when(() => services.repository.logout()).thenAnswer((_) async {});
      await services.signIn(
        authUser(
          nombre: 'Ana',
          apellido: 'Pérez',
          email: 'ana@itsqmet.edu.ec',
          rol: Rol.admin,
        ),
      );
      final router = await tester.pumpAuthRouter(
        '/admin',
        size: TestScreens.tabletLandscape,
      );

      expect(inNavbar(find.text('A')), findsOneWidget);
      expect(inNavbar(find.text('Ana')), findsOneWidget);
      expect(inNavbar(find.text('ADMIN')), findsOneWidget);

      await tester.tap(find.byKey(AppNavbar.userMenuKey));
      await tester.pumpAndSettle();

      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('ana@itsqmet.edu.ec'), findsOneWidget);
      expect(find.text('Gestión del Sistema'), findsOneWidget);
      expect(find.text('Mis Pedidos y Facturas'), findsNothing);

      await tester.tap(find.text('Cerrar Sesión'));
      await tester.pumpAndSettle();

      verify(() => services.repository.logout()).called(1);
      expect(await services.storage.readToken(), isNull);
      expect(currentPath(router), '/login');
      expect(inNavbar(find.text('Crear Cuenta Cliente')), findsOneWidget);
    });

    testWidgets('the cliente menu opens the pedidos panel', (tester) async {
      await services.signIn(authUser(rol: Rol.cliente));
      final router = await tester.pumpAuthRouter(
        '/',
        size: TestScreens.tabletLandscape,
      );

      await tester.tap(find.byKey(AppNavbar.userMenuKey));
      await tester.pumpAndSettle();
      expect(find.text('Gestión del Sistema'), findsNothing);
      await tester.tap(find.text('Mis Pedidos y Facturas'));
      await tester.pumpAndSettle();

      expect(currentPath(router), '/cliente/pedidos');
    });

    testWidgets('the user name is hidden below the lg breakpoint', (
      tester,
    ) async {
      await services.signIn(authUser(nombre: 'Ana', rol: Rol.admin));

      await tester.pumpAuthRouter('/', size: TestScreens.tabletPortrait);

      expect(find.byKey(AppNavbar.userMenuKey), findsOneWidget);
      expect(inNavbar(find.text('Ana')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('phone', () {
    testWidgets('links live in the hamburger menu', (tester) async {
      await services.signIn(authUser(rol: Rol.mesero));
      await tester.pumpAuthRouter('/');

      expect(inNavbar(find.text('Mesas & Salón')), findsNothing);
      expect(find.byKey(AppNavbar.mobileMenuKey), findsNothing);

      await tester.tap(inNavbar(find.byIcon(Icons.menu)));
      await tester.pumpAndSettle();

      for (final link in allLinks) {
        expect(
          inMobileMenu(find.text(link)),
          linksByRol[Rol.mesero]!.contains(link)
              ? findsOneWidget
              : findsNothing,
          reason: link,
        );
      }
    });

    testWidgets('a guest can open register from the menu', (tester) async {
      final router = await tester.pumpAuthRouter('/');

      await tester.tap(inNavbar(find.byIcon(Icons.menu)));
      await tester.pumpAndSettle();
      expect(inMobileMenu(find.text('Iniciar Sesión')), findsOneWidget);

      await tester.tap(inMobileMenu(find.text('Registrarse')));
      await tester.pumpAndSettle();

      expect(currentPath(router), '/register');
      expect(find.byKey(AppNavbar.mobileMenuKey), findsNothing);
    });

    testWidgets('a link closes the menu and navigates', (tester) async {
      await services.signIn(authUser(rol: Rol.cocina));
      final router = await tester.pumpAuthRouter('/');

      await tester.tap(inNavbar(find.byIcon(Icons.menu)));
      await tester.pumpAndSettle();
      await tester.tap(inMobileMenu(find.text('Monitor Cocina')));
      await tester.pumpAndSettle();

      expect(currentPath(router), '/cocina');
      expect(find.byKey(AppNavbar.mobileMenuKey), findsNothing);
    });

    testWidgets('shows the user and logs out', (tester) async {
      when(() => services.repository.logout()).thenAnswer((_) async {});
      await services.signIn(
        authUser(nombre: 'Luis', email: 'luis@x.com', rol: Rol.mesero),
      );
      final router = await tester.pumpAuthRouter('/mesas');

      await tester.tap(inNavbar(find.byIcon(Icons.menu)));
      await tester.pumpAndSettle();
      expect(inMobileMenu(find.text('Luis')), findsOneWidget);
      expect(inMobileMenu(find.text('luis@x.com')), findsOneWidget);

      await tester.tap(inMobileMenu(find.text('Cerrar Sesión')));
      await tester.pumpAndSettle();

      expect(currentPath(router), '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(AppNavbar.mobileMenuKey), findsNothing);
    });
  });

  testWidgets('an expired session updates the navbar and opens the login', (
    tester,
  ) async {
    await services.signIn(authUser(rol: Rol.mesero));
    final router = await tester.pumpAuthRouter(
      '/caja',
      size: TestScreens.tabletLandscape,
    );
    expect(find.byKey(AppNavbar.userMenuKey), findsOneWidget);

    services.expired
      ..notifyExpired()
      ..notifyExpired();
    await tester.pumpAndSettle();

    expect(currentPath(router), '/login');
    expect(find.byKey(AppNavbar.userMenuKey), findsNothing);
    expect(inNavbar(find.text('Crear Cuenta Cliente')), findsOneWidget);
  });
}
