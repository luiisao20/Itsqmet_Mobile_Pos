import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_cliente_detalle_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showClienteDetalleModal(
  BuildContext context,
  Cliente cliente,
) async {
  await showAppModal<void>(
    context: context,
    title: 'Historial del Cliente',
    body: BlocProvider<AdminClienteDetalleCubit>(
      create: (_) => getIt<AdminClienteDetalleCubit>(param1: cliente)..load(),
      child: const _ClienteDetalleContent(),
    ),
  );
}

class _ClienteDetalleContent extends StatelessWidget {
  const _ClienteDetalleContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminClienteDetalleCubit, AdminClienteDetalleState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ClienteInfoCard(cliente: state.cliente),
              AppSpacing.h12,
              _MetricasResumen(state: state),
              AppSpacing.h16,
              _TabSelector(state: state),
              AppSpacing.h12,
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.emerald600,
                    ),
                  ),
                )
              else if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    state.errorMessage!,
                    style: AppTextStyles.sm.copyWith(color: AppColors.red600),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (state.tab == AdminClienteDetalleTab.pedidos)
                _PedidosList(pedidos: state.pedidos)
              else
                _FacturasList(facturas: state.facturas),
              AppSpacing.h16,
              AppButton(
                label: 'Cerrar',
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClienteInfoCard extends StatelessWidget {
  const _ClienteInfoCard({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.emerald100,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.emerald800,
                    size: 20,
                  ),
                ),
              ),
              AppSpacing.w8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.razonSocial,
                      style: AppTextStyles.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          cliente.tipoIdentificacion.toJson(),
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                          ),
                        ),
                        AppSpacing.w4,
                        Text(
                          cliente.identificacion,
                          style: AppTextStyles.mono.copyWith(
                            fontSize: 11,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cliente.email != null && cliente.email!.isNotEmpty ||
              cliente.telefono != null && cliente.telefono!.isNotEmpty) ...[
            AppSpacing.h8,
            const Divider(color: AppColors.gray200, height: 1),
            AppSpacing.h8,
            Row(
              children: [
                if (cliente.email != null && cliente.email!.isNotEmpty)
                  Expanded(
                    child: Text(
                      '✉ ${cliente.email}',
                      style: AppTextStyles.text10.copyWith(color: AppColors.gray600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
                  Text(
                    '📞 ${cliente.telefono}',
                    style: AppTextStyles.text10.copyWith(color: AppColors.gray600),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricasResumen extends StatelessWidget {
  const _MetricasResumen({required this.state});

  final AdminClienteDetalleState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricaCard(
            label: 'PEDIDOS',
            value: state.pedidosCount.toString(),
            color: AppColors.gray900,
          ),
        ),
        AppSpacing.w8,
        Expanded(
          child: _MetricaCard(
            label: 'FACTURAS',
            value: state.facturasCount.toString(),
            color: AppColors.gray900,
          ),
        ),
        AppSpacing.w8,
        Expanded(
          child: _MetricaCard(
            label: 'GASTO TOTAL',
            value: '\$${state.totalFacturado.toStringAsFixed(2)}',
            color: AppColors.emerald700,
          ),
        ),
      ],
    );
  }
}

class _MetricaCard extends StatelessWidget {
  const _MetricaCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray400,
            ),
          ),
          AppSpacing.h4,
          Text(
            value,
            style: AppTextStyles.sm.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.state});

  final AdminClienteDetalleState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminClienteDetalleCubit>();
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: '📦 Pedidos (${state.pedidosCount})',
            active: state.tab == AdminClienteDetalleTab.pedidos,
            onTap: () => cubit.setTab(AdminClienteDetalleTab.pedidos),
          ),
        ),
        AppSpacing.w8,
        Expanded(
          child: _TabButton(
            label: '🧾 Facturas (${state.facturasCount})',
            active: state.tab == AdminClienteDetalleTab.facturas,
            onTap: () => cubit.setTab(AdminClienteDetalleTab.facturas),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.emerald600 : AppColors.gray100,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? AppColors.white : AppColors.gray700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PedidosList extends StatelessWidget {
  const _PedidosList({required this.pedidos});

  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'El cliente no registra pedidos realizados',
            style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pedidos.length,
      separatorBuilder: (_, _) => AppSpacing.h8,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        final fechaStr = pedido.fechaApertura != null
            ? dateFormat.format(pedido.fechaApertura!)
            : '-';

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${pedido.id}',
                        style: AppTextStyles.xs.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                        ),
                      ),
                      AppSpacing.w4,
                      Text(
                        pedido.tipo == TipoPedido.salon
                            ? 'Mesa ${pedido.numeroMesa ?? '-'}'
                            : 'Para Llevar',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(StatusBadges.pedido(pedido.estado.toJson())),
                ],
              ),
              AppSpacing.h4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fechaStr,
                    style: AppTextStyles.text10.copyWith(color: AppColors.gray400),
                  ),
                  Text(
                    '\$${pedido.total.toStringAsFixed(2)}',
                    style: AppTextStyles.sm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald700,
                    ),
                  ),
                ],
              ),
              if (pedido.detalles.isNotEmpty) ...[
                AppSpacing.h8,
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pedido.detalles.map((det) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${det.cantidad}x ${det.nombrePlato}',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.gray800,
                                ),
                              ),
                            ),
                            Text(
                              '\$${det.subtotal.toStringAsFixed(2)}',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FacturasList extends StatelessWidget {
  const _FacturasList({required this.facturas});

  final List<Factura> facturas;

  @override
  Widget build(BuildContext context) {
    if (facturas.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'El cliente no registra facturas emitidas',
            style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: facturas.length,
      separatorBuilder: (_, _) => AppSpacing.h8,
      itemBuilder: (context, index) {
        final factura = facturas[index];
        final fechaStr = factura.fechaEmision != null
            ? dateFormat.format(factura.fechaEmision!)
            : '-';

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    factura.numeroSecuencial,
                    style: AppTextStyles.xs.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                    ),
                  ),
                  StatusBadge(StatusBadges.factura(factura.estado.toJson())),
                ],
              ),
              AppSpacing.h4,
              Text(
                fechaStr,
                style: AppTextStyles.text10.copyWith(color: AppColors.gray400),
              ),
              AppSpacing.h4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal: \$${factura.subtotal.toStringAsFixed(2)} | IVA: \$${factura.subtotalIva.toStringAsFixed(2)}',
                    style: AppTextStyles.text10.copyWith(color: AppColors.gray600),
                  ),
                  Text(
                    '\$${factura.total.toStringAsFixed(2)}',
                    style: AppTextStyles.sm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
