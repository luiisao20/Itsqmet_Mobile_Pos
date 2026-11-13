import 'dart:ui';

import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.onOrder});

  final VoidCallback onOrder;

  static const Color _white20 = Color(0x33FFFFFF);
  static const Color _white10 = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    final md = context.atLeastMd;
    final titleStyle = md
        ? AppTextStyles.heroTitleTablet
        : AppTextStyles.heroTitle;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            bottom: -48,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 384,
                  height: 384,
                  decoration: const BoxDecoration(
                    color: _white10,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(md ? AppSpacing.s12 : AppSpacing.s8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroTag(),
                    AppSpacing.h12,
                    Text.rich(
                      TextSpan(
                        text: 'Sabores Auténticos, \n',
                        children: [
                          TextSpan(
                            text: 'Preparados al Momento.',
                            style: titleStyle.copyWith(
                              color: AppColors.emerald200,
                            ),
                          ),
                        ],
                      ),
                      style: titleStyle.copyWith(
                        letterSpacing: titleStyle.fontSize! * -0.025,
                      ),
                    ),
                    AppSpacing.h12,
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 576),
                      child: Text(
                        'Explora nuestro menú artesanal. Pide directamente para llevar o disfruta en nuestro salón atendido por nuestro equipo.',
                        style: (md ? AppTextStyles.base : AppTextStyles.sm)
                            .copyWith(
                              color: AppColors.emerald100,
                              height: 1.625,
                            ),
                      ),
                    ),
                    AppSpacing.h24,
                    AppButton(
                      label: 'Realizar Pedido para Llevar',
                      leading: Icons.shopping_bag_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: onOrder,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: HomeHero._white20,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: HomeHero._white20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: AppColors.emerald50),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Experiencia Gastronómica & Pedidos Online',
              style: AppTextStyles.xs.copyWith(
                color: AppColors.emerald50,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
