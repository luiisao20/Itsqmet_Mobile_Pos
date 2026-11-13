import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class SegmentedTabItem<T> {
  const SegmentedTabItem({
    required this.value,
    required this.label,
    this.icon,
    this.badgeCount,
    this.activeColor = AppColors.emerald600,
  });

  final T value;
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final Color activeColor;
}

class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.compact = false,
    this.borderColor = AppColors.emerald100,
  });

  final List<SegmentedTabItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool compact;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s1),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: borderColor),
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _Tab<T>(
                item: items[i],
                active: items[i].value == selected,
                compact: compact,
                onTap: () => onChanged(items[i].value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tab<T> extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final SegmentedTabItem<T> item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active ? AppColors.white : AppColors.gray600;
    final icon = item.icon;
    final count = item.badgeCount;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? item.activeColor : Colors.transparent,
            borderRadius: AppRadius.mdAll,
            boxShadow: active ? AppShadows.xs : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                item.label,
                maxLines: 1,
                style: AppTextStyles.xs.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? AppColors.white : AppColors.emerald100,
                    borderRadius: AppRadius.fullAll,
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.text10.copyWith(
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: active
                          ? AppColors.emerald700
                          : AppColors.emerald800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
