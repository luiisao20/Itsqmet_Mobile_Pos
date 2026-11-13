import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  BoxDecoration decorationOf(WidgetTester tester, Type widget) {
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(widget),
        matching: find.byType(DecoratedBox),
      ),
    );
    return box.decoration as BoxDecoration;
  }

  group('AppBadge', () {
    testWidgets('renders label with the variant colors', (tester) async {
      await tester.pumpApp(
        const AppBadge(label: 'Libre', variant: BadgeVariant.success),
      );

      final decoration = decorationOf(tester, AppBadge);
      final text = tester.widget<Text>(find.text('Libre'));

      expect(decoration.color, AppColors.emerald50);
      expect((decoration.border! as Border).top.color, AppColors.emerald200);
      expect(decoration.borderRadius, AppRadius.fullAll);
      expect(text.style!.color, AppColors.emerald800);
      expect(text.style!.fontSize, 12);
      expect(text.style!.fontWeight, FontWeight.w500);
    });

    testWidgets('defaults to the neutral variant', (tester) async {
      await tester.pumpApp(const AppBadge(label: 'Nada'));

      expect(decorationOf(tester, AppBadge).color, AppColors.gray100);
    });

    testWidgets('StatusBadge renders the mapped spec', (tester) async {
      await tester.pumpApp(StatusBadge(StatusBadges.pedido('EN_PREPARACION')));

      expect(find.text('En Preparación'), findsOneWidget);
      expect(decorationOf(tester, AppBadge).color, AppColors.amber50);
    });
  });

  group('RoleChip', () {
    testWidgets('renders the role with its colors', (tester) async {
      await tester.pumpApp(const RoleChip('ADMIN'));

      final decoration = decorationOf(tester, RoleChip);
      final text = tester.widget<Text>(find.text('ADMIN'));

      expect(decoration.color, AppColors.purple100);
      expect(text.style!.color, AppColors.purple800);
      expect(text.style!.fontSize, 11);
    });
  });
}
