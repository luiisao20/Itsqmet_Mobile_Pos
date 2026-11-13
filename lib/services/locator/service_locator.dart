import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/services/locator/data_locator.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  registerDataDependencies(getIt);
}
