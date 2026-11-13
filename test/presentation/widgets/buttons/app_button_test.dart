import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  ButtonStyle styleOf(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;

  Color? background(ButtonStyle style, [Set<WidgetState> states = const {}]) =>
      style.backgroundColor!.resolve(states);

  const pressed = {WidgetState.pressed};

  group('AppButton variants', () {
    testWidgets('primary: emerald-600, pressed emerald-700, white text', (
      tester,
    ) async {
      await tester.pumpApp(AppButton(label: 'Guardar', onPressed: () {}));
      final style = styleOf(tester);

      expect(find.text('Guardar'), findsOneWidget);
      expect(background(style), AppColors.emerald600);
      expect(background(style, pressed), AppColors.emerald700);
      expect(style.foregroundColor!.resolve({}), AppColors.white);
    });

    testWidgets('secondary: emerald-50, border emerald-200, text emerald-800', (
      tester,
    ) async {
      await tester.pumpApp(
        AppButton(
          label: 'Editar',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      );
      final style = styleOf(tester);

      expect(background(style), AppColors.emerald50);
      expect(background(style, pressed), AppColors.emerald100);
      expect(style.foregroundColor!.resolve({}), AppColors.emerald800);
      expect(style.side!.resolve({})!.color, AppColors.emerald200);
    });

    testWidgets('outline: transparent, border gray-300, pressed gray-50', (
      tester,
    ) async {
      await tester.pumpApp(
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.outline,
          onPressed: () {},
        ),
      );
      final style = styleOf(tester);

      expect(background(style), Colors.transparent);
      expect(background(style, pressed), AppColors.gray50);
      expect(style.foregroundColor!.resolve({}), AppColors.gray700);
      expect(style.side!.resolve({})!.color, AppColors.gray300);
    });

    testWidgets('danger: rose-600, pressed rose-700, white text', (
      tester,
    ) async {
      await tester.pumpApp(
        AppButton(
          label: 'Eliminar',
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
      );
      final style = styleOf(tester);

      expect(background(style), AppColors.rose600);
      expect(background(style, pressed), AppColors.rose700);
      expect(style.foregroundColor!.resolve({}), AppColors.white);
    });
  });

  group('AppButton sizes', () {
    Future<ButtonStyle> styleFor(
      WidgetTester tester,
      AppButtonSize size,
    ) async {
      await tester.pumpApp(AppButton(label: 'X', size: size, onPressed: () {}));
      return styleOf(tester);
    }

    testWidgets('sm is px10 py6 12px', (tester) async {
      final style = await styleFor(tester, AppButtonSize.sm);
      expect(
        style.padding!.resolve({}),
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      );
      expect(style.textStyle!.resolve({})!.fontSize, 12);
    });

    testWidgets('md is px16 py8 14px', (tester) async {
      final style = await styleFor(tester, AppButtonSize.md);
      expect(
        style.padding!.resolve({}),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      expect(style.textStyle!.resolve({})!.fontSize, 14);
    });

    testWidgets('lg is px20 py10 16px', (tester) async {
      final style = await styleFor(tester, AppButtonSize.lg);
      expect(
        style.padding!.resolve({}),
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      );
      expect(style.textStyle!.resolve({})!.fontSize, 16);
    });
  });

  group('AppButton behaviour', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(AppButton(label: 'Tocar', onPressed: () => taps++));

      await tester.tap(find.byType(AppButton));

      expect(taps, 1);
    });

    testWidgets('is disabled at 50% opacity when onPressed is null', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppButton(label: 'Deshabilitado', onPressed: null),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.5),
        findsOneWidget,
      );
    });

    testWidgets('is fully opaque when enabled', (tester) async {
      await tester.pumpApp(AppButton(label: 'Activo', onPressed: () {}));

      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.5),
        findsNothing,
      );
    });

    testWidgets('loading shows a spinner, the loading label and ignores taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(
          label: 'Guardar',
          loadingLabel: 'Guardando...',
          loading: true,
          onPressed: () => taps++,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Guardando...'), findsOneWidget);
      expect(find.text('Guardar'), findsNothing);

      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('loading without loadingLabel keeps the label', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Guardar', loading: true, onPressed: () {}),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('shows the leading emoji', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Nuevo', leading: Icons.add, onPressed: () {}),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('expand fills the available width', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Ancho', expand: true, onPressed: () {}),
      );

      expect(tester.getSize(find.byType(AppButton)).width, 390);
    });
  });

  group('AppLinkButton', () {
    testWidgets('renders and calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppLinkButton(label: 'Ver más', onPressed: () => taps++),
      );

      await tester.tap(find.byType(AppLinkButton));

      expect(find.text('Ver más'), findsOneWidget);
      expect(taps, 1);
    });
  });
}
