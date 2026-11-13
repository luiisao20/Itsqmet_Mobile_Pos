import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_registration_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/auth_repository.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/session_token.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/session_user_codec.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._repository,
    required this._storage,
    required this._userCodec,
    Stream<void>? sessionExpired,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const AuthState.unknown()) {
    _expiredSubscription = sessionExpired?.listen((_) => _onSessionExpired());
  }

  final AuthRepository _repository;
  final SessionStorage _storage;
  final SessionUserCodec _userCodec;
  final DateTime Function() _clock;

  StreamSubscription<void>? _expiredSubscription;
  Future<void>? _restoring;
  bool _expiring = false;
  bool _expiredWhileRestoring = false;

  Future<void> ensureRestored() => _restoring ??= _restore();

  Future<AuthUser> loginStaff({
    required String email,
    required String password,
  }) => _authenticate(
    () => _repository.loginStaff(email: email, password: password),
  );

  Future<AuthUser> loginCliente({
    required String login,
    required String password,
  }) => _authenticate(
    () => _repository.loginCliente(login: login, password: password),
  );

  Future<AuthUser> registerCliente(ClienteRegistrationDraft draft) =>
      _authenticate(() => _repository.registerCliente(draft));

  Future<void> logout() async {
    final request = _notifyBackendLogout();
    await _endSession();
    unawaited(request);
  }

  Future<void> _notifyBackendLogout() async {
    try {
      await _repository.logout();
    } catch (_) {}
  }

  Future<void> _restore() async {
    final token = await _safeRead(_storage.readToken);
    final userJson = await _safeRead(_storage.readUserJson);
    final user = _expiredWhileRestoring ? null : _restoredUser(token, userJson);

    if (user == null && (token != null || userJson != null)) {
      try {
        await _storage.clear();
      } catch (_) {}
    }
    if (isClosed || !state.isUnknown) return;
    emit(
      user == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user),
    );
  }

  AuthUser? _restoredUser(String? token, String? userJson) {
    if (token == null || token.isEmpty || userJson == null) return null;
    if (isTokenExpired(token, _clock())) return null;
    try {
      final user = _userCodec.decode(userJson);
      return user.uuid.isEmpty ? null : user;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> _authenticate(Future<AuthResult> Function() request) async {
    await ensureRestored();
    final result = await request();
    try {
      await _storage.saveToken(result.token);
      await _storage.saveUserJson(_userCodec.encode(result.user));
    } catch (_) {
      await _storage.clear();
      rethrow;
    }
    if (!isClosed) emit(AuthState.authenticated(result.user));
    return result.user;
  }

  Future<void> _onSessionExpired() async {
    if (state.isUnknown) {
      _expiredWhileRestoring = true;
      return;
    }
    if (_expiring || !state.isAuthenticated) return;
    _expiring = true;
    try {
      await _endSession();
    } finally {
      _expiring = false;
    }
  }

  Future<void> _endSession() async {
    try {
      await _storage.clear();
    } catch (_) {
    } finally {
      if (!isClosed) emit(const AuthState.unauthenticated());
    }
  }

  static Future<String?> _safeRead(Future<String?> Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _expiredSubscription?.cancel();
    return super.close();
  }
}
