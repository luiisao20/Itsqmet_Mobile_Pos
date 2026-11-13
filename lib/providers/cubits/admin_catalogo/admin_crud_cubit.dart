import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_state.dart';

abstract class AdminCrudCubit<T> extends Cubit<AdminCrudState<T>> {
  AdminCrudCubit(this._changes) : super(AdminCrudState<T>());

  final AdminChanges _changes;
  int _errorSequence = 0;

  Future<List<T>> fetch();

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final items = await fetch();
      if (isClosed) return;
      emit(state.copyWith(loading: false, items: items));
    } on AppException {
      if (isClosed) return;
      emit(state.copyWith(loading: false));
    }
  }

  Future<bool> save(
    Future<void> Function() action, {
    required String fallback,
  }) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true));
    try {
      await action();
      if (isClosed) return false;
      emit(state.copyWith(submitting: false));
      _changes.notify();
      unawaited(load());
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(submitting: false, error: _error(error, fallback)));
      return false;
    }
  }

  Future<bool> run(
    Future<void> Function() action, {
    required String fallback,
  }) async {
    try {
      await action();
      if (isClosed) return false;
      _changes.notify();
      await load();
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(error: _error(error, fallback)));
      return false;
    }
  }

  void reject(String message) =>
      emit(state.copyWith(error: AdminError(++_errorSequence, message)));

  AdminError _error(AppException error, String fallback) {
    final message = error.message.trim().isEmpty ? fallback : error.message;
    return AdminError(++_errorSequence, message);
  }
}
