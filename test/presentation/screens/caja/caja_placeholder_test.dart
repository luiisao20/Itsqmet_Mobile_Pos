import 'package:itsqmet_mobile_pos/presentation/screens/caja/caja_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'CajaScreen',
    () => const CajaScreen(),
    title: 'Módulo de Caja & Facturación',
    subtitle: 'Emisión de facturas electrónicas autorizadas y recaudación de pagos (Efectivo, Tarjeta, Transferencia)',
    icon: Icons.point_of_sale,
  );
}
