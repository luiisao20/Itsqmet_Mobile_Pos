import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class CategoriasTab extends StatelessWidget {
  const CategoriasTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.folder_open,
      title: 'Categorías',
      message: FeaturePlaceholder.emptyMessage,
    );
  }
}
