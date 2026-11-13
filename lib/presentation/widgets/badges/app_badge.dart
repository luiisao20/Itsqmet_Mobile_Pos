import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

enum BadgeVariant { success, warning, danger, info, neutral }

@immutable
class BadgeColors {
  const BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  static BadgeColors of(BadgeVariant variant) => switch (variant) {
    BadgeVariant.success => const BadgeColors(
      background: AppColors.emerald50,
      foreground: AppColors.emerald800,
      border: AppColors.emerald200,
    ),
    BadgeVariant.warning => const BadgeColors(
      background: AppColors.amber50,
      foreground: AppColors.amber800,
      border: AppColors.amber200,
    ),
    BadgeVariant.danger => const BadgeColors(
      background: AppColors.rose50,
      foreground: AppColors.rose800,
      border: AppColors.rose200,
    ),
    BadgeVariant.info => const BadgeColors(
      background: AppColors.sky50,
      foreground: AppColors.sky800,
      border: AppColors.sky200,
    ),
    BadgeVariant.neutral => const BadgeColors(
      background: AppColors.gray100,
      foreground: AppColors.gray700,
      border: AppColors.gray200,
    ),
  };
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
  });

  final String label;
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = BadgeColors.of(variant);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.badge.copyWith(color: colors.foreground),
        ),
      ),
    );
  }
}
