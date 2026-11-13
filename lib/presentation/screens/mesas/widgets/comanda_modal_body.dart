import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:material_ui/material_ui.dart';

class ComandaModalBody extends StatelessWidget {
  const ComandaModalBody({super.key, required this.numeroMesa});

  static const double platosMaxHeight = 224;

  final int numeroMesa;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MesasCubit>();
    return BlocBuilder<MesasCubit, MesasState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Selecciona los platos para los comensales de la Mesa $numeroMesa.',
            style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
          ),
          AppSpacing.h16,
          _PlatoPicker(platos: state.platos, onAdd: cubit.addPlato),
          AppSpacing.h16,
          if (state.comandaError != null) ...[
            ErrorBanner(message: state.comandaError!),
            AppSpacing.h16,
          ],
          OrderSummary(
            title: 'Items en Comanda',
            submitLabel: 'Enviar Comanda a Cocina',
            items: state.comanda.items,
            observaciones: state.observaciones,
            loading: state.loadingOrder,
            onQuantityChange: cubit.changeQuantity,
            onRemoveItem: cubit.removeItem,
            onNotesChange: cubit.updateNotes,
            onObservacionesChange: cubit.updateObservaciones,
            onSubmit: () => _submit(context, cubit),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, MesasCubit cubit) async {
    final sent = await cubit.submitComanda();
    if (!sent || !context.mounted) return;
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      closeAppModal<void>(context);
    }
  }
}

class _PlatoPicker extends StatelessWidget {
  const _PlatoPicker({required this.platos, required this.onAdd});

  final List<Plato> platos;
  final ValueChanged<Plato> onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: ComandaModalBody.platosMaxHeight,
      ),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.gray50.withValues(alpha: 0.5),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.gray100),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: platos.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, thickness: 1, color: AppColors.gray100),
        itemBuilder: (context, index) {
          final plato = platos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s2,
                    children: [
                      Text(
                        plato.nombre,
                        style: AppTextStyles.xs.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray800,
                        ),
                      ),
                      Text(
                        CurrencyFormat.format(plato.precioUnitario),
                        style: AppTextStyles.xs.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.emerald700,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.w8,
                AppButton(
                  label: '+ Agregar',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => onAdd(plato),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
