import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/widgets/mis_facturas_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/widgets/mis_pedidos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/widgets/nuevo_pedido_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/segmented_tabs.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/feedback/success_banner.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/layout/page_container.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class ClientePedidosScreen extends StatelessWidget {
  const ClientePedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientePedidosCubit>(
      create: (_) => getIt<ClientePedidosCubit>()..load(),
      child: const ClientePedidosView(),
    );
  }
}

class ClientePedidosView extends StatelessWidget {
  const ClientePedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientePedidosCubit, ClientePedidosState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (_, state) =>
          NotificationsService.showError(state.error!.message),
      child: BlocBuilder<ClientePedidosCubit, ClientePedidosState>(
        builder: (context, state) {
          final cubit = context.read<ClientePedidosCubit>();
          final success = state.successMessage;
          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  tab: state.tab,
                  pedidosCount: state.misPedidos.length,
                  onTabChanged: cubit.changeTab,
                ),
                AppSpacing.h24,
                if (success != null) ...[
                  SuccessBanner(message: success),
                  AppSpacing.h24,
                ],
                switch (state.tab) {
                  ClienteTab.nuevo => NuevoPedidoTab(state: state),
                  ClienteTab.historial => MisPedidosTab(
                    loading: state.loadingList,
                    pedidos: state.misPedidos,
                    onCrearPedido: () => cubit.changeTab(ClienteTab.nuevo),
                  ),
                  ClienteTab.facturas => MisFacturasTab(
                    facturas: state.misFacturas,
                  ),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tab,
    required this.pedidosCount,
    required this.onTabChanged,
  });

  final ClienteTab tab;
  final int pedidosCount;
  final ValueChanged<ClienteTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = SegmentedTabs<ClienteTab>(
      selected: tab,
      onChanged: onTabChanged,
      items: [
        const SegmentedTabItem(
          value: ClienteTab.nuevo,
          label: 'Nuevo Pedido (Llevar)',
          icon: Icons.shopping_bag_outlined,
        ),
        SegmentedTabItem(
          value: ClienteTab.historial,
          label: 'Mis Pedidos',
          icon: Icons.assignment_outlined,
          badgeCount: pedidosCount > 0 ? pedidosCount : null,
        ),
        const SegmentedTabItem(
          value: ClienteTab.facturas,
          label: 'Mis Facturas',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.emerald100)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s4,
          runSpacing: AppSpacing.s4,
          children: [const _Title(), tabs],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel de Pedidos & Facturas',
          style: AppTextStyles.x2l.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.emerald950,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Arma tu pedido para llevar en tiempo real y consulta tu historial fiscal',
          style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
