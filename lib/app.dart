import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/layout.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scaffoldMessengerKey: NotificationsService.messengerKey,
      home: const AppShell(child: _FoundationPreview()),
    );
  }
}

class _FoundationPreview extends StatelessWidget {
  const _FoundationPreview();

  @override
  Widget build(BuildContext context) {
    return const PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            icon: Icons.restaurant,
            title: 'Restaurante POS',
            subtitle: 'Base de la aplicación lista',
          ),
          EmptyState(
            title: 'Sin contenido todavía',
            message: 'Las pantallas se agregarán en las siguientes etapas.',
          ),
        ],
      ),
    );
  }
}
