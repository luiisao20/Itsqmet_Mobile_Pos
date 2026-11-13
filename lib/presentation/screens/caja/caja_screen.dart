import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class CajaScreen extends StatelessWidget {
  const CajaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.point_of_sale,
      title: 'Módulo de Caja & Facturación',
      subtitle: 'Emisión de facturas electrónicas autorizadas y recaudación de pagos (Efectivo, Tarjeta, Transferencia)',
    );
  }
}
