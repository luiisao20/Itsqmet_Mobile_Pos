import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/pill_selector.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_search_field.dart';
import 'package:material_ui/material_ui.dart';

class HomeFilterBar extends StatelessWidget {
  const HomeFilterBar({
    super.key,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.searchController,
    required this.onCategoriaSelected,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final List<CategoriaPlato> categorias;
  final int? selectedCategoriaId;
  final TextEditingController searchController;
  final ValueChanged<int?> onCategoriaSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  static const double searchWidth = 288;

  @override
  Widget build(BuildContext context) {
    final pills = PillSelector<int?>(
      items: [
        const PillItem<int?>(value: null, label: 'Todos los Platos'),
        for (final categoria in categorias)
          PillItem<int?>(value: categoria.id, label: categoria.nombre),
      ],
      selected: selectedCategoriaId,
      onSelected: onCategoriaSelected,
    );
    final search = AppSearchField(
      controller: searchController,
      hint: 'Buscar plato o ingrediente...',
      onChanged: onSearchChanged,
      onSubmitted: (_) => onSearchSubmitted(),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: context.atLeastMd
          ? Row(
              children: [
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: pills),
                ),
                AppSpacing.w16,
                SizedBox(width: searchWidth, child: search),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [pills, AppSpacing.h16, search],
            ),
    );
  }
}
