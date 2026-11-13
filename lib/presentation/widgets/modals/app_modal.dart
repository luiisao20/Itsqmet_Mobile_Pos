import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

const double kAppModalMaxWidth = 512;

Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required Widget body,
  Widget? footer,
  bool useRootNavigator = true,
}) {
  if (context.isTablet) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierColor: AppColors.modalBarrier,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.s4),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kAppModalMaxWidth,
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.9,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: AppColors.emerald100),
                boxShadow: AppShadows.xl,
              ),
              child: _ModalContent(title: title, body: body, footer: footer),
            ),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    barrierColor: AppColors.modalBarrier,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlTop),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
        ),
        child: _ModalContent(title: title, body: body, footer: footer),
      ),
    ),
  );
}

void closeAppModal<T>(BuildContext context, [T? result]) {
  Navigator.of(context, rootNavigator: true).pop<T>(result);
}

class AppModalActions extends StatelessWidget {
  const AppModalActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      children: children,
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent({required this.title, required this.body, this.footer});

  final String title;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModalHeader(title: title),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: body,
          ),
        ),
        if (footer != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s3,
            ),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: Align(alignment: Alignment.centerRight, child: footer),
          ),
      ],
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.5),
        border: const Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.emerald950,
              ),
            ),
          ),
          AppSpacing.w8,
          InkWell(
            onTap: () => closeAppModal(context),
            borderRadius: AppRadius.smAll,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s1),
              child: Semantics(
                label: 'Cerrar',
                button: true,
                excludeSemantics: true,
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
