import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itsqmet_mobile_pos/app.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(isOptional: true);
  } catch (error) {
    debugPrint('dotenv could not be loaded, using defaults: $error');
  }

  await setupLocator();

  runApp(const App());
}
