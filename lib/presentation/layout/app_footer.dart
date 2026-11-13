import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key, this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final year = (now ?? DateTime.now()).year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.emerald100)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.xl),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© $year Restaurante POS - Sistema de Gestión Gastronómica & '
                  'Facturación Electrónica',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
                ),
                AppSpacing.h4,
                Text(
                  'Actualización en tiempo real vía WebSocket & Cookies de '
                  'Sesión Segura',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text11.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.emerald700.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
