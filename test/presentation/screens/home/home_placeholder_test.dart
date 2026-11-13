import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'HomeScreen',
    () => const HomeScreen(),
    title: 'Sabores Auténticos, Preparados al Momento.',
    subtitle: 'Explora nuestro menú artesanal. Pide directamente para llevar o disfruta en nuestro salón atendido por nuestro equipo.',
    icon: Icons.restaurant,
  );
}
