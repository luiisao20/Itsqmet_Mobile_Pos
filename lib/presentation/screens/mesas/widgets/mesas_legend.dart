import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

class MesasLegend extends StatelessWidget {
  const MesasLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.gray200),
        boxShadow: AppShadows.xs,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(color: AppColors.emerald500, label: 'Libre'),
          AppSpacing.w12,
          _LegendItem(color: AppColors.amber500, label: 'Ocupada'),
          AppSpacing.w12,
          _LegendItem(color: AppColors.sky500, label: 'Cuenta'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.xs.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
