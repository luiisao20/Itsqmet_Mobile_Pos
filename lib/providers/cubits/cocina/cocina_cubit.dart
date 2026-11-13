import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina_state.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/kitchen_bell.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

class CocinaCubit extends Cubit<CocinaState> {
  CocinaCubit({
    required this._pedidoRepository,
    required this._realtime,
    required this._bell,
  }) : super(const CocinaState());

  static const int pageSize = 50;
  static const String updateErrorFallback =
      'Error al actualizar estado del pedido';

  final PedidoRepository _pedidoRepository;
  final RealtimeService _realtime;
  final KitchenBell _bell;
  final List<StreamSubscription<Pedido>> _subscriptions = [];
  int _errorSequence = 0;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    _listenRealtime();
    try {
      final page = await _pedidoRepository.getPedidos(page: 0, size: pageSize);
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          pedidos: page.content.where(_isActive).toList(),
        ),
      );
    } on AppException {
      if (isClosed) return;
      emit(state.copyWith(loading: false));
    }
  }

  void changeFiltro(CocinaFiltro filtro) =>
      emit(state.copyWith(filtro: filtro));

  Future<void> updateEstado(Pedido pedido, EstadoPedido estado) async {
    try {
      final updated = await _pedidoRepository.updateEstado(pedido.id, estado);
      _handleIncoming(updated);
    } on AppException catch (error) {
      if (isClosed) return;
      final message = error.message.trim().isEmpty
          ? updateErrorFallback
          : error.message;
      emit(state.copyWith(error: CocinaError(++_errorSequence, message)));
    }
  }

  void _listenRealtime() {
    if (_subscriptions.isNotEmpty) return;
    _realtime.connect();
    _subscriptions
      ..add(_realtime.cocina.listen(_handleIncoming))
      ..add(_realtime.pedidos.listen(_handleIncoming));
  }

  void _handleIncoming(Pedido pedido) {
    if (isClosed) return;
    final current = [...state.pedidos];
    final index = current.indexWhere((item) => item.id == pedido.id);

    if (index > -1) {
      if (_isActive(pedido)) {
        current[index] = pedido;
      } else {
        current.removeAt(index);
      }
    } else if (_isActive(pedido)) {
      current.insert(0, pedido);
      unawaited(_bell.ring());
    }

    emit(state.copyWith(pedidos: current));
  }

  static bool _isActive(Pedido pedido) =>
      pedido.estado != EstadoPedido.facturado &&
      pedido.estado != EstadoPedido.anulado;

  @override
  Future<void> close() async {
    final connected = _subscriptions.isNotEmpty;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    if (connected) await _realtime.disconnect();
    return super.close();
  }
}
