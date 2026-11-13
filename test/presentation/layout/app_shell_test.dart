import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/layout.dart';

import '../../helpers/pump_app.dart';

void main() {
  const drawer = Drawer(child: Text('Menú lateral'));

  group('AppShell', () {
    testWidgets('renders the navbar logo, the child and the app background', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppShell(child: Text('Contenido')),
        withScaffold: false,
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);

      expect(find.text('RESTAURANTEPOS'), findsOneWidget);
      expect(find.text('Contenido'), findsOneWidget);
      expect(scaffold.backgroundColor, AppColors.background);
    });

    testWidgets('shows the actions slot in the navbar', (tester) async {
      await tester.pumpApp(
        const AppShell(navActions: [Text('Perfil')], child: SizedBox()),
        withScaffold: false,
        size: TestScreens.tabletLandscape,
      );

      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('on a phone the menu button opens the drawer', (tester) async {
      await tester.pumpApp(
        const AppShell(drawer: drawer, child: SizedBox()),
        withScaffold: false,
        size: TestScreens.phone,
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Menú lateral'), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Menú lateral'), findsOneWidget);
    });

    testWidgets('on a phone without drawer there is no menu button', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppShell(child: SizedBox()),
        withScaffold: false,
        size: TestScreens.phone,
      );

      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('on a tablet there is no menu button', (tester) async {
      await tester.pumpApp(
        const AppShell(drawer: drawer, child: SizedBox()),
        withScaffold: false,
        size: TestScreens.tabletLandscape,
      );

      expect(find.byIcon(Icons.menu), findsNothing);
    });
  });

  group('AppNavbar', () {
    testWidgets('is 64px tall with an emerald-100 bottom border', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppShell(child: SizedBox()),
        withScaffold: false,
      );

      final navbar = find.byType(AppNavbar);
      final container = tester.widget<Container>(
        find.descendant(of: navbar, matching: find.byType(Container)).first,
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(tester.getSize(navbar).height, 64);
      expect((decoration.border! as Border).bottom.color, AppColors.emerald100);
      expect(decoration.color, AppColors.white.withValues(alpha: 0.95));
    });
  });

  group('AppLogo', () {
    testWidgets('shows the emoji box, wordmark and tagline', (tester) async {
      await tester.pumpApp(const AppLogo());

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.text('RESTAURANTEPOS'), findsOneWidget);
      expect(find.text('SISTEMA GASTRONÓMICO'), findsOneWidget);
    });

    testWidgets('the brand square is 36px emerald-600 with radius 12', (
      tester,
    ) async {
      await tester.pumpApp(const AppLogo());

      final box = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.restaurant),
          matching: find.byType(Container),
        ),
      );
      final decoration = box.decoration! as BoxDecoration;

      expect(tester.getSize(find.byWidget(box)), const Size(36, 36));
      expect(decoration.color, AppColors.emerald600);
      expect(decoration.borderRadius, AppRadius.mdAll);
    });
  });

  group('AppFooter', () {
    testWidgets('shows the copyright year and both caption lines', (
      tester,
    ) async {
      await tester.pumpApp(AppFooter(now: DateTime(2030)));

      expect(
        find.text(
          '© 2030 Restaurante POS - Sistema de Gestión Gastronómica & '
          'Facturación Electrónica',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Actualización en tiempo real vía WebSocket & Cookies de '
          'Sesión Segura',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has a white background and an emerald-100 top border', (
      tester,
    ) async {
      await tester.pumpApp(const AppFooter());

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppFooter),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.color, AppColors.white);
      expect((decoration.border! as Border).top.color, AppColors.emerald100);
    });
  });
}
