import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('shows label, required marker and hint', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: 'Correo', required: true, hint: 'a@b.com'),
      );

      expect(find.text('Correo *'), findsOneWidget);
      expect(find.text('a@b.com'), findsOneWidget);
    });

    testWidgets('does not show the marker when not required', (tester) async {
      await tester.pumpApp(const AppTextField(label: 'Nombre'));

      expect(find.text('Nombre'), findsOneWidget);
      expect(find.textContaining('*'), findsNothing);
    });

    testWidgets('renders errorText in rose-600 11px', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: 'Cédula', errorText: 'Campo requerido'),
      );

      final error = tester.widget<Text>(find.text('Campo requerido'));

      expect(error.style!.color, AppColors.rose600);
      expect(error.style!.fontSize, 11);
    });

    testWidgets('reports changes through onChanged', (tester) async {
      String? value;
      await tester.pumpApp(AppTextField(onChanged: (v) => value = v));

      await tester.enterText(find.byType(TextField), 'hola');

      expect(value, 'hola');
    });

    testWidgets('obscure fields can toggle visibility', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: 'Contraseña', obscureText: true),
      );

      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;

      expect(obscured(), isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(obscured(), isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('shows the prefix emoji', (tester) async {
      await tester.pumpApp(
        const AppTextField(prefixIcon: Icons.email_outlined),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('uses the web input look (filled, radius 12, emerald focus)', (
      tester,
    ) async {
      await tester.pumpApp(const AppTextField());

      final field = tester.widget<TextField>(find.byType(TextField));
      final decoration = field.decoration!.applyDefaults(
        AppTheme.light.inputDecorationTheme,
      );
      final border = decoration.focusedBorder! as OutlineInputBorder;

      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, AppColors.gray50.withValues(alpha: 0.5));
      expect(border.borderSide.color, AppColors.emerald500);
      expect(border.borderRadius, AppRadius.mdAll);
    });
  });

  group('AppSearchField', () {
    testWidgets('shows the search icon and submits the query', (tester) async {
      String? submitted;
      await tester.pumpApp(
        AppSearchField(onSubmitted: (value) => submitted = value),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ceviche');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submitted, 'ceviche');
    });
  });

  group('AppDropdownField', () {
    testWidgets('shows the hint and reports the selected value', (
      tester,
    ) async {
      String? selected;
      await tester.pumpApp(
        AppDropdownField<String>(
          label: 'Rol',
          hint: 'Seleccione',
          items: const [
            DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
            DropdownMenuItem(value: 'MESERO', child: Text('MESERO')),
          ],
          onChanged: (value) => selected = value,
        ),
      );

      expect(find.text('Rol'), findsOneWidget);
      expect(find.text('Seleccione'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MESERO').last);
      await tester.pumpAndSettle();

      expect(selected, 'MESERO');
    });

    testWidgets('shows the current value', (tester) async {
      await tester.pumpApp(
        AppDropdownField<String>(
          value: 'ADMIN',
          items: const [DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN'))],
          onChanged: (_) {},
        ),
      );

      expect(find.text('ADMIN'), findsOneWidget);
    });
  });

  group('AppCheckboxField', () {
    testWidgets('tapping the row toggles the value', (tester) async {
      bool? value;
      await tester.pumpApp(
        AppCheckboxField(
          label: 'Aplica IVA',
          value: false,
          onChanged: (v) => value = v,
        ),
      );

      await tester.tap(find.text('Aplica IVA'));

      expect(value, isTrue);
    });

    testWidgets('tapping the checkbox reports the new value', (tester) async {
      bool? value;
      await tester.pumpApp(
        AppCheckboxField(
          label: 'Activo',
          value: true,
          onChanged: (v) => value = v,
        ),
      );

      await tester.tap(find.byType(Checkbox));

      expect(value, isFalse);
    });
  });
}
