import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/cards/app_card.dart';
import 'package:material_ui/material_ui.dart';

typedef ResponsiveCellBuilder<T> = Widget Function(BuildContext context, T row);

@immutable
class ResponsiveColumn<T> {
  const ResponsiveColumn({
    required this.label,
    required this.cellBuilder,
    this.alignEnd = false,
    this.showOnMobile = true,
  });

  final String label;
  final ResponsiveCellBuilder<T> cellBuilder;
  final bool alignEnd;
  final bool showOnMobile;
}

class ResponsiveDataTable<T> extends StatelessWidget {
  const ResponsiveDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No hay registros',
    this.mobileCardBuilder,
  });

  final List<ResponsiveColumn<T>> columns;
  final List<T> rows;
  final String emptyMessage;
  final ResponsiveCellBuilder<T>? mobileCardBuilder;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
        ),
      );
    }
    return ResponsiveLayout(mobile: _buildCards, tablet: _buildTable);
  }

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 0.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DividerTheme(
              data: const DividerThemeData(color: AppColors.gray100),
              child: DataTable(
                headingRowColor: const WidgetStatePropertyAll(AppColors.gray50),
                headingRowHeight: 38,
                headingTextStyle: AppTextStyles.tableHeader,
                dataTextStyle: AppTextStyles.xs.copyWith(
                  color: AppColors.gray700,
                ),
                dataRowMinHeight: 48,
                dataRowMaxHeight: double.infinity,
                horizontalMargin: AppSpacing.s6,
                columnSpacing: AppSpacing.s12,
                dividerThickness: 1,
                showCheckboxColumn: false,
                columns: [
                  for (final column in columns)
                    DataColumn(
                      numeric: column.alignEnd,
                      label: Text(column.label.toUpperCase()),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      cells: [
                        for (final column in columns)
                          DataCell(column.cellBuilder(context, row)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCards(BuildContext context) {
    final custom = mobileCardBuilder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) AppSpacing.h12,
          if (custom != null)
            custom(context, rows[i])
          else
            _MobileRowCard<T>(columns: columns, row: rows[i]),
        ],
      ],
    );
  }
}

class _MobileRowCard<T> extends StatelessWidget {
  const _MobileRowCard({required this.columns, required this.row});

  final List<ResponsiveColumn<T>> columns;
  final T row;

  @override
  Widget build(BuildContext context) {
    final visible = columns.where((column) => column.showOnMobile);
    final fields = visible.where((column) => !column.alignEnd).toList();
    final actions = visible.where((column) => column.alignEnd).toList();

    return AppCard(
      child: DefaultTextStyle.merge(
        style: AppTextStyles.xs.copyWith(color: AppColors.gray700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) AppSpacing.h8,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    fields[i].label.toUpperCase(),
                    style: AppTextStyles.tableHeader,
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: fields[i].cellBuilder(context, row),
                    ),
                  ),
                ],
              ),
            ],
            if (actions.isNotEmpty) ...[
              AppSpacing.h12,
              const Divider(height: 1, color: AppColors.gray100),
              AppSpacing.h8,
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final action in actions)
                    action.cellBuilder(context, row),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
