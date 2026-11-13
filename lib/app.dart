import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/app_router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class App extends StatefulWidget {
  const App({super.key, this.router});

  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurante POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scaffoldMessengerKey: NotificationsService.messengerKey,
      routerConfig: _router,
    );
  }
}
