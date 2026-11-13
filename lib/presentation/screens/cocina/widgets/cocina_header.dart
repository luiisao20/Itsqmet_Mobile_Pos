import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:material_ui/material_ui.dart';

class CocinaHeader extends StatelessWidget {
  const CocinaHeader({
    super.key,
    required this.total,
    required this.filtro,
    required this.onFiltroChanged,
  });

  final int total;
  final CocinaFiltro filtro;
  final ValueChanged<CocinaFiltro> onFiltroChanged;

  @override
  Widget build(BuildContext context) {
    final filters = SegmentedTabs<CocinaFiltro>(
      selected: filtro,
      onChanged: onFiltroChanged,
      borderColor: AppColors.gray200,
      items: [
        SegmentedTabItem(value: CocinaFiltro.todos, label: 'Todos ($total)'),
        const SegmentedTabItem(
          value: CocinaFiltro.abierto,
          label: 'Nuevos',
          activeColor: AppColors.sky600,
        ),
        const SegmentedTabItem(
          value: CocinaFiltro.enPreparacion,
          label: 'En Preparación',
          activeColor: AppColors.amber600,
        ),
        const SegmentedTabItem(
          value: CocinaFiltro.servido,
          label: 'Listos / Servidos',
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.emerald100)),
      ),
      child: context.atLeastMd
          ? Row(
              children: [
                const Expanded(child: _Title()),
                AppSpacing.w16,
                Flexible(child: filters),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const _Title(), AppSpacing.h16, filters],
            ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.emerald600,
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadows.xs,
          ),
          child: const Icon(
            Icons.soup_kitchen,
            size: 22,
            color: AppColors.white,
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Monitor KDS de Cocina & Bar',
                    style: AppTextStyles.x2l.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald950,
                    ),
                  ),
                  const _LiveBadge(),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Recepción instantánea de comandas por orden de llegada con instrucciones de preparación',
                style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: AppColors.emerald200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.emerald500,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.w4,
          Flexible(
            child: Text(
              'WebSocket En Vivo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.text11.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.emerald700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
