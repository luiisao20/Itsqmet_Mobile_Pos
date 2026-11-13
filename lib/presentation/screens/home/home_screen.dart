import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.restaurant,
      title: 'Sabores Auténticos, Preparados al Momento.',
      subtitle: 'Explora nuestro menú artesanal. Pide directamente para llevar o disfruta en nuestro salón atendido por nuestro equipo.',
    );
  }
}
