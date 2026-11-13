import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/services/locator/auth_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../providers/cubits/auth/auth_fixtures.dart';

class AuthTestServices {
  AuthTestServices._(this.repository, this.storage, this.expired);

  final MockAuthRepository repository;
  final InMemorySessionStorage storage;
  final SessionExpiredNotifier expired;

  static Future<AuthTestServices> register() async {
    final services = AuthTestServices._(
      MockAuthRepository(),
      InMemorySessionStorage(),
      SessionExpiredNotifier(),
    );
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt
      ..registerSingleton<AuthRepository>(services.repository)
      ..registerSingleton<SessionStorage>(services.storage)
      ..registerSingleton<SessionExpiredNotifier>(services.expired);
    registerRouterDependencies(getIt);
    registerAuthDependencies(getIt);
    return services;
  }

  Future<void> signIn(AuthUser user) async {
    await storage.saveToken(validJwt());
    await storage.saveUserJson(testCodec.encode(user));
  }
}

extension PumpAuthRouterX on WidgetTester {
  Future<GoRouter> pumpAuthRouter(
    String initialLocation, {
    Size size = TestScreens.phone,
  }) async {
    setScreenSize(size);
    final router = createAppRouter(
      locator: GetIt.instance,
      initialLocation: initialLocation,
      screenBuilder: authScreenBuilder,
    );
    addTearDown(router.dispose);
    await pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await pumpAndSettle();
    return router;
  }

  Future<void> enterField(Key key, String text) => enterText(
    find.descendant(of: find.byKey(key), matching: find.byType(EditableText)),
    text,
  );
}

Widget authScreenBuilder(AppRoute route) =>
    route == AppRoutes.login || route == AppRoutes.register
    ? screenFor(route)
    : SizedBox(key: ValueKey('screen:${route.name}'));

String currentPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;
