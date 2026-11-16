import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/kitchen_bell.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/order_alerts_state.dart';
import 'package:itsqmet_mobile_pos/services/notifications/order_alert_notifier.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

/// Listens for new orders during a staff session, from any screen.
///
/// It is an extra owner of the shared [RealtimeService]: it calls `connect`
/// once when a staff session starts and `disconnect` once when it ends, so
/// screen cubits opening and closing their own connection never stop it.
class OrderAlertsCubit extends Cubit<OrderAlertsState> {
  OrderAlertsCubit({
    required this._realtime,
    required this._pedidoRepository,
    required this._bell,
    required this._notifier,
    required this._isAppInForeground,
  }) : super(const OrderAlertsState());

  static const Set<Rol> staffRoles = {Rol.admin, Rol.cocina, Rol.mesero};

  /// Roles allowed to list pedidos, used to mark open orders as seen.
  static const Set<Rol> _seedRoles = {Rol.admin, Rol.mesero};

  /// How many open orders are loaded at start to mark them as already seen.
  static const int seedSize = 100;

  static const String systemTitle = 'Nuevo pedido';

  final RealtimeService _realtime;
  final PedidoRepository _pedidoRepository;
  final KitchenBell _bell;
  final OrderAlertNotifier _notifier;
  final bool Function() _isAppInForeground;

  final Set<int> _seen = {};
  final List<StreamSubscription<Pedido>> _subscriptions = [];
  StreamSubscription<AuthState>? _sessionSubscription;
  Future<void> _pendingSession = Future<void>.value();

  /// Uuid of the staff user being served, or null when not listening.
  String? _staffUuid;
  int _generation = 0;
  int _kitchenViews = 0;

  /// Follows [changes], starting from [current].
  void bindSession(AuthState current, Stream<AuthState> changes) {
    unawaited(_sessionSubscription?.cancel());
    _sessionSubscription = changes.listen(onSessionChanged);
    unawaited(onSessionChanged(current));
  }

  /// Starts listening for staff sessions and stops for any other session.
  /// Calls are applied in order.
  Future<void> onSessionChanged(AuthState session) =>
      _pendingSession = _pendingSession.then((_) => _applySession(session));

  /// The kitchen screen is visible: its orders are no longer unseen.
  void kitchenOpened() {
    _kitchenViews++;
    if (!isClosed && state.unseen != 0) emit(state.copyWith(unseen: 0));
  }

  void kitchenClosed() {
    if (_kitchenViews > 0) _kitchenViews--;
  }

  /// Short in-app text, e.g. "Nuevo pedido · Mesa 4".
  static String alertMessage(Pedido pedido) => switch (pedido.tipo) {
    TipoPedido.llevar => 'Nuevo pedido para llevar',
    TipoPedido.salon => 'Nuevo pedido · ${describe(pedido)}',
  };

  /// Where the order goes, e.g. "Mesa 4" or "Para llevar".
  static String describe(Pedido pedido) => switch (pedido.tipo) {
    TipoPedido.llevar => 'Para llevar',
    TipoPedido.salon =>
      pedido.numeroMesa == null ? 'Salón' : 'Mesa ${pedido.numeroMesa}',
  };

  Future<void> _applySession(AuthState session) async {
    if (isClosed) return;
    final staff = _staffOf(session);
    if (staff?.uuid == _staffUuid) return;
    await _stop();
    if (staff != null && !isClosed) _start(staff);
  }

  static AuthUser? _staffOf(AuthState session) {
    final user = session.user;
    if (!session.isAuthenticated || user == null) return null;
    return staffRoles.contains(user.rol) ? user : null;
  }

  void _start(AuthUser staff) {
    _staffUuid = staff.uuid;
    final generation = ++_generation;
    _realtime.connect();
    _subscriptions
      ..add(_realtime.pedidos.listen(_handleIncoming))
      ..add(_realtime.cocina.listen(_handleIncoming));
    emit(state.copyWith(listening: true));
    // The backend only allows ADMIN and MESERO on /pedidos/** (GlobalConfig),
    // so COCINA would always get 403: it skips the seed. Without a seed, an
    // order already open at login alerts once if it is broadcast again while
    // still ABIERTO. For every role, an update arriving before the seed
    // answers can also alert once; there is no buffering on purpose.
    if (_seedRoles.contains(staff.rol)) {
      unawaited(_seedOpenOrders(generation));
    }
  }

  Future<void> _stop() async {
    if (_staffUuid == null) return;
    _staffUuid = null;
    _generation++;
    final subscriptions = [..._subscriptions];
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    _seen.clear();
    await _realtime.disconnect();
    if (!isClosed) emit(const OrderAlertsState());
  }

  /// Marks the orders already open as seen. Best effort: if it fails, an
  /// update of one of those orders while still ABIERTO looks new.
  Future<void> _seedOpenOrders(int generation) async {
    try {
      final page = await _pedidoRepository.searchPedidos(
        estado: EstadoPedido.abierto,
        size: seedSize,
      );
      if (generation != _generation) return;
      _seen.addAll(page.content.map((pedido) => pedido.id));
    } on Object {
      return;
    }
  }

  void _handleIncoming(Pedido pedido) {
    if (isClosed || _staffUuid == null) return;
    if (!_seen.add(pedido.id)) return;
    if (pedido.estado != EstadoPedido.abierto) return;
    _alert(pedido);
  }

  void _alert(Pedido pedido) {
    // An open kitchen screen rings its own bell for the same order.
    final kitchenVisible = _kitchenViews > 0;
    _notifier.showInApp(alertMessage(pedido));
    if (!kitchenVisible) unawaited(_bell.ring());
    if (!_isAppInForeground()) {
      unawaited(
        _notifier.showSystem(
          id: pedido.id,
          title: systemTitle,
          body: describe(pedido),
        ),
      );
    }
    if (!kitchenVisible) emit(state.copyWith(unseen: state.unseen + 1));
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    _sessionSubscription = null;
    await _pendingSession;
    await _stop();
    return super.close();
  }
}
