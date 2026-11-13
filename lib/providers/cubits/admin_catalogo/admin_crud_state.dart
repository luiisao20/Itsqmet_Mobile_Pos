import 'package:equatable/equatable.dart';

class AdminError extends Equatable {
  const AdminError(this.id, this.message);

  final int id;
  final String message;

  @override
  List<Object?> get props => [id, message];
}

class AdminCrudState<T> extends Equatable {
  const AdminCrudState({
    this.loading = false,
    this.items = const [],
    this.submitting = false,
    this.error,
  });

  final bool loading;
  final List<T> items;
  final bool submitting;
  final AdminError? error;

  AdminCrudState<T> copyWith({
    bool? loading,
    List<T>? items,
    bool? submitting,
    AdminError? error,
  }) {
    return AdminCrudState<T>(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      submitting: submitting ?? this.submitting,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loading, items, submitting, error];
}
