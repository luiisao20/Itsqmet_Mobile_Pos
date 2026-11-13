import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class ClientePedidosScreen extends StatelessWidget {
  const ClientePedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.receipt_long,
      title: 'Panel de Pedidos & Facturas',
      subtitle: 'Arma tu pedido para llevar en tiempo real y consulta tu historial fiscal',
    );
  }
}
