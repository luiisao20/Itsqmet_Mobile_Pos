import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class InsumosTab extends StatelessWidget {
  const InsumosTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.inventory_2,
      title: 'Insumos / Inventario',
      message: FeaturePlaceholder.emptyMessage,
    );
  }
}
