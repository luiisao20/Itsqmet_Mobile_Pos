import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/not_found/no_page_found_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the Angular not-found copy and styles', (tester) async {
    await tester.pumpApp(const NoPageFoundScreen());

    final code = tester.widget<Text>(find.text('404'));
    expect(code.style?.color, AppColors.emerald300);
    expect(code.style?.fontWeight, FontWeight.w900);
    expect(code.style?.fontSize, 60);

    final title = tester.widget<Text>(find.text('Página No Encontrada'));
    expect(title.style?.color, AppColors.emerald950);
    expect(title.style?.fontWeight, FontWeight.w700);

    final message = tester.widget<Text>(
      find.text(
        'La ruta que buscas no existe o ha sido movida. Regresa al menú principal.',
      ),
    );
    expect(message.style?.color, AppColors.gray400);
    expect(message.textAlign, TextAlign.center);

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.label, 'Volver al Menú');
    expect(button.variant, AppButtonVariant.primary);
    expect(button.size, AppButtonSize.md);
  });

  testWidgets('renders on tablet without overflow', (tester) async {
    await tester.pumpApp(
      const NoPageFoundScreen(),
      size: TestScreens.tabletLandscape,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Página No Encontrada'), findsOneWidget);
  });
}
