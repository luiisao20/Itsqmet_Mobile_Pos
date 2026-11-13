import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

enum PillSelectorStyle { filled, outlined }

enum PillSize { sm, md }

@immutable
class PillItem<T> {
  const PillItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class PillSelector<T> extends StatelessWidget {
  const PillSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.style = PillSelectorStyle.filled,
    this.size = PillSize.sm,
  });

  final List<PillItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final PillSelectorStyle style;
  final PillSize size;

  @override
  Widget build(BuildContext context) {
    final gap = size == PillSize.md ? AppSpacing.s2 : 6.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            _Pill<T>(
              item: items[i],
              active: items[i].value == selected,
              style: style,
              size: size,
              onTap: () => onSelected(items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill<T> extends StatelessWidget {
  const _Pill({
    required this.item,
    required this.active,
    required this.style,
    required this.size,
    required this.onTap,
  });

  final PillItem<T> item;
  final bool active;
  final PillSelectorStyle style;
  final PillSize size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outlined = style == PillSelectorStyle.outlined;
    final foreground = active
        ? AppColors.white
        : outlined
        ? AppColors.gray700
        : AppColors.gray600;
    final background = active
        ? AppColors.emerald600
        : outlined
        ? AppColors.white
        : AppColors.gray100;
    final icon = item.icon;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: size == PillSize.md
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.mdAll,
            border: !active && outlined
                ? Border.all(color: AppColors.gray200)
                : null,
            boxShadow: active && !outlined ? AppShadows.xs : null,
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
                  fontWeight: size == PillSize.md
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
