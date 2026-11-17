import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:material_ui/material_ui.dart';

/// Tells [OrderAlertsCubit] while the kitchen screen is open, so its counter
/// of unseen orders is cleared when the screen opens.
class KitchenAlertsScope extends StatefulWidget {
  const KitchenAlertsScope({
    super.key,
    required this.alerts,
    required this.child,
  });

  final OrderAlertsCubit alerts;
  final Widget child;

  @override
  State<KitchenAlertsScope> createState() => _KitchenAlertsScopeState();
}

class _KitchenAlertsScopeState extends State<KitchenAlertsScope> {
  @override
  void initState() {
    super.initState();
    widget.alerts.kitchenOpened();
  }

  @override
  void dispose() {
    widget.alerts.kitchenClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
