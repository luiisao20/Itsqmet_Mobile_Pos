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

class _StubTab extends StatelessWidget {
  const _StubTab({required this.tab, required this.createRequests});

  final AdminTab tab;
  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) => Text('stub:${tab.name}');
}

Finder stubTab(AdminTab tab) =>
    find.byWidgetPredicate((widget) => widget is _StubTab && widget.tab == tab);

Future<void> pumpAdmin(WidgetTester tester, {Size? size}) => tester.pumpApp(
  AdminScreen(
    tabBuilder: (tab, requests) => _StubTab(tab: tab, createRequests: requests),
    metrics: const Text('metrics-stub'),
  ),
  size: size ?? TestScreens.phone,
);

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

  for (final entry in tabWidgets.entries) {
    test('adminTabFor maps ${entry.key.name} to ${entry.value}', () {
      expect(
        adminTabFor(entry.key, const Stream<void>.empty()).runtimeType,
        entry.value,
      );
    });
  }

  test('AdminScreen uses the real tabs and AdminMetrics by default', () {
    const screen = AdminScreen();

    expect(screen.metrics, isA<AdminMetrics>());
    expect(screen.tabBuilder, adminTabFor);
  });

  testWidgets('shows the header, metrics, tab bar and the platos tab', (
    tester,
  ) async {
    await pumpAdmin(tester);

    final header = tester.widget<PageHeader>(find.byType(PageHeader));
    expect(header.title, 'Panel de Administración');
    expect(
      header.subtitle,
      'Gestión integral de catálogo, personal, inventario, mesas y proveedores',
    );
    expect(find.text('metrics-stub'), findsOneWidget);
    for (final tab in AdminTab.values) {
      expect(find.byKey(ValueKey(tab)), findsOneWidget);
    }
    expect(stubTab(AdminTab.platos), findsOneWidget);
    expect(find.text('+ Nuevo Plato'), findsOneWidget);
  });

  for (final tab in AdminTab.values) {
    testWidgets('selecting ${tab.name} shows only its tab', (tester) async {
      await pumpAdmin(tester);

      await selectTab(tester, tab);

      expect(stubTab(tab), findsOneWidget);
      expect(find.text(tab.createLabel), findsOneWidget);
      for (final other in AdminTab.values.where((t) => t != tab)) {
        expect(stubTab(other), findsNothing);
      }
    });
  }

  testWidgets('the selected pill uses the active colors', (tester) async {
    await pumpAdmin(tester);

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
    await pumpAdmin(tester);
    await selectTab(tester, AdminTab.insumos);

    final tab = tester.widget<_StubTab>(stubTab(AdminTab.insumos));
    var requests = 0;
    final subscription = tab.createRequests.listen((_) => requests++);
    addTearDown(subscription.cancel);

    await tester.tap(find.text('+ Nuevo Insumo'));
    await tester.pump();

    expect(requests, 1);
  });

  testWidgets('create requests are scoped to their own tab', (tester) async {
    await pumpAdmin(tester);
    final platos = tester.widget<_StubTab>(stubTab(AdminTab.platos));
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

  testWidgets('renders on tablet without overflow', (tester) async {
    await pumpAdmin(tester, size: TestScreens.tabletLandscape);

    expect(tester.takeException(), isNull);
    expect(find.text('+ Nuevo Plato'), findsOneWidget);
  });
}
