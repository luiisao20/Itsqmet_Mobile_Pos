import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class PlatosTab extends StatelessWidget {
  const PlatosTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.restaurant_menu,
      title: 'Platos',
      message: FeaturePlaceholder.emptyMessage,
    );
  }
}
