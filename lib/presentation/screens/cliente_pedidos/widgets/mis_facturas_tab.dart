import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/helpers/date_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:material_ui/material_ui.dart';

class MisFacturasTab extends StatelessWidget {
  const MisFacturasTab({super.key, required this.facturas});

  final List<Factura> facturas;

  @override
  Widget build(BuildContext context) {
    final cell = AppTextStyles.xs.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.gray700,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: AppColors.emerald50.withValues(alpha: 0.4),
              border: const Border(
                bottom: BorderSide(color: AppColors.emerald100),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de Facturas Electrónicas',
                  style: AppTextStyles.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald950,
                  ),
                ),
                Text(
                  'Comprobantes autorizados emitidos a tu nombre o cédula',
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
          ResponsiveDataTable<Factura>(
            rows: facturas,
            emptyMessage: 'Aún no tienes facturas emitidas. Las facturas se generan automáticamente al completar y pagar tus pedidos.',
            columns: [
              ResponsiveColumn(
                label: 'Secuencial',
                cellBuilder: (_, factura) => Text(
                  factura.numeroSecuencial,
                  style: AppTextStyles.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald900,
                  ),
                ),
              ),
              ResponsiveColumn(
                label: 'Fecha',
                cellBuilder: (_, factura) {
                  final fecha = factura.fechaEmision;
                  return Text(
                    fecha == null ? '-' : AppDateFormat.date(fecha),
                    style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
                  );
                },
              ),
              ResponsiveColumn(
                label: 'Subtotal',
                cellBuilder: (_, factura) =>
                    Text(CurrencyFormat.format(factura.subtotal), style: cell),
              ),
              ResponsiveColumn(
                label: 'IVA (15%)',
                cellBuilder: (_, factura) => Text(
                  CurrencyFormat.format(factura.subtotalIva),
                  style: cell,
                ),
              ),
              ResponsiveColumn(
                label: 'Total',
                cellBuilder: (_, factura) => Text(
                  CurrencyFormat.format(factura.total),
                  style: AppTextStyles.sm.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald800,
                  ),
                ),
              ),
              ResponsiveColumn(
                label: 'Estado',
                cellBuilder: (_, factura) =>
                    StatusBadge(StatusBadges.factura(factura.estado.toJson())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
