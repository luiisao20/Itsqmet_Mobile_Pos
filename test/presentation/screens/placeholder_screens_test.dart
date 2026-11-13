import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/caja_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/cliente_pedidos_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/cocina_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/mesas_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  final cases = <String, (Widget, String, String, IconData)>{
    'HomeScreen': (
      const HomeScreen(),
      'Sabores Auténticos, Preparados al Momento.',
      'Explora nuestro menú artesanal. Pide directamente para llevar o disfruta en nuestro salón atendido por nuestro equipo.',
      Icons.restaurant,
    ),
    'ClientePedidosScreen': (
      const ClientePedidosScreen(),
      'Panel de Pedidos & Facturas',
      'Arma tu pedido para llevar en tiempo real y consulta tu historial fiscal',
      Icons.receipt_long,
    ),
    'MesasScreen': (
      const MesasScreen(),
      'Mapa de Mesas & Salón',
      'Visualiza el estado de las mesas en tiempo real y asigna comandas de salón',
      Icons.table_restaurant,
    ),
    'CocinaScreen': (
      const CocinaScreen(),
      'Monitor KDS de Cocina & Bar',
      'Recepción instantánea de comandas por orden de llegada con instrucciones de preparación',
      Icons.soup_kitchen,
    ),
    'CajaScreen': (
      const CajaScreen(),
      'Módulo de Caja & Facturación',
      'Emisión de facturas electrónicas autorizadas y recaudación de pagos (Efectivo, Tarjeta, Transferencia)',
      Icons.point_of_sale,
    ),
  };

  for (final entry in cases.entries) {
    final (screen, title, subtitle, icon) = entry.value;

    testWidgets('${entry.key} shows its web title inside a placeholder', (
      tester,
    ) async {
      await tester.pumpApp(screen);

      expect(find.byType(FeaturePlaceholder), findsOneWidget);
      expect(find.byType(PageContainer), findsOneWidget);
      final header = tester.widget<PageHeader>(find.byType(PageHeader));
      expect(header.title, title);
      expect(header.subtitle, subtitle);
      expect(header.icon, icon);
      expect(find.text(FeaturePlaceholder.emptyTitle), findsOneWidget);
      expect(find.text(FeaturePlaceholder.emptyMessage), findsOneWidget);
    });
  }

  testWidgets('placeholders render on tablet without overflow', (tester) async {
    await tester.pumpApp(const CajaScreen(), size: TestScreens.tabletLandscape);

    expect(tester.takeException(), isNull);
    expect(find.text('Módulo de Caja & Facturación'), findsOneWidget);
  });
}
