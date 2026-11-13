import 'package:itsqmet_mobile_pos/presentation/screens/mesas/mesas_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'MesasScreen',
    () => const MesasScreen(),
    title: 'Mapa de Mesas & Salón',
    subtitle: 'Visualiza el estado de las mesas en tiempo real y asigna comandas de salón',
    icon: Icons.table_restaurant,
  );
}
