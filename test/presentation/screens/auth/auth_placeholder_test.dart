import 'package:itsqmet_mobile_pos/presentation/screens/auth/login_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/register_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/feature_placeholder_expectations.dart';

void main() {
  testFeaturePlaceholder(
    'LoginScreen',
    () => const LoginScreen(),
    title: 'Iniciar Sesión',
    subtitle: 'Ingresa con tu cuenta de cliente o credenciales de personal',
    icon: Icons.lock_outline,
  );
  testFeaturePlaceholder(
    'RegisterScreen',
    () => const RegisterScreen(),
    title: 'Registro de Cliente',
    subtitle: 'Crea tu cuenta para realizar pedidos para llevar y gestionar tus facturas',
    icon: Icons.edit_note,
  );
}
