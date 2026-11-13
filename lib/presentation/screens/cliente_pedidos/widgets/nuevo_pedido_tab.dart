import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/order_summary.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/pill_selector.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/plato_card.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:material_ui/material_ui.dart';

class NuevoPedidoTab extends StatelessWidget {
  const NuevoPedidoTab({super.key, required this.state});

  final ClientePedidosState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientePedidosCubit>();
    final catalog = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillSelector<int?>(
          items: [
            const PillItem<int?>(value: null, label: 'Todos'),
            for (final categoria in state.categorias)
              PillItem<int?>(value: categoria.id, label: categoria.nombre),
          ],
          selected: state.selectedCategoriaId,
          onSelected: cubit.filterCategoria,
        ),
        AppSpacing.h24,
        _PlatosGrid(platos: state.platos, onAdd: cubit.addPlato),
      ],
    );
    final summary = OrderSummary(
      title: 'Mi Pedido Para Llevar',
      submitLabel: 'Enviar Pedido a Cocina',
      items: state.cart.items,
      observaciones: state.observaciones,
      loading: state.loadingOrder,
      onQuantityChange: cubit.changeQuantity,
      onRemoveItem: cubit.removeItem,
      onNotesChange: cubit.updateNotes,
      onObservacionesChange: cubit.updateObservaciones,
      onSubmit: cubit.submitOrder,
    );

    if (!context.atLeastLg) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [catalog, AppSpacing.h32, summary],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: catalog),
        AppSpacing.w32,
        Expanded(child: summary),
      ],
    );
  }
}

class _PlatosGrid extends StatelessWidget {
  const _PlatosGrid({required this.platos, required this.onAdd});

  static const double gap = AppSpacing.s4;
  static const double minCardWidth = 256;

  final List<Plato> platos;
  final ValueChanged<Plato> onAdd;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsTwo =
            constraints.maxWidth >= scaler.scale(minCardWidth) * 2 + gap;
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.atLeastSm && fitsTwo ? 2 : 1,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: PlatoCard.imageHeight + scaler.scale(175),
          ),
          itemCount: platos.length,
          itemBuilder: (_, index) =>
              PlatoCard(plato: platos[index], onAddToCart: onAdd),
        );
      },
    );
  }
}
