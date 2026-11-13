import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.expand = false,
    this.loading = false,
    this.loadingLabel,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  final bool expand;
  final bool loading;
  final String? loadingLabel;

  final IconData? leading;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final colors = _VariantColors.of(variant);
    final metrics = _SizeMetrics.of(size);
    final text = loading && loadingLabel != null ? loadingLabel! : label;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: metrics.fontSize,
            height: metrics.fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.foreground,
            ),
          ),
          AppSpacing.w8,
        ] else if (leading != null) ...[
          Icon(leading, size: metrics.fontSize + 2, color: colors.foreground),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: _enabled ? onPressed : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)
              ? colors.pressedBackground
              : colors.background,
        ),
        foregroundColor: WidgetStatePropertyAll(colors.foreground),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(metrics.padding),
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: metrics.fontSize, fontWeight: FontWeight.w500),
        ),
        side: WidgetStatePropertyAll(
          colors.border == null
              ? BorderSide.none
              : BorderSide(color: colors.border!),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      child: content,
    );

    Widget result = colors.shadow
        ? DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: AppRadius.smAll,
              boxShadow: AppShadows.xs,
            ),
            child: button,
          )
        : button;

    if (!_enabled) {
      result = Opacity(opacity: 0.5, child: result);
    }
    if (expand) {
      result = SizedBox(width: double.infinity, child: result);
    }
    return result;
  }
}

class _VariantColors {
  const _VariantColors({
    required this.background,
    required this.pressedBackground,
    required this.foreground,
    this.border,
    this.shadow = false,
  });

  final Color background;
  final Color pressedBackground;
  final Color foreground;
  final Color? border;
  final bool shadow;

  static _VariantColors of(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => const _VariantColors(
      background: AppColors.emerald600,
      pressedBackground: AppColors.emerald700,
      foreground: AppColors.white,
      shadow: true,
    ),
    AppButtonVariant.secondary => const _VariantColors(
      background: AppColors.emerald50,
      pressedBackground: AppColors.emerald100,
      foreground: AppColors.emerald800,
      border: AppColors.emerald200,
    ),
    AppButtonVariant.outline => const _VariantColors(
      background: Colors.transparent,
      pressedBackground: AppColors.gray50,
      foreground: AppColors.gray700,
      border: AppColors.gray300,
    ),
    AppButtonVariant.danger => const _VariantColors(
      background: AppColors.rose600,
      pressedBackground: AppColors.rose700,
      foreground: AppColors.white,
      shadow: true,
    ),
  };
}

class _SizeMetrics {
  const _SizeMetrics({required this.padding, required this.fontSize});

  final EdgeInsets padding;
  final double fontSize;

  static _SizeMetrics of(AppButtonSize size) => switch (size) {
    AppButtonSize.sm => const _SizeMetrics(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      fontSize: 12,
    ),
    AppButtonSize.md => const _SizeMetrics(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      fontSize: 14,
    ),
    AppButtonSize.lg => const _SizeMetrics(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      fontSize: 16,
    ),
  };
}
