import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.lock_outline,
      title: 'Iniciar Sesión',
      subtitle: 'Ingresa con tu cuenta de cliente o credenciales de personal',
    );
  }
}
