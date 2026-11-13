import 'package:itsqmet_mobile_pos/presentation/screens/cocina/cocina_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'CocinaScreen',
    () => const CocinaScreen(),
    title: 'Monitor KDS de Cocina & Bar',
    subtitle: 'Recepción instantánea de comandas por orden de llegada con instrucciones de preparación',
    icon: Icons.soup_kitchen,
  );
}
