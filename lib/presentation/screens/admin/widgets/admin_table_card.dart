import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:material_ui/material_ui.dart';

class AdminTableCard<T> extends StatelessWidget {
  const AdminTableCard({
    super.key,
    required this.title,
    required this.countLabel,
    required this.columns,
    required this.rows,
    required this.emptyMessage,
    this.loading = false,
  });

  final String title;
  final String countLabel;
  final List<ResponsiveColumn<T>> columns;
  final List<T> rows;
  final String emptyMessage;
  final bool loading;

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
                AppSpacing.w8,
                Text(
                  countLabel,
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
          if (loading && rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.s8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.emerald600,
                  ),
                ),
              ),
            )
          else
            ResponsiveDataTable<T>(
              columns: columns,
              rows: rows,
              emptyMessage: emptyMessage,
            ),
        ],
      ),
    );
  }
}
