import 'dart:async';

import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/categorias_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/clientes_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/distribuidores_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/insumos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/mesas_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/personal_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/platos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_metrics.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

enum AdminTab {
  platos('Platos', Icons.restaurant_menu, '+ Nuevo Plato'),
  categorias('Categorías', Icons.folder_open, '+ Nueva Categoría'),
  mesas('Mesas', Icons.table_restaurant, '+ Nueva Mesa'),
  personal('Personal', Icons.groups, '+ Nuevo Empleado'),
  insumos('Insumos / Inventario', Icons.inventory_2, '+ Nuevo Insumo'),
  distribuidores(
    'Distribuidores',
    Icons.local_shipping,
    '+ Nuevo Distribuidor',
  ),
  clientes('Clientes', Icons.person, '+ Nuevo Cliente');

  const AdminTab(this.label, this.icon, this.createLabel);

  final String label;
  final IconData icon;
  final String createLabel;
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final StreamController<AdminTab> _createController =
      StreamController<AdminTab>.broadcast();

  late final Map<AdminTab, Stream<void>> _createRequests = {
    for (final tab in AdminTab.values)
      tab: _createController.stream.where((t) => t == tab).map((_) {}),
  };

  AdminTab _active = AdminTab.platos;

  @override
  void dispose() {
    _createController.close();
    super.dispose();
  }

  Widget _buildTab(AdminTab tab) {
    final requests = _createRequests[tab]!;
    return switch (tab) {
      AdminTab.platos => PlatosTab(createRequests: requests),
      AdminTab.categorias => CategoriasTab(createRequests: requests),
      AdminTab.mesas => MesasTab(createRequests: requests),
      AdminTab.personal => PersonalTab(createRequests: requests),
      AdminTab.insumos => InsumosTab(createRequests: requests),
      AdminTab.distribuidores => DistribuidoresTab(createRequests: requests),
      AdminTab.clientes => ClientesTab(createRequests: requests),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Panel de Administración',
            subtitle: 'Gestión integral de catálogo, personal, inventario, mesas y proveedores',
            actions: [
              AppButton(
                label: _active.createLabel,
                onPressed: () => _createController.add(_active),
              ),
            ],
          ),
          const AdminMetrics(),
          AppSpacing.h32,
          _AdminTabBar(
            active: _active,
            onSelected: (tab) => setState(() => _active = tab),
          ),
          KeyedSubtree(
            key: ValueKey('admin-tab-body-${_active.name}'),
            child: _buildTab(_active),
          ),
        ],
      ),
    );
  }
}

class _AdminTabBar extends StatelessWidget {
  const _AdminTabBar({required this.active, required this.onSelected});

  final AdminTab active;
  final ValueChanged<AdminTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in AdminTab.values) ...[
              if (tab != AdminTab.values.first) AppSpacing.w8,
              _AdminTabPill(
                key: ValueKey(tab),
                tab: tab,
                selected: tab == active,
                onTap: () => onSelected(tab),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminTabPill extends StatelessWidget {
  const _AdminTabPill({
    super.key,
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AdminTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.gray600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald600 : AppColors.gray100,
          borderRadius: AppRadius.mdAll,
          boxShadow: selected ? AppShadows.xs : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 14, color: foreground),
            const SizedBox(width: 6),
            Text(
              tab.label,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
