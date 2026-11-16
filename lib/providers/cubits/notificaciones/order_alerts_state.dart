import 'package:equatable/equatable.dart';

class OrderAlertsState extends Equatable {
  const OrderAlertsState({this.unseen = 0, this.listening = false});

  /// New orders received since the kitchen screen was last opened.
  final int unseen;

  /// Whether a staff session is listening for orders.
  final bool listening;

  OrderAlertsState copyWith({int? unseen, bool? listening}) => OrderAlertsState(
    unseen: unseen ?? this.unseen,
    listening: listening ?? this.listening,
  );

  @override
  List<Object?> get props => [unseen, listening];
}
