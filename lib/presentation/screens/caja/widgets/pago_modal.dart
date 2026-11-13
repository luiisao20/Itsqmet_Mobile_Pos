import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showPagoModal({
  required BuildContext context,
  required CajaCubit cubit,
}) {
  final form = cubit.state.pago;
  if (form == null) return Future.value();
  return showAppModal<void>(
    context: context,
    title: 'Registrar Pago - Factura ${form.factura.numeroSecuencial}',
    body: BlocProvider.value(value: cubit, child: const _PagoBody()),
    footer: BlocProvider.value(value: cubit, child: const _PagoFooter()),
  );
}

const Map<MetodoPago, (IconData, String)> _metodos = {
  MetodoPago.efectivo: (Icons.payments, 'Efectivo'),
  MetodoPago.tarjeta: (Icons.credit_card, 'Tarjeta de Débito / Crédito'),
  MetodoPago.transferencia: (Icons.account_balance, 'Transferencia Bancaria'),
};

class _PagoBody extends StatelessWidget {
  const _PagoBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CajaCubit>();
    return BlocBuilder<CajaCubit, CajaState>(
      buildWhen: (_, current) => current.pago != null,
      builder: (context, state) {
        final form = state.pago!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdownField<MetodoPago>(
              label: 'Método de Pago',
              required: true,
              value: form.metodoPago,
              onChanged: (value) {
                if (value != null) cubit.changeMetodoPago(value);
              },
              items: [
                for (final MapEntry(key: metodo, value: (icon, label))
                    in _metodos.entries)
                  DropdownMenuItem(
                    value: metodo,
                    child: Row(
                      children: [
                        Icon(icon, size: 16, color: AppColors.emerald700),
                        AppSpacing.w8,
                        Flexible(
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            AppSpacing.h16,
            AppTextField(
              key: const ValueKey('caja.monto'),
              label: 'Monto Cobrado (\$)',
              required: true,
              initialValue: CurrencyFormat.plain(form.monto),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: cubit.changeMonto,
            ),
            AppSpacing.h16,
            AppTextField(
              key: const ValueKey('caja.referencia'),
              label: 'Referencia de Transacción (opcional)',
              hint: 'ej: Lote 45892 o Nro Transferencia',
              initialValue: form.referencia,
              onChanged: cubit.changeReferencia,
            ),
          ],
        );
      },
    );
  }
}

class _PagoFooter extends StatelessWidget {
  const _PagoFooter();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CajaCubit>();
    return BlocBuilder<CajaCubit, CajaState>(
      buildWhen: (_, current) => current.pago != null,
      builder: (context, state) {
        final submitting = state.pago?.submitting ?? false;
        return AppModalActions(
          children: [
            AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: () => closeAppModal<void>(context),
            ),
            AppButton(
              label: 'Finalizar Pago',
              loadingLabel: 'Registrando...',
              loading: submitting,
              size: AppButtonSize.sm,
              onPressed: () async {
                final ok = await cubit.registrarPago();
                if (ok && context.mounted) closeAppModal<void>(context);
              },
            ),
          ],
        );
      },
    );
  }
}
