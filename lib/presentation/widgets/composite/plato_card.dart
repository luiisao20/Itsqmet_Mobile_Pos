import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/plato.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class PlatoCard extends StatelessWidget {
  const PlatoCard({super.key, required this.plato, this.onAddToCart});

  static const double imageHeight = 176;
  static const String defaultDescription =
      'Plato preparado al momento con insumos frescos';

  final Plato plato;
  final ValueChanged<Plato>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.hasBoundedHeight;
          final body = Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_info(), _footer()],
            ),
          );
          return Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              if (bounded) Expanded(child: body) else body,
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    final url = plato.urlImagen;
    final categoria = plato.nombreCategoria;
    return SizedBox(
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.emerald50),
          if (url != null && url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _NoImage(),
            )
          else
            const _NoImage(),
          Positioned(
            top: AppSpacing.s3,
            right: AppSpacing.s3,
            child: plato.disponible
                ? const AppBadge(
                    label: 'Disponible',
                    variant: BadgeVariant.success,
                  )
                : const AppBadge(
                    label: 'Agotado',
                    variant: BadgeVariant.danger,
                  ),
          ),
          if (categoria != null && categoria.isNotEmpty)
            Positioned(
              left: AppSpacing.s3,
              bottom: AppSpacing.s3,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.chipOverlay,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: 2,
                  ),
                  child: Text(
                    categoria,
                    style: AppTextStyles.text11.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _info() {
    final descripcion = plato.descripcion;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plato.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.base.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        AppSpacing.h4,
        Text(
          descripcion == null || descripcion.isEmpty
              ? defaultDescription
              : descripcion,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _footer() {
    final callback = onAddToCart;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s4),
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio',
                style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
              ),
              Text(
                CurrencyFormat.format(plato.precioUnitario),
                style: AppTextStyles.price,
              ),
            ],
          ),
          AppButton(
            label: '+ Agregar',
            size: AppButtonSize.sm,
            onPressed: plato.disponible && callback != null
                ? () => callback(plato)
                : null,
          ),
        ],
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sin imagen',
        style: AppTextStyles.base.copyWith(
          color: AppColors.emerald300,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
