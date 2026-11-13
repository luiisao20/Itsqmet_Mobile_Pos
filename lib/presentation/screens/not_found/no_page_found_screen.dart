import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class NoPageFoundScreen extends StatelessWidget {
  const NoPageFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final minHeight = MediaQuery.sizeOf(context).height * 0.6;

    return PageContainer(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 60,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.emerald300,
                ),
              ),
              AppSpacing.h8,
              Text(
                'Página No Encontrada',
                textAlign: TextAlign.center,
                style: AppTextStyles.xl.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald950,
                ),
              ),
              AppSpacing.h4,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: Text(
                  'La ruta que buscas no existe o ha sido movida. Regresa al menú principal.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
                ),
              ),
              AppSpacing.h24,
              AppButton(
                label: 'Volver al Menú',
                onPressed: () => context.go(AppRoutes.home.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
