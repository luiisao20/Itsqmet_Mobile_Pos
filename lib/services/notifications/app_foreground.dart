import 'package:flutter/widgets.dart';

/// Whether the user can still see the app. Only paused, hidden and detached
/// count as background; inactive (e.g. the notification shade is pulled
/// down) and an unknown state count as visible.
bool isAppVisible(AppLifecycleState? state) => switch (state) {
  AppLifecycleState.paused ||
  AppLifecycleState.hidden ||
  AppLifecycleState.detached => false,
  _ => true,
};

/// [isAppVisible] for the current lifecycle state of the app.
bool isAppInForeground() =>
    isAppVisible(WidgetsBinding.instance.lifecycleState);
