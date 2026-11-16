import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:itsqmet_mobile_pos/services/push_notification_service.dart';

/// Shows staff alerts about new orders.
abstract interface class OrderAlertNotifier {
  /// Shows [message] on top of the current screen.
  void showInApp(String message);

  /// Shows a system notification, visible while the app is in background.
  Future<void> showSystem({
    required int id,
    required String title,
    required String body,
  });
}

/// Uses the global [NotificationsService] messenger for in-app alerts and the
/// local notifications plugin already set up by [PushNotificationService].
class DefaultOrderAlertNotifier implements OrderAlertNotifier {
  DefaultOrderAlertNotifier(this._push);

  final PushNotificationService _push;

  @override
  void showInApp(String message) => NotificationsService.showInfo(message);

  @override
  Future<void> showSystem({
    required int id,
    required String title,
    required String body,
  }) => _push.showOrderNotification(id: id, title: title, body: body);
}
