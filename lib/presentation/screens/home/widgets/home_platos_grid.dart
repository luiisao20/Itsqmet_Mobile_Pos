import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/plato_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/feedback/skeleton_box.dart';
import 'package:material_ui/material_ui.dart';

class HomePlatosGrid extends StatelessWidget {
  const HomePlatosGrid({
    super.key,
    required this.loading,
    required this.platos,
    required this.onAddToCart,
    required this.onShowAll,
  });

  final bool loading;
  final List<Plato> platos;
  final ValueChanged<Plato> onAddToCart;
  final VoidCallback onShowAll;

  static const int skeletonCount = 8;
  static const double skeletonHeight = 288;
  static const double gap = AppSpacing.s6;
  static const double minCardWidth = 256;

  static double cardExtent(TextScaler scaler) =>
      PlatoCard.imageHeight + scaler.scale(175);

  static int columnsFor(double width, int webColumns, TextScaler scaler) {
    final fitting = ((width + gap) / (scaler.scale(minCardWidth) + gap))
        .floor();
    return fitting.clamp(1, webColumns);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _grid(
        context,
        key: const ValueKey('home-skeleton-grid'),
        extent: skeletonHeight,
        count: skeletonCount,
        builder: (_) => const _SkeletonCard(),
      );
    }
    if (platos.isEmpty) return _EmptyPlatos(onShowAll: onShowAll);
    return _grid(
      context,
      key: const ValueKey('home-platos-grid'),
      extent: cardExtent(MediaQuery.textScalerOf(context)),
      count: platos.length,
      builder: (index) =>
          PlatoCard(plato: platos[index], onAddToCart: onAddToCart),
    );
  }

  Widget _grid(
    BuildContext context, {
    required Key key,
    required double extent,
    required int count,
    required Widget Function(int index) builder,
  }) {
    final webColumns = responsive(context, base: 1, sm: 2, md: 3, lg: 4);
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        key: key,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsFor(constraints.maxWidth, webColumns, scaler),
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          mainAxisExtent: extent,
        ),
        itemCount: count,
        itemBuilder: (_, index) => builder(index),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-skeleton-card'),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.gray100),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 160, radius: AppRadius.md),
          AppSpacing.h16,
          FractionallySizedBox(
            widthFactor: 0.75,
            child: SkeletonBox(height: 16, radius: 2),
          ),
          AppSpacing.h8,
          FractionallySizedBox(
            widthFactor: 0.5,
            child: SkeletonBox(height: 12, radius: 2),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlatos extends StatelessWidget {
  const _EmptyPlatos({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.emerald100),
            boxShadow: AppShadows.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 36,
                color: AppColors.emerald600,
              ),
              AppSpacing.h12,
              Text(
                'No se encontraron platos',
                textAlign: TextAlign.center,
                style: AppTextStyles.base.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray800,
                ),
              ),
              AppSpacing.h4,
              Text(
                'Prueba buscando con otro término o selecciona otra categoría.',
                textAlign: TextAlign.center,
                style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
              ),
              AppSpacing.h16,
              AppButton(
                label: 'Ver todos los platos',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: onShowAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
