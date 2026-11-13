import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showAdminFormModal<T>({
  required BuildContext context,
  required AdminCrudCubit<T> cubit,
  required String title,
  required String submitLabel,
  required Widget body,
  required Future<bool> Function() onSubmit,
}) {
  return showAppModal<void>(
    context: context,
    title: title,
    body: body,
    footer: _AdminFormFooter<T>(
      cubit: cubit,
      submitLabel: submitLabel,
      onSubmit: onSubmit,
    ),
  );
}

class _AdminFormFooter<T> extends StatelessWidget {
  const _AdminFormFooter({
    required this.cubit,
    required this.submitLabel,
    required this.onSubmit,
  });

  final AdminCrudCubit<T> cubit;
  final String submitLabel;
  final Future<bool> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCrudCubit<T>, AdminCrudState<T>>(
      bloc: cubit,
      builder: (context, state) => AppModalActions(
        children: [
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            onPressed: () => closeAppModal<void>(context),
          ),
          AppButton(
            label: submitLabel,
            loadingLabel: 'Guardando...',
            loading: state.submitting,
            size: AppButtonSize.sm,
            onPressed: () async {
              final ok = await onSubmit();
              if (ok && context.mounted) closeAppModal<void>(context);
            },
          ),
        ],
      ),
    );
  }
}
