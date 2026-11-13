import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  Widget cell(Widget child) =>
      Center(child: SizedBox(width: 280, height: 360, child: child));

  for (final entry in {
    'phone': TestScreens.phone,
    'tablet': TestScreens.tabletLandscape,
  }.entries) {
    testWidgets('shows plato data and adds to cart on ${entry.key}', (
      tester,
    ) async {
      final added = <Plato>[];
      final plato = platoFixture(precioUnitario: 8.5);

      await tester.pumpApp(
        cell(PlatoCard(plato: plato, onAddToCart: added.add)),
        size: entry.value,
      );

      expect(find.text('Ceviche'), findsOneWidget);
      expect(find.text('Con limón'), findsOneWidget);
      expect(find.text('Entradas'), findsOneWidget);
      expect(find.text('Disponible'), findsOneWidget);
      expect(find.text('Precio'), findsOneWidget);
      expect(find.text('\$8.50'), findsOneWidget);
      expect(find.text('Sin imagen'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('+ Agregar'));

      expect(added, [plato]);
    });
  }

  testWidgets('uses the default description when there is none', (
    tester,
  ) async {
    await tester.pumpApp(
      cell(PlatoCard(plato: platoFixture(descripcion: null))),
    );

    expect(
      find.text('Plato preparado al momento con insumos frescos'),
      findsOneWidget,
    );
  });

  testWidgets('uses the default description when it is empty', (tester) async {
    await tester.pumpApp(cell(PlatoCard(plato: platoFixture(descripcion: ''))));

    expect(
      find.text('Plato preparado al momento con insumos frescos'),
      findsOneWidget,
    );
  });

  testWidgets('hides the category chip when there is no category', (
    tester,
  ) async {
    await tester.pumpApp(
      cell(PlatoCard(plato: platoFixture(nombreCategoria: null))),
    );

    expect(find.text('Entradas'), findsNothing);
  });

  testWidgets('unavailable plato shows Agotado and cannot be added', (
    tester,
  ) async {
    final added = <Plato>[];

    await tester.pumpApp(
      cell(
        PlatoCard(
          plato: platoFixture(disponible: false),
          onAddToCart: added.add,
        ),
      ),
    );

    expect(find.text('Agotado'), findsOneWidget);
    expect(find.text('Disponible'), findsNothing);
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.text('+ Agregar'), warnIfMissed: false);
    expect(added, isEmpty);
  });

  testWidgets('without callback the button is disabled', (tester) async {
    await tester.pumpApp(cell(PlatoCard(plato: platoFixture())));

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('renders a network image when urlImagen is present', (
    tester,
  ) async {
    await tester.pumpApp(
      cell(PlatoCard(plato: platoFixture(urlImagen: 'https://img.test/a.png'))),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://img.test/a.png');
    expect(image.fit, BoxFit.cover);
  });

  testWidgets('card has white surface, emerald-100 border and radius 16', (
    tester,
  ) async {
    await tester.pumpApp(cell(PlatoCard(plato: platoFixture())));

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(PlatoCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.white);
    expect(decoration.borderRadius, AppRadius.lgAll);
    expect((decoration.border! as Border).top.color, AppColors.emerald100);
    expect(decoration.boxShadow, AppShadows.xs);
  });

  testWidgets('price uses bold emerald-800 18px text', (tester) async {
    await tester.pumpApp(cell(PlatoCard(plato: platoFixture())));

    final price = tester.widget<Text>(find.text('\$8.50'));
    expect(price.style!.fontSize, 18);
    expect(price.style!.fontWeight, FontWeight.w700);
    expect(price.style!.color, AppColors.emerald800);
  });

  testWidgets('works without a bounded height', (tester) async {
    await tester.pumpApp(
      SingleChildScrollView(
        child: SizedBox(width: 300, child: PlatoCard(plato: platoFixture())),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('+ Agregar'), findsOneWidget);
  });
}
