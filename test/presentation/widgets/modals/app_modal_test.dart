import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpOpener(
    WidgetTester tester,
    Size size,
    void Function(BuildContext context) onOpen,
  ) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => onOpen(context),
            child: const Text('Abrir'),
          ),
        ),
      ),
      size: size,
    );
  }

  Future<void> openAppModal(WidgetTester tester, Size size) async {
    await pumpOpener(tester, size, (context) {
      showAppModal<void>(
        context: context,
        title: 'Título',
        body: const Text('Cuerpo'),
        footer: const Text('Pie'),
      );
    });
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  group('showAppModal', () {
    testWidgets('uses a centered Dialog on tablets', (tester) async {
      await openAppModal(tester, TestScreens.tabletLandscape);

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Cuerpo'), findsOneWidget);
      expect(find.text('Pie'), findsOneWidget);
    });

    testWidgets('limits the tablet dialog to 512px wide', (tester) async {
      await openAppModal(tester, TestScreens.tabletLandscape);

      final content = find
          .descendant(of: find.byType(Dialog), matching: find.byType(Container))
          .first;

      expect(tester.getSize(content).width, 512);
      expect(tester.getCenter(content).dx, 1024 / 2);
    });

    testWidgets('uses a modal bottom sheet on phones', (tester) async {
      await openAppModal(tester, TestScreens.phone);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Cuerpo'), findsOneWidget);
      expect(find.text('Pie'), findsOneWidget);
    });

    testWidgets('the phone bottom sheet is anchored to the bottom', (
      tester,
    ) async {
      await openAppModal(tester, TestScreens.phone);

      expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, 844);
      expect(tester.getSize(find.byType(BottomSheet)).width, 390);
    });

    testWidgets('lifts the phone sheet content above the keyboard', (
      tester,
    ) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);

      await openAppModal(tester, TestScreens.phone);

      expect(
        tester.getBottomLeft(find.text('Pie')).dy,
        lessThanOrEqualTo(844 - 300),
      );
    });

    testWidgets('the close button dismisses the modal', (tester) async {
      await openAppModal(tester, TestScreens.tabletLandscape);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('tapping the barrier dismisses the tablet dialog', (
      tester,
    ) async {
      await openAppModal(tester, TestScreens.tabletLandscape);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('closeAppModal returns a result to the caller', (tester) async {
      int? result;
      await pumpOpener(tester, TestScreens.tabletLandscape, (context) async {
        result = await showAppModal<int>(
          context: context,
          title: 'Elegir',
          body: const Text('Cuerpo'),
          footer: Builder(
            builder: (inner) => AppButton(
              label: 'Aceptar',
              onPressed: () => closeAppModal<int>(inner, 42),
            ),
          ),
        );
      });

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      expect(result, 42);
    });

    testWidgets('dialog barrier uses black 40% and header uses emerald tint', (
      tester,
    ) async {
      await openAppModal(tester, TestScreens.tabletLandscape);

      final barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(barrier.color, AppColors.modalBarrier);

      final header = tester.widget<Container>(
        find
            .ancestor(of: find.text('Título'), matching: find.byType(Container))
            .first,
      );
      final decoration = header.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.emerald50.withValues(alpha: 0.5));
    });
  });

  group('showConfirmDialog', () {
    Future<bool?> runConfirm(
      WidgetTester tester,
      Size size,
      Finder target, {
      bool danger = false,
    }) async {
      bool? result;
      await pumpOpener(tester, size, (context) async {
        result = await showConfirmDialog(
          context,
          title: 'Eliminar plato',
          message: '¿Seguro que desea eliminarlo?',
          confirmLabel: 'Eliminar',
          danger: danger,
        );
      });

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar plato'), findsOneWidget);
      expect(find.text('¿Seguro que desea eliminarlo?'), findsOneWidget);

      await tester.tap(target);
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('resolves true when confirmed (tablet)', (tester) async {
      expect(
        await runConfirm(
          tester,
          TestScreens.tabletLandscape,
          find.text('Eliminar'),
        ),
        isTrue,
      );
    });

    testWidgets('resolves false when cancelled (tablet)', (tester) async {
      expect(
        await runConfirm(
          tester,
          TestScreens.tabletLandscape,
          find.text('Cancelar'),
        ),
        isFalse,
      );
    });

    testWidgets('resolves true when confirmed (phone)', (tester) async {
      expect(
        await runConfirm(tester, TestScreens.phone, find.text('Eliminar')),
        isTrue,
      );
    });

    testWidgets('resolves false when dismissed with the close button', (
      tester,
    ) async {
      expect(
        await runConfirm(tester, TestScreens.phone, find.byIcon(Icons.close)),
        isFalse,
      );
    });

    testWidgets('danger uses the rose confirm button', (tester) async {
      await pumpOpener(tester, TestScreens.tabletLandscape, (context) {
        showConfirmDialog(
          context,
          title: 'Eliminar plato',
          message: '¿Seguro?',
          confirmLabel: 'Eliminar',
          danger: true,
        );
      });
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      final confirm = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Eliminar'),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(confirm.style!.backgroundColor!.resolve({}), AppColors.rose600);
    });

    testWidgets('non-danger uses the primary confirm button', (tester) async {
      await pumpOpener(tester, TestScreens.tabletLandscape, (context) {
        showConfirmDialog(context, title: 'Confirmar', message: '¿Continuar?');
      });
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      final confirm = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Confirmar').last,
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(confirm.style!.backgroundColor!.resolve({}), AppColors.emerald600);
    });
  });
}
