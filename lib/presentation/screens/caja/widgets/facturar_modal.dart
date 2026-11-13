import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showFacturarModal({
  required BuildContext context,
  required CajaCubit cubit,
}) {
  final form = cubit.state.facturar;
  if (form == null) return Future.value();
  return showAppModal<void>(
    context: context,
    title: 'Emitir Factura - Pedido #${form.pedido.id}',
    body: BlocProvider.value(value: cubit, child: const _FacturarBody()),
    footer: BlocProvider.value(value: cubit, child: const _FacturarFooter()),
  );
}

class _FacturarBody extends StatelessWidget {
  const _FacturarBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CajaCubit>();
    return BlocBuilder<CajaCubit, CajaState>(
      buildWhen: (_, current) => current.facturar != null,
      builder: (context, state) {
        final form = state.facturar!;
        final totals = form.totals;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              key: const ValueKey('caja.secuencial'),
              label: 'Número Secuencial de Factura',
              required: true,
              initialValue: form.numeroSecuencial,
              onChanged: cubit.changeNumeroSecuencial,
            ),
            AppSpacing.h16,
            AppTextField(
              key: const ValueKey('caja.propina'),
              label: 'Propina Sugerida (\$)',
              hint: '0.00',
              initialValue: '0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: cubit.changePropina,
            ),
            AppSpacing.h16,
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.emerald50.withValues(alpha: 0.5),
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: AppColors.emerald100),
              ),
              child: Column(
                children: [
                  _TotalRow('Subtotal', totals.subtotal),
                  _TotalRow('IVA (15%)', totals.iva),
                  if (totals.propina > 0) _TotalRow('Propina', totals.propina),
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.s2),
                    padding: const EdgeInsets.only(top: AppSpacing.s2),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.emerald200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total a Facturar',
                            style: AppTextStyles.sm.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald950,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormat.format(totals.total),
                          style: AppTextStyles.base.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.emerald700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value);

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.xs.copyWith(color: AppColors.gray600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(CurrencyFormat.format(value), style: style),
        ],
      ),
    );
  }
}

class _FacturarFooter extends StatelessWidget {
  const _FacturarFooter();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CajaCubit>();
    return BlocBuilder<CajaCubit, CajaState>(
      buildWhen: (_, current) => current.facturar != null,
      builder: (context, state) {
        final submitting = state.facturar?.submitting ?? false;
        return AppModalActions(
          children: [
            AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: () => closeAppModal<void>(context),
            ),
            AppButton(
              label: 'Confirmar Factura',
              loadingLabel: 'Emitiendo...',
              loading: submitting,
              size: AppButtonSize.sm,
              onPressed: () async {
                final ok = await cubit.emitirFactura();
                if (ok && context.mounted) closeAppModal<void>(context);
              },
            ),
          ],
        );
      },
    );
  }
}
