import 'package:flutter/painting.dart';
import 'package:itsqmet_mobile_pos/config/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle text10 = TextStyle(fontSize: 10, height: 14 / 10);
  static const TextStyle text11 = TextStyle(fontSize: 11, height: 16 / 11);
  static const TextStyle xs = TextStyle(fontSize: 12, height: 16 / 12);
  static const TextStyle sm = TextStyle(fontSize: 14, height: 20 / 14);
  static const TextStyle base = TextStyle(fontSize: 16, height: 24 / 16);
  static const TextStyle lg = TextStyle(fontSize: 18, height: 28 / 18);
  static const TextStyle xl = TextStyle(fontSize: 20, height: 28 / 20);
  static const TextStyle x2l = TextStyle(fontSize: 24, height: 32 / 24);
  static const TextStyle x3l = TextStyle(fontSize: 30, height: 36 / 30);
  static const TextStyle x5l = TextStyle(fontSize: 48, height: 1);

  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w900,
    color: AppColors.emerald950,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.gray500,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 30,
    height: 1.25,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
  );

  static const TextStyle heroTitleTablet = TextStyle(
    fontSize: 48,
    height: 1.1,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );

  static const TextStyle body = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.gray700,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gray700,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    color: AppColors.gray700,
  );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.gray400,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    color: AppColors.gray400,
  );

  static const TextStyle price = TextStyle(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w700,
    color: AppColors.emerald800,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontFamily: 'monospace',
    fontFamilyFallback: ['RobotoMono', 'Courier New', 'Courier'],
    color: AppColors.gray500,
  );

  static const TextStyle logo = TextStyle(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.45,
    color: AppColors.emerald950,
  );
}
