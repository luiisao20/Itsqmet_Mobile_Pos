import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class AdminMetrics extends StatelessWidget {
  const AdminMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminMetricsCubit>(
      create: (_) => getIt<AdminMetricsCubit>()..load(),
      child: const AdminMetricsView(),
    );
  }
}

class AdminMetricsView extends StatelessWidget {
  const AdminMetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.atLeastSm ? 4 : 2;
    final state = context.watch<AdminMetricsCubit>().state;
    final metrics = [
      (Icons.restaurant_menu, 'Platos', state.platos),
      (Icons.table_restaurant, 'Mesas', state.mesas),
      (Icons.groups, 'Personal', state.personal),
      (Icons.inventory_2, 'Insumos', state.insumos),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.s4;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, label, value) in metrics)
              SizedBox(
                width: itemWidth,
                child: _MetricCard(icon: icon, label: label, value: '$value'),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: AppRadius.lgAll,
            ),
            child: Icon(icon, size: 20, color: AppColors.emerald800),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text11.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.xl.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald950,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
