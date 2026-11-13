import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/widgets/caja_pedido_card.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/widgets/facturar_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/widgets/facturas_recientes_card.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/widgets/pago_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/layout/page_container.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class CajaScreen extends StatelessWidget {
  const CajaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CajaCubit>(
      create: (_) => getIt<CajaCubit>()..load(),
      child: const CajaView(),
    );
  }
}

class CajaView extends StatelessWidget {
  const CajaView({super.key});

  Future<void> _facturar(BuildContext context, Pedido pedido) async {
    final cubit = context.read<CajaCubit>()..openFacturar(pedido);
    await showFacturarModal(context: context, cubit: cubit);
    if (cubit.isClosed) return;
    if (cubit.state.facturar != null) cubit.cancelFacturar();
    if (cubit.state.pago != null && context.mounted) {
      await _cobrar(context, cubit);
    }
  }

  Future<void> _registrarPago(BuildContext context, Factura factura) async {
    final cubit = context.read<CajaCubit>()..openPago(factura);
    await _cobrar(context, cubit);
  }

  Future<void> _cobrar(BuildContext context, CajaCubit cubit) async {
    await showPagoModal(context: context, cubit: cubit);
    if (cubit.isClosed) return;
    if (cubit.state.pago != null) cubit.cancelPago();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CajaCubit, CajaState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (_, state) {
        final message = state.message!;
        if (message.isError) {
          NotificationsService.showError(message.text);
        } else {
          NotificationsService.showSuccess(message.text);
        }
      },
      child: BlocBuilder<CajaCubit, CajaState>(
        builder: (context, state) {
          final pedidos = _PedidosSection(
            state: state,
            onRefresh: context.read<CajaCubit>().load,
            onFacturar: (pedido) => _facturar(context, pedido),
          );
          final facturas = FacturasRecientesCard(
            facturas: state.facturas,
            onRegistrarPago: (factura) => _registrarPago(context, factura),
          );

          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                AppSpacing.h24,
                if (context.atLeastLg)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: pedidos),
                      AppSpacing.w32,
                      Expanded(child: facturas),
                    ],
                  )
                else ...[
                  pedidos,
                  AppSpacing.h32,
                  facturas,
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.emerald100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Módulo de Caja & Facturación',
            style: AppTextStyles.x2l.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.emerald950,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Emisión de facturas electrónicas autorizadas y recaudación de pagos (Efectivo, Tarjeta, Transferencia)',
            style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

class _PedidosSection extends StatelessWidget {
  const _PedidosSection({
    required this.state,
    required this.onRefresh,
    required this.onFacturar,
  });

  final CajaState state;
  final VoidCallback onRefresh;
  final ValueChanged<Pedido> onFacturar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Comandas Listas para Facturar (${state.pedidos.length})',
                style: AppTextStyles.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Actualizar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.emerald700,
                textStyle: AppTextStyles.xs.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        AppSpacing.h16,
        _body(context),
      ],
    );
  }

  Widget _body(BuildContext context) {
    if (state.loading) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          'Cargando comandas pendientes...',
          textAlign: TextAlign.center,
          style: AppTextStyles.sm.copyWith(color: AppColors.gray400),
        ),
      );
    }

    if (state.pedidos.isEmpty) return const _SinComandas();

    final columns = context.atLeastSm ? 2 : 1;
    final pedidos = state.pedidos;
    final rows = <Widget>[];
    for (var start = 0; start < pedidos.length; start += columns) {
      final chunk = pedidos.skip(start).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < columns; index++) ...[
                if (index > 0) AppSpacing.w16,
                Expanded(
                  child: index < chunk.length
                      ? CajaPedidoCard(
                          key: ValueKey(chunk[index].id),
                          pedido: chunk[index],
                          onFacturar: () => onFacturar(chunk[index]),
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
          if (index > 0) AppSpacing.h16,
          row,
        ],
      ],
    );
  }
}

class _SinComandas extends StatelessWidget {
  const _SinComandas();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 40, color: AppColors.gray400),
          AppSpacing.h12,
          Text(
            'No hay comandas pendientes de cobro',
            textAlign: TextAlign.center,
            style: AppTextStyles.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray700,
            ),
          ),
          AppSpacing.h4,
          Text(
            'Los pedidos aparecerán aquí cuando estén marcados como Servidos o Para Llevar.',
            textAlign: TextAlign.center,
            style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
