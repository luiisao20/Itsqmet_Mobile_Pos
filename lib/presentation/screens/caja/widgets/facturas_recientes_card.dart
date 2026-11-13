import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:material_ui/material_ui.dart';

class FacturasRecientesCard extends StatelessWidget {
  const FacturasRecientesCard({
    super.key,
    required this.facturas,
    required this.onRegistrarPago,
  });

  final List<Factura> facturas;
  final ValueChanged<Factura> onRegistrarPago;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
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
                  child: Text(
                    'Facturas Recientes',
                    style: AppTextStyles.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald950,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: AppRadius.fullAll,
                  ),
                  child: Text(
                    'Hoy',
                    style: AppTextStyles.xs.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (facturas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
              child: Text(
                'No hay facturas emitidas recientemente.',
                textAlign: TextAlign.center,
                style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
              ),
            )
          else
            for (final (index, factura) in facturas.indexed) ...[
              if (index > 0) const Divider(height: 1, color: AppColors.gray100),
              _FacturaRow(
                factura: factura,
                onRegistrarPago: () => onRegistrarPago(factura),
              ),
            ],
        ],
      ),
    );
  }
}

class _FacturaRow extends StatelessWidget {
  const _FacturaRow({required this.factura, required this.onRegistrarPago});

  final Factura factura;
  final VoidCallback onRegistrarPago;

  @override
  Widget build(BuildContext context) {
    final cliente = factura.razonSocialCliente;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factura.numeroSecuencial,
                  style: AppTextStyles.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                if (cliente != null)
                  Text(
                    cliente,
                    style: AppTextStyles.text11.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.w8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormat.format(factura.total),
                style: AppTextStyles.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald700,
                ),
              ),
              InkWell(
                onTap: onRegistrarPago,
                borderRadius: AppRadius.smAll,
                child: Text(
                  '+ Registrar Pago',
                  style: AppTextStyles.text11.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
