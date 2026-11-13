import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard_auth.dart';
import 'package:itsqmet_mobile_pos/config/router/router_refresh_notifier.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/auth_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/auth_mapper.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/session_user_codec.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';

final SessionUserCodec authSessionUserCodec = SessionUserCodec(
  encode: (user) => jsonEncode(AuthMapper.userToJson(user)),
  decode: (json) => AuthMapper.userFromJson(asJsonMap(jsonDecode(json))),
);

void registerAuthDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthCubit>(() {
    final cubit = AuthCubit(
      repository: getIt<AuthRepository>(),
      storage: getIt<SessionStorage>(),
      userCodec: authSessionUserCodec,
      sessionExpired: getIt<SessionExpiredNotifier>().onExpired,
    );
    final refresh = getIt<RouterRefreshNotifier>();
    cubit.stream.listen((_) => refresh.notify());
    return cubit;
  }, dispose: (cubit) => cubit.close());

  overrideRouteGuard(getIt, () => AuthRouteGuard(getIt<AuthCubit>()));
}
