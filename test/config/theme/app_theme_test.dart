import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

void main() {
  group('AppColors', () {
    test('project tokens match the web', () {
      expect(AppColors.background.toARGB32(), 0xFFF8FAF8);
      expect(AppColors.surface.toARGB32(), 0xFFFFFFFF);
      expect(AppColors.textPrimary.toARGB32(), 0xFF1F2937);
      expect(AppColors.primary, AppColors.emerald600);
    });

    test('emerald scale matches Tailwind', () {
      expect(AppColors.emerald50.toARGB32(), 0xFFECFDF5);
      expect(AppColors.emerald100.toARGB32(), 0xFFD1FAE5);
      expect(AppColors.emerald200.toARGB32(), 0xFFA7F3D0);
      expect(AppColors.emerald300.toARGB32(), 0xFF6EE7B7);
      expect(AppColors.emerald500.toARGB32(), 0xFF10B981);
      expect(AppColors.emerald600.toARGB32(), 0xFF059669);
      expect(AppColors.emerald700.toARGB32(), 0xFF047857);
      expect(AppColors.emerald800.toARGB32(), 0xFF065F46);
      expect(AppColors.emerald900.toARGB32(), 0xFF064E3B);
      expect(AppColors.emerald950.toARGB32(), 0xFF022C22);
      expect(AppColors.teal700.toARGB32(), 0xFF0F766E);
    });

    test('gray scale matches Tailwind', () {
      expect(AppColors.gray50.toARGB32(), 0xFFF9FAFB);
      expect(AppColors.gray100.toARGB32(), 0xFFF3F4F6);
      expect(AppColors.gray200.toARGB32(), 0xFFE5E7EB);
      expect(AppColors.gray300.toARGB32(), 0xFFD1D5DB);
      expect(AppColors.gray400.toARGB32(), 0xFF9CA3AF);
      expect(AppColors.gray500.toARGB32(), 0xFF6B7280);
      expect(AppColors.gray600.toARGB32(), 0xFF4B5563);
      expect(AppColors.gray700.toARGB32(), 0xFF374151);
      expect(AppColors.gray800.toARGB32(), 0xFF1F2937);
      expect(AppColors.gray900.toARGB32(), 0xFF111827);
    });

    test('amber, sky, rose, red, purple and blue tokens match Tailwind', () {
      expect(AppColors.amber50.toARGB32(), 0xFFFFFBEB);
      expect(AppColors.amber800.toARGB32(), 0xFF92400E);
      expect(AppColors.amber900.toARGB32(), 0xFF78350F);
      expect(AppColors.sky50.toARGB32(), 0xFFF0F9FF);
      expect(AppColors.sky800.toARGB32(), 0xFF075985);
      expect(AppColors.rose50.toARGB32(), 0xFFFFF1F2);
      expect(AppColors.rose600.toARGB32(), 0xFFE11D48);
      expect(AppColors.rose700.toARGB32(), 0xFFBE123C);
      expect(AppColors.rose800.toARGB32(), 0xFF9F1239);
      expect(AppColors.red600.toARGB32(), 0xFFDC2626);
      expect(AppColors.purple100.toARGB32(), 0xFFF3E8FF);
      expect(AppColors.purple800.toARGB32(), 0xFF6B21A8);
      expect(AppColors.blue100.toARGB32(), 0xFFDBEAFE);
      expect(AppColors.blue800.toARGB32(), 0xFF1E40AF);
    });

    test('overlays are black at 40% and 60%', () {
      expect(AppColors.modalBarrier.a, closeTo(0.4, 0.01));
      expect(AppColors.chipOverlay.a, closeTo(0.6, 0.01));
      expect(AppColors.modalBarrier.toARGB32() & 0x00FFFFFF, 0);
    });

    test('heroGradient goes left to right emerald-700 -> 600 -> teal-700', () {
      const gradient = AppColors.heroGradient;

      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
      expect(gradient.colors, [
        AppColors.emerald700,
        AppColors.emerald600,
        AppColors.teal700,
      ]);
    });
  });

  group('AppTextStyles', () {
    test('follows the Tailwind size / line height scale', () {
      expect(AppTextStyles.text10.fontSize, 10);
      expect(AppTextStyles.text11.fontSize, 11);
      expect(AppTextStyles.xs.fontSize, 12);
      expect(AppTextStyles.xs.height, closeTo(16 / 12, 0.001));
      expect(AppTextStyles.sm.fontSize, 14);
      expect(AppTextStyles.sm.height, closeTo(20 / 14, 0.001));
      expect(AppTextStyles.base.fontSize, 16);
      expect(AppTextStyles.base.height, closeTo(24 / 16, 0.001));
      expect(AppTextStyles.lg.fontSize, 18);
      expect(AppTextStyles.lg.height, closeTo(28 / 18, 0.001));
      expect(AppTextStyles.xl.fontSize, 20);
      expect(AppTextStyles.x2l.fontSize, 24);
      expect(AppTextStyles.x2l.height, closeTo(32 / 24, 0.001));
      expect(AppTextStyles.x3l.fontSize, 30);
      expect(AppTextStyles.x3l.height, closeTo(36 / 30, 0.001));
      expect(AppTextStyles.x5l.fontSize, 48);
      expect(AppTextStyles.x5l.height, 1);
    });

    test('semantic styles', () {
      expect(AppTextStyles.pageTitle.fontSize, 24);
      expect(AppTextStyles.pageTitle.fontWeight, FontWeight.w900);
      expect(AppTextStyles.pageTitle.color, AppColors.emerald950);
      expect(AppTextStyles.pageSubtitle.fontSize, 12);
      expect(AppTextStyles.pageSubtitle.color, AppColors.gray500);
      expect(AppTextStyles.heroTitle.fontSize, 30);
      expect(AppTextStyles.heroTitleTablet.fontSize, 48);
      expect(AppTextStyles.cardTitle.fontSize, 14);
      expect(AppTextStyles.cardTitle.fontWeight, FontWeight.w700);
      expect(AppTextStyles.body.fontSize, 12);
      expect(AppTextStyles.body.color, AppColors.gray700);
      expect(AppTextStyles.label.fontWeight, FontWeight.w600);
      expect(AppTextStyles.labelBold.fontWeight, FontWeight.w700);
      expect(AppTextStyles.tableHeader.fontSize, 10);
      expect(AppTextStyles.tableHeader.fontWeight, FontWeight.w700);
      expect(AppTextStyles.tableHeader.letterSpacing, 0.5);
      expect(AppTextStyles.tableHeader.color, AppColors.gray400);
      expect(AppTextStyles.badge.fontWeight, FontWeight.w500);
      expect(AppTextStyles.caption.fontSize, 11);
      expect(AppTextStyles.price.fontSize, 18);
      expect(AppTextStyles.price.color, AppColors.emerald800);
      expect(AppTextStyles.mono.fontFamily, 'monospace');
      expect(AppTextStyles.logo.fontWeight, FontWeight.w900);
    });
  });

  group('AppRadius', () {
    test('matches Tailwind rounded-lg/xl/2xl/3xl/full', () {
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 12);
      expect(AppRadius.lg, 16);
      expect(AppRadius.xl, 24);
      expect(AppRadius.full, 999);
      expect(AppRadius.mdAll, BorderRadius.circular(12));
      expect(AppRadius.xlTop.topLeft, const Radius.circular(24));
      expect(AppRadius.xlTop.bottomLeft, Radius.zero);
    });
  });

  group('AppShadows', () {
    test('xs is a single 1px 2px 5% shadow', () {
      expect(AppShadows.xs, hasLength(1));
      expect(AppShadows.xs.first.offset, const Offset(0, 1));
      expect(AppShadows.xs.first.blurRadius, 2);
      expect(AppShadows.xs.first.color.a, closeTo(0.05, 0.01));
    });

    test('sm, md, lg and xl have two layers each', () {
      expect(AppShadows.sm, hasLength(2));
      expect(AppShadows.md, hasLength(2));
      expect(AppShadows.lg, hasLength(2));
      expect(AppShadows.xl, hasLength(2));
    });

    test('xl matches 0 20px 25px -5px and 0 8px 10px -6px', () {
      expect(AppShadows.xl[0].offset, const Offset(0, 20));
      expect(AppShadows.xl[0].blurRadius, 25);
      expect(AppShadows.xl[0].spreadRadius, -5);
      expect(AppShadows.xl[1].offset, const Offset(0, 8));
      expect(AppShadows.xl[1].blurRadius, 10);
      expect(AppShadows.xl[1].spreadRadius, -6);
    });
  });

  group('AppSpacing', () {
    test('uses a 4px scale', () {
      expect(AppSpacing.s1, 4);
      expect(AppSpacing.s2, 8);
      expect(AppSpacing.s4, 16);
      expect(AppSpacing.s6, 24);
      expect(AppSpacing.s8, 32);
      expect(AppSpacing.s12, 48);
    });

    test('page paddings', () {
      expect(AppSpacing.pagePaddingMobile, 16);
      expect(AppSpacing.pagePaddingTablet, 24);
      expect(AppSpacing.pagePaddingDesktop, 32);
      expect(AppSpacing.pageVertical, 32);
    });

    test('gap helpers have the matching size', () {
      expect(AppSpacing.h8.height, 8);
      expect(AppSpacing.w16.width, 16);
    });
  });

  group('AppTheme.light', () {
    final theme = AppTheme.light;

    test('is Material 3 with the brand colors', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.emerald600);
      expect(theme.colorScheme.onPrimary, AppColors.white);
      expect(theme.colorScheme.error, AppColors.rose600);
      expect(theme.colorScheme.surface, AppColors.white);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('uses InkRipple so no shader asset is required', () {
      expect(theme.splashFactory, InkRipple.splashFactory);
    });

    test('text uses gray-800', () {
      expect(theme.textTheme.bodyMedium!.color, AppColors.gray800);
    });

    test('inputs mirror the web fields', () {
      final input = theme.inputDecorationTheme;
      final focused = input.focusedBorder! as OutlineInputBorder;
      final enabled = input.enabledBorder! as OutlineInputBorder;

      expect(input.filled, isTrue);
      expect(input.fillColor, AppColors.gray50.withValues(alpha: 0.5));
      expect(
        input.contentPadding,
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      );
      expect(enabled.borderSide.color, AppColors.gray200);
      expect(focused.borderSide.color, AppColors.emerald500);
      expect(focused.borderSide.width, 1);
      expect(focused.borderRadius, AppRadius.mdAll);
      expect(input.hintStyle!.fontSize, 12);
      expect(input.hintStyle!.color, AppColors.gray400);
      expect(input.labelStyle!.fontWeight, FontWeight.w600);
    });

    test('cards, dialogs, sheets and dividers', () {
      final card = theme.cardTheme.shape! as RoundedRectangleBorder;
      final dialog = theme.dialogTheme.shape! as RoundedRectangleBorder;
      final sheet = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;

      expect(card.borderRadius, AppRadius.lgAll);
      expect(card.side.color, AppColors.emerald100);
      expect(theme.cardTheme.color, AppColors.white);
      expect(dialog.borderRadius, AppRadius.lgAll);
      expect(sheet.borderRadius, AppRadius.xlTop);
      expect(theme.dividerTheme.color, AppColors.gray100);
    });

    test('snackbars float and the app bar is flat white', () {
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.appBarTheme.backgroundColor, AppColors.white);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.foregroundColor, AppColors.emerald950);
    });

    test('elevated buttons use emerald-600 and radius 8', () {
      final style = theme.elevatedButtonTheme.style!;

      expect(style.backgroundColor!.resolve({}), AppColors.emerald600);
      expect(
        style.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.emerald700,
      );
      expect(style.foregroundColor!.resolve({}), AppColors.white);
      expect(
        (style.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
        AppRadius.smAll,
      );
    });

    test('outlined buttons use a gray-300 border', () {
      final style = theme.outlinedButtonTheme.style!;

      expect(style.side!.resolve({})!.color, AppColors.gray300);
      expect(style.foregroundColor!.resolve({}), AppColors.gray700);
    });

    test('text buttons use emerald-700 / pressed emerald-800', () {
      final style = theme.textButtonTheme.style!;

      expect(style.foregroundColor!.resolve({}), AppColors.emerald700);
      expect(
        style.foregroundColor!.resolve({WidgetState.pressed}),
        AppColors.emerald800,
      );
    });
  });
}
