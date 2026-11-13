import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/cliente_pedidos_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'ClientePedidosScreen',
    () => const ClientePedidosScreen(),
    title: 'Panel de Pedidos & Facturas',
    subtitle: 'Arma tu pedido para llevar en tiempo real y consulta tu historial fiscal',
    icon: Icons.receipt_long,
  );
}
