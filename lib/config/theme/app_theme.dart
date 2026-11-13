import 'package:itsqmet_mobile_pos/config/theme/app_colors.dart';
import 'package:itsqmet_mobile_pos/config/theme/app_radius.dart';
import 'package:itsqmet_mobile_pos/config/theme/app_text_styles.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static final ThemeData light = _build();

  static ThemeData _build() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.emerald600)
        .copyWith(
          primary: AppColors.emerald600,
          onPrimary: AppColors.white,
          error: AppColors.rose600,
          surface: AppColors.white,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.gray800,
        displayColor: AppColors.gray800,
      ),
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledStyle()),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
      textButtonTheme: TextButtonThemeData(style: _textStyle()),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppColors.emerald100),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.gray100,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AppColors.modalBarrier,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlTop),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.emerald950,
        centerTitle: false,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.emerald600
              : null,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.gray300, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emerald600,
      ),
    );
  }

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50.withValues(alpha: 0.5),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        hintStyle: AppTextStyles.xs.copyWith(color: AppColors.gray400),
        labelStyle: AppTextStyles.label,
        floatingLabelStyle: AppTextStyles.label,
        errorStyle: AppTextStyles.text11.copyWith(color: AppColors.rose600),
        border: _border(AppColors.gray200),
        enabledBorder: _border(AppColors.gray200),
        focusedBorder: _border(AppColors.emerald500),
        errorBorder: _border(AppColors.rose500),
        focusedErrorBorder: _border(AppColors.rose600),
        disabledBorder: _border(AppColors.gray100),
      );

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.mdAll,
    borderSide: BorderSide(color: color),
  );

  static ButtonStyle _filledStyle() => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered)
          ? AppColors.emerald700
          : AppColors.emerald600,
    ),
    foregroundColor: const WidgetStatePropertyAll(AppColors.white),
    elevation: const WidgetStatePropertyAll(0),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textStyle: WidgetStatePropertyAll(
      AppTextStyles.sm.copyWith(fontWeight: FontWeight.w500),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.smAll),
    ),
  );

  static ButtonStyle _outlinedStyle() => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.pressed)
          ? AppColors.gray50
          : Colors.transparent,
    ),
    foregroundColor: const WidgetStatePropertyAll(AppColors.gray700),
    side: const WidgetStatePropertyAll(BorderSide(color: AppColors.gray300)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textStyle: WidgetStatePropertyAll(
      AppTextStyles.sm.copyWith(fontWeight: FontWeight.w500),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.smAll),
    ),
  );

  static ButtonStyle _textStyle() => ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.pressed)
          ? AppColors.emerald800
          : AppColors.emerald700,
    ),
    textStyle: WidgetStatePropertyAll(
      AppTextStyles.xs.copyWith(fontWeight: FontWeight.w600),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.smAll),
    ),
  );
}
