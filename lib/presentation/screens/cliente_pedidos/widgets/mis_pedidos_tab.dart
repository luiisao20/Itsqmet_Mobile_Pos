import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/helpers/date_format.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class MisPedidosTab extends StatelessWidget {
  const MisPedidosTab({
    super.key,
    required this.loading,
    required this.pedidos,
    required this.onCrearPedido,
  });

  final bool loading;
  final List<Pedido> pedidos;
  final VoidCallback onCrearPedido;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          'Cargando tus pedidos...',
          textAlign: TextAlign.center,
          style: AppTextStyles.sm.copyWith(color: AppColors.gray400),
        ),
      );
    }
    if (pedidos.isEmpty) return _SinPedidos(onCrearPedido: onCrearPedido);

    final columns = context.atLeastMd ? 2 : 1;
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
                      ? _PedidoCard(
                          key: ValueKey(chunk[index].id),
                          pedido: chunk[index],
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

class _SinPedidos extends StatelessWidget {
  const _SinPedidos({required this.onCrearPedido});

  final VoidCallback onCrearPedido;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: AppColors.emerald100),
          boxShadow: AppShadows.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.gray400,
            ),
            AppSpacing.h12,
            Text(
              'No tienes pedidos registrados',
              textAlign: TextAlign.center,
              style: AppTextStyles.base.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
            AppSpacing.h4,
            Text(
              'Arma tu primer pedido para llevar en la pestaña anterior.',
              textAlign: TextAlign.center,
              style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
            ),
            AppSpacing.h16,
            AppButton(
              label: 'Crear Pedido',
              size: AppButtonSize.sm,
              onPressed: onCrearPedido,
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({super.key, required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final observaciones = pedido.observaciones;
    final fecha = pedido.fechaApertura;
    final footerStyle = AppTextStyles.text11.copyWith(color: AppColors.gray400);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Pedido #${pedido.id}',
                        style: AppTextStyles.sm.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald950,
                        ),
                      ),
                      _TipoTag(tipo: pedido.tipo),
                    ],
                  ),
                ),
                AppSpacing.w8,
                StatusBadge(StatusBadges.pedido(pedido.estado.toJson())),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: Column(
              children: [
                for (final detalle in pedido.detalles) _DetalleRow(detalle),
              ],
            ),
          ),
          if (observaciones != null && observaciones.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.s2),
              padding: const EdgeInsets.all(AppSpacing.s2),
              decoration: BoxDecoration(
                color: AppColors.emerald50.withValues(alpha: 0.5),
                borderRadius: AppRadius.smAll,
                border: Border.all(color: AppColors.emerald100),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Observación:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' $observaciones'),
                  ],
                ),
                style: AppTextStyles.text11.copyWith(
                  color: AppColors.emerald900,
                ),
              ),
            ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.s3),
            padding: const EdgeInsets.only(top: AppSpacing.s3),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Registrado: ${fecha == null ? '' : AppDateFormat.dateTime(fecha)}',
                    style: footerStyle,
                  ),
                ),
                Text(
                  '${pedido.detalles.length} items',
                  style: footerStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoTag extends StatelessWidget {
  const _TipoTag({required this.tipo});

  final TipoPedido tipo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.emerald200),
      ),
      child: Text(
        tipo.toJson(),
        style: AppTextStyles.text11.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.emerald800,
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  const _DetalleRow(this.detalle);

  final DetallePedido detalle;

  @override
  Widget build(BuildContext context) {
    final notas = detalle.notasPreparacion;
    final style = AppTextStyles.xs.copyWith(color: AppColors.gray600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${detalle.cantidad}x',
                      style: style.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray800,
                      ),
                    ),
                    AppSpacing.w8,
                    Flexible(child: Text(detalle.nombrePlato, style: style)),
                  ],
                ),
                if (notas != null && notas.isNotEmpty)
                  Text(
                    '"$notas"',
                    style: AppTextStyles.text11.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.emerald700,
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.w8,
          Text(
            CurrencyFormat.format(detalle.subtotal),
            style: style.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
