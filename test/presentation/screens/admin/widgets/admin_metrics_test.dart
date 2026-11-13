import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_metrics.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockMetricsCubit extends MockCubit<AdminMetricsState>
    implements AdminMetricsCubit {}

void main() {
  late _MockMetricsCubit cubit;

  setUp(() {
    cubit = _MockMetricsCubit();
    when(() => cubit.state).thenReturn(
      const AdminMetricsState(platos: 12, mesas: 8, personal: 5, insumos: 30),
    );
  });

  Future<void> pump(WidgetTester tester, Size size) => tester.pumpApp(
    BlocProvider<AdminMetricsCubit>.value(
      value: cubit,
      child: const AdminMetricsView(),
    ),
    size: size,
  );

  testWidgets('shows the four labels with their counts', (tester) async {
    await pump(tester, TestScreens.tabletLandscape);

    for (final (label, value) in [
      ('Platos', '12'),
      ('Mesas', '8'),
      ('Personal', '5'),
      ('Insumos', '30'),
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(find.text(value), findsOneWidget, reason: label);
    }
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.byIcon(Icons.table_restaurant), findsOneWidget);
    expect(find.byIcon(Icons.groups), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2), findsOneWidget);
  });

  testWidgets('a wide screen shows the four metrics in one row', (
    tester,
  ) async {
    await pump(tester, TestScreens.tabletLandscape);

    final platos = tester.getTopLeft(find.text('Platos'));
    final insumos = tester.getTopLeft(find.text('Insumos'));
    expect(insumos.dy, platos.dy);
  });

  testWidgets('a phone shows two metrics per row', (tester) async {
    await pump(tester, TestScreens.phone);

    final platos = tester.getTopLeft(find.text('Platos'));
    final mesas = tester.getTopLeft(find.text('Mesas'));
    final personal = tester.getTopLeft(find.text('Personal'));
    expect(mesas.dy, platos.dy);
    expect(personal.dy, greaterThan(platos.dy));
  });
}
