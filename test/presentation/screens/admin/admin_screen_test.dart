import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/admin_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/categorias_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/clientes_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/distribuidores_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/insumos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/mesas_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/personal_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/platos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_metrics.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

Future<void> selectTab(WidgetTester tester, AdminTab tab) async {
  await tester.ensureVisible(find.byKey(ValueKey(tab)));
  await tester.tap(find.byKey(ValueKey(tab)));
  await tester.pumpAndSettle();
}

void main() {
  final tabWidgets = <AdminTab, Type>{
    AdminTab.platos: PlatosTab,
    AdminTab.categorias: CategoriasTab,
    AdminTab.mesas: MesasTab,
    AdminTab.personal: PersonalTab,
    AdminTab.insumos: InsumosTab,
    AdminTab.distribuidores: DistribuidoresTab,
    AdminTab.clientes: ClientesTab,
  };

  test('AdminTab keeps the web order, labels and create actions', () {
    expect(AdminTab.values, tabWidgets.keys.toList());
    expect(AdminTab.values.map((t) => t.label).toList(), [
      'Platos',
      'Categorías',
      'Mesas',
      'Personal',
      'Insumos / Inventario',
      'Distribuidores',
      'Clientes',
    ]);
    expect(AdminTab.values.map((t) => t.createLabel).toList(), [
      '+ Nuevo Plato',
      '+ Nueva Categoría',
      '+ Nueva Mesa',
      '+ Nuevo Empleado',
      '+ Nuevo Insumo',
      '+ Nuevo Distribuidor',
      '+ Nuevo Cliente',
    ]);
  });

  testWidgets('shows the header, metrics, tab bar and the platos tab', (
    tester,
  ) async {
    await tester.pumpApp(const AdminScreen());

    final header = tester.widget<PageHeader>(find.byType(PageHeader));
    expect(header.title, 'Panel de Administración');
    expect(
      header.subtitle,
      'Gestión integral de catálogo, personal, inventario, mesas y proveedores',
    );
    expect(find.byType(AdminMetrics), findsOneWidget);
    for (final tab in AdminTab.values) {
      expect(find.byKey(ValueKey(tab)), findsOneWidget);
    }
    expect(find.byType(PlatosTab), findsOneWidget);
    expect(find.text('+ Nuevo Plato'), findsOneWidget);
  });

  for (final entry in tabWidgets.entries) {
    testWidgets('selecting ${entry.key.name} shows ${entry.value}', (
      tester,
    ) async {
      await tester.pumpApp(const AdminScreen());

      await selectTab(tester, entry.key);

      expect(find.byType(entry.value), findsOneWidget);
      expect(find.text(entry.key.createLabel), findsOneWidget);
      for (final other in tabWidgets.entries) {
        if (other.key != entry.key) {
          expect(find.byType(other.value), findsNothing);
        }
      }
    });
  }

  testWidgets('the selected pill uses the active colors', (tester) async {
    await tester.pumpApp(const AdminScreen());

    BoxDecoration decorationOf(AdminTab tab) {
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(ValueKey(tab)),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return container.decoration! as BoxDecoration;
    }

    expect(decorationOf(AdminTab.platos).color, AppColors.emerald600);
    expect(decorationOf(AdminTab.mesas).color, AppColors.gray100);
  });

  testWidgets('the header action emits a create request for the active tab', (
    tester,
  ) async {
    await tester.pumpApp(const AdminScreen());
    await selectTab(tester, AdminTab.insumos);

    final tab = tester.widget<InsumosTab>(find.byType(InsumosTab));
    var requests = 0;
    final subscription = tab.createRequests.listen((_) => requests++);
    addTearDown(subscription.cancel);

    await tester.tap(find.text('+ Nuevo Insumo'));
    await tester.pump();

    expect(requests, 1);
  });

  testWidgets('create requests are scoped to their own tab', (tester) async {
    await tester.pumpApp(const AdminScreen());
    final platos = tester.widget<PlatosTab>(find.byType(PlatosTab));
    var platosRequests = 0;
    final StreamSubscription<void> subscription = platos.createRequests.listen(
      (_) => platosRequests++,
    );
    addTearDown(subscription.cancel);

    await selectTab(tester, AdminTab.categorias);
    await tester.tap(find.text('+ Nueva Categoría'));
    await tester.pump();

    expect(platosRequests, 0);
  });

  testWidgets('placeholder tabs show their label in an EmptyState', (
    tester,
  ) async {
    await tester.pumpApp(const AdminScreen());
    await selectTab(tester, AdminTab.distribuidores);

    final empty = tester.widget<EmptyState>(
      find.descendant(
        of: find.byType(DistribuidoresTab),
        matching: find.byType(EmptyState),
      ),
    );
    expect(empty.title, 'Distribuidores');
    expect(empty.icon, Icons.local_shipping);
  });

  testWidgets('AdminMetrics shows the four web metric labels', (tester) async {
    await tester.pumpApp(const AdminMetrics());

    for (final label in ['Platos', 'Mesas', 'Personal', 'Insumos']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('renders on tablet without overflow', (tester) async {
    await tester.pumpApp(
      const AdminScreen(),
      size: TestScreens.tabletLandscape,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('+ Nuevo Plato'), findsOneWidget);
  });
}
