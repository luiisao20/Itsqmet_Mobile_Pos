import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const String emptyTitle = 'Sección en construcción';
  static const String emptyMessage =
      'Esta sección estará disponible próximamente.';

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(icon: icon, title: title, subtitle: subtitle),
          EmptyState(icon: icon, title: emptyTitle, message: emptyMessage),
        ],
      ),
    );
  }
}
