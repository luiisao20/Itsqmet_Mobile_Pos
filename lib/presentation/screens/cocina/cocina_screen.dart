import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/widgets/cocina_header.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/widgets/cocina_pedido_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/layout/page_container.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class CocinaScreen extends StatelessWidget {
  const CocinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CocinaCubit>(
      create: (_) => getIt<CocinaCubit>()..load(),
      child: const CocinaView(),
    );
  }
}

class CocinaView extends StatelessWidget {
  const CocinaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CocinaCubit, CocinaState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (_, state) =>
          NotificationsService.showError(state.error!.message),
      child: BlocBuilder<CocinaCubit, CocinaState>(
        builder: (context, state) {
          final cubit = context.read<CocinaCubit>();
          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CocinaHeader(
                  total: state.pedidos.length,
                  filtro: state.filtro,
                  onFiltroChanged: cubit.changeFiltro,
                ),
                AppSpacing.h24,
                _Body(state: state, onUpdateEstado: cubit.updateEstado),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onUpdateEstado});

  final CocinaState state;
  final void Function(Pedido pedido, EstadoPedido estado) onUpdateEstado;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return Padding(
        padding: const EdgeInsets.all(64),
        child: Text(
          'Cargando monitor de cocina...',
          textAlign: TextAlign.center,
          style: AppTextStyles.sm.copyWith(color: AppColors.gray400),
        ),
      );
    }

    final pedidos = state.filteredPedidos;
    if (pedidos.isEmpty) return const _AllCaughtUp();

    final columns = context.atLeastLg ? 3 : (context.atLeastMd ? 2 : 1);
    final rows = <Widget>[];
    for (var start = 0; start < pedidos.length; start += columns) {
      final chunk = pedidos.skip(start).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < columns; index++) ...[
                if (index > 0) AppSpacing.w24,
                Expanded(
                  child: index < chunk.length
                      ? CocinaPedidoCard(
                          key: ValueKey(chunk[index].id),
                          pedido: chunk[index],
                          onUpdateEstado: onUpdateEstado,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) AppSpacing.h24,
          row,
        ],
      ],
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        padding: const EdgeInsets.all(64),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: AppColors.emerald100),
          boxShadow: AppShadows.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: AppColors.amber500),
            AppSpacing.h16,
            Text(
              '¡Todo al día en Cocina!',
              textAlign: TextAlign.center,
              style: AppTextStyles.base.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
            AppSpacing.h4,
            Text(
              'No hay pedidos pendientes por preparar en este momento. La pantalla se actualizará automáticamente con campanilla al recibir un nuevo pedido.',
              textAlign: TextAlign.center,
              style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }
}
