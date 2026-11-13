import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/helpers/date_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class CajaPedidoCard extends StatelessWidget {
  const CajaPedidoCard({
    super.key,
    required this.pedido,
    required this.onFacturar,
  });

  final Pedido pedido;
  final VoidCallback onFacturar;

  @override
  Widget build(BuildContext context) {
    final fecha = pedido.fechaApertura;
    final lineStyle = AppTextStyles.xs.copyWith(color: AppColors.gray600);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.s2),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray100)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${pedido.id}',
                        style: AppTextStyles.sm.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald950,
                        ),
                      ),
                      if (fecha != null)
                        Text(
                          AppDateFormat.time(fecha),
                          style: AppTextStyles.text11.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                    ],
                  ),
                ),
                _TipoTag(pedido: pedido),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: Column(
              children: [
                for (final detalle in pedido.detalles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${detalle.cantidad}x ${detalle.nombrePlato}',
                            style: lineStyle,
                          ),
                        ),
                        Text(
                          CurrencyFormat.format(detalle.subtotal),
                          style: lineStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.s3),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: AppButton(
              label: 'Facturar y Cobrar',
              leading: Icons.credit_card,
              size: AppButtonSize.sm,
              expand: true,
              onPressed: onFacturar,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoTag extends StatelessWidget {
  const _TipoTag({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final salon = pedido.tipo == TipoPedido.salon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: salon ? AppColors.emerald100 : AppColors.purple100,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        salon ? 'Mesa ${pedido.numeroMesa}' : 'Llevar',
        style: AppTextStyles.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: salon ? AppColors.emerald800 : AppColors.purple800,
        ),
      ),
    );
  }
}
