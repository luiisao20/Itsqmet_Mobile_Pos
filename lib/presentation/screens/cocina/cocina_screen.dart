import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class CocinaScreen extends StatelessWidget {
  const CocinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.soup_kitchen,
      title: 'Monitor KDS de Cocina & Bar',
      subtitle: 'Recepción instantánea de comandas por orden de llegada con instrucciones de preparación',
    );
  }
}
