import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.edit_note,
      title: 'Registro de Cliente',
      subtitle: 'Crea tu cuenta para realizar pedidos para llevar y gestionar tus facturas',
    );
  }
}
