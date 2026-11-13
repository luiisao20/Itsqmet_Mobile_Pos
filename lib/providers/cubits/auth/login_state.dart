import 'package:equatable/equatable.dart';

enum LoginTab { cliente, staff }

class LoginState extends Equatable {
  const LoginState({
    this.tab = LoginTab.cliente,
    this.loading = false,
    this.errorMessage,
  });

  final LoginTab tab;
  final bool loading;
  final String? errorMessage;

  @override
  List<Object?> get props => [tab, loading, errorMessage];
}
