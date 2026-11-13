import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class MesasScreen extends StatelessWidget {
  const MesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.table_restaurant,
      title: 'Mapa de Mesas & Salón',
      subtitle: 'Visualiza el estado de las mesas en tiempo real y asigna comandas de salón',
    );
  }
}
