import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders emoji, title and message', (tester) async {
      await tester.pumpApp(
        const EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'Sin pedidos',
          message: 'Aún no hay pedidos',
        ),
      );

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('Sin pedidos'), findsOneWidget);
      expect(find.text('Aún no hay pedidos'), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('action button calls onAction when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        EmptyState(
          title: 'Sin platos',
          actionLabel: 'Crear plato',
          onAction: () => taps++,
        ),
      );

      await tester.tap(find.text('Crear plato'));

      expect(taps, 1);
    });

    testWidgets('the badge is a 48px emerald-50 circle', (tester) async {
      await tester.pumpApp(const EmptyState(title: 'Vacío'));

      final badge = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.restaurant),
          matching: find.byType(Container),
        ),
      );
      final decoration = badge.decoration! as BoxDecoration;

      expect(decoration.color, AppColors.emerald50);
      expect(decoration.shape, BoxShape.circle);
      expect(tester.getSize(find.byWidget(badge)), const Size(48, 48));
    });
  });

  group('LoadingView', () {
    testWidgets('shows the default text and a spinner', (tester) async {
      await tester.pumpApp(const LoadingView());

      expect(find.text('Cargando ...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('accepts a custom message', (tester) async {
      await tester.pumpApp(const LoadingView(message: 'Cargando mesas ...'));

      expect(find.text('Cargando mesas ...'), findsOneWidget);
    });
  });

  group('ErrorBanner', () {
    testWidgets('renders the message with the rose style', (tester) async {
      await tester.pumpApp(const ErrorBanner(message: 'Algo salió mal'));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ErrorBanner),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      final text = tester.widget<Text>(find.text('Algo salió mal'));

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(decoration.color, AppColors.rose50);
      expect((decoration.border! as Border).top.color, AppColors.rose200);
      expect(decoration.borderRadius, AppRadius.mdAll);
      expect(text.style!.color, AppColors.rose700);
    });
  });

  group('SuccessBanner', () {
    testWidgets('renders the message with the emerald style', (tester) async {
      await tester.pumpApp(const SuccessBanner(message: 'Pedido creado'));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SuccessBanner),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(find.text('Pedido creado'), findsOneWidget);
      expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
      expect(decoration.color, AppColors.emerald50);
      expect((decoration.border! as Border).top.color, AppColors.emerald300);
      expect(decoration.borderRadius, AppRadius.lgAll);
    });
  });

  group('SkeletonBox', () {
    testWidgets('has the requested size and gray color', (tester) async {
      await tester.pumpApp(
        const Align(
          alignment: Alignment.topLeft,
          child: SkeletonBox(width: 120, height: 20),
        ),
      );

      expect(tester.getSize(find.byType(SkeletonBox)), const Size(120, 20));
    });

    testWidgets('pulses its opacity between 1 and 0.5', (tester) async {
      await tester.pumpApp(const SkeletonBox(width: 50, height: 10));

      double opacity() => tester
          .widget<FadeTransition>(find.byType(FadeTransition).last)
          .opacity
          .value;

      expect(opacity(), 1);

      await tester.pump(const Duration(seconds: 1));
      expect(opacity(), closeTo(0.5, 0.05));
    });
  });
}
