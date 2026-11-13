import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class RoleChipColors extends Equatable {
  const RoleChipColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  List<Object?> get props => [background, foreground];
}

class RoleChip extends StatelessWidget {
  const RoleChip(this.role, {super.key});

  final String role;

  static RoleChipColors colorsFor(String role) => switch (role) {
    'ADMIN' => const RoleChipColors(
      background: AppColors.purple100,
      foreground: AppColors.purple800,
    ),
    'MESERO' => const RoleChipColors(
      background: AppColors.emerald100,
      foreground: AppColors.emerald800,
    ),
    'COCINA' => const RoleChipColors(
      background: AppColors.amber100,
      foreground: AppColors.amber800,
    ),
    'CLIENTE' => const RoleChipColors(
      background: AppColors.blue100,
      foreground: AppColors.blue800,
    ),
    _ => const RoleChipColors(
      background: AppColors.gray100,
      foreground: AppColors.gray700,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(role);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.fullAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          role,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text11.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.55,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}
