import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itsqmet_mobile_pos/app.dart';
import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';
import 'package:itsqmet_mobile_pos/firebase_options.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/push_notification_service.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    debugPrint('[Firebase] Error al inicializar Firebase: $error');
  }

  try {
    await dotenv.load(isOptional: true);
    debugPrint('[Environment] API Base URL: ${AppEnvironment.apiBaseUrl}');
  } catch (error) {
    debugPrint('dotenv could not be loaded, using defaults: $error');
  }

  await setupLocator();

  try {
    await getIt<PushNotificationService>().initialize();
  } catch (error) {
    debugPrint('[FCM] Error inicializando servicio de push notifications: $error');
  }

  runApp(const App());
}
