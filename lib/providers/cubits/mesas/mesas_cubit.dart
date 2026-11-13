import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_state.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

export 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_state.dart';

class MesasCubit extends Cubit<MesasState> {
  MesasCubit({
    required this._mesaRepository,
    required this._catalogoRepository,
    required this._pedidoRepository,
    required this._realtimeService,
  }) : super(const MesasState());

  static const String submitErrorMessage =
      'Error al enviar la comanda de la mesa';
  static const String estadoErrorMessage = 'Error al cambiar estado de mesa';

  final MesaRepository _mesaRepository;
  final CatalogoRepository _catalogoRepository;
  final PedidoRepository _pedidoRepository;
  final RealtimeService _realtimeService;

  StreamSubscription<Pedido>? _realtimeSubscription;
  int _mesasRequest = 0;
  int _comandaSession = 0;
  bool _disposed = false;

  Future<void> start() async {
    _listenRealtime();
    await Future.wait([loadMesas(), loadCatalog()]);
  }

  Future<void> loadMesas() async {
    if (_disposed) return;
    emit(state.copyWith(loadingMesas: true));
    await _fetchMesas();
  }

  Future<void> refreshMesas() => _fetchMesas();

  Future<void> loadCatalog() async {
    try {
      final page = await _catalogoRepository.getPlatos();
      if (!_disposed) emit(state.copyWith(platos: page.content));
    } on AppException {
      if (!_disposed) emit(state.copyWith(platos: const []));
    }
  }

  void openComanda(Mesa mesa) {
    _comandaSession++;
    emit(
      state.copyWith(
        selectedMesa: mesa,
        comanda: const ShoppingCart(),
        observaciones: '',
        loadingOrder: false,
        clearComandaError: true,
      ),
    );
  }

  void closeComanda() {
    _comandaSession++;
    emit(
      state.copyWith(
        clearSelectedMesa: true,
        loadingOrder: false,
        clearComandaError: true,
      ),
    );
  }

  void addPlato(Plato plato) =>
      emit(state.copyWith(comanda: state.comanda.add(plato)));

  void changeQuantity(int index, int delta) =>
      emit(state.copyWith(comanda: state.comanda.changeQuantity(index, delta)));

  void removeItem(int index) =>
      emit(state.copyWith(comanda: state.comanda.remove(index)));

  void updateNotes(int index, String notes) =>
      emit(state.copyWith(comanda: state.comanda.updateNotes(index, notes)));

  void updateObservaciones(String value) =>
      emit(state.copyWith(observaciones: value));

  Future<bool> submitComanda() async {
    final mesa = state.selectedMesa;
    if (mesa == null || state.comanda.isEmpty) return false;

    final session = _comandaSession;
    emit(state.copyWith(loadingOrder: true, clearComandaError: true));
    final observaciones = state.observaciones.trim();
    final draft = PedidoDraft(
      idMesa: mesa.id,
      tipo: TipoPedido.salon,
      observaciones: observaciones.isEmpty ? null : observaciones,
      detalles: state.comanda.toDetalles(),
    );

    try {
      await _pedidoRepository.createPedido(draft);
    } on AppException {
      if (!_disposed && session == _comandaSession) {
        emit(
          state.copyWith(loadingOrder: false, comandaError: submitErrorMessage),
        );
      }
      return false;
    }

    if (_disposed) return false;
    final current = session == _comandaSession;
    if (current) {
      _comandaSession++;
      emit(state.copyWith(loadingOrder: false, clearSelectedMesa: true));
    }
    unawaited(loadMesas());
    return current;
  }

  Future<void> cambiarEstadoMesa(Mesa mesa, EstadoMesa nuevoEstado) async {
    try {
      await _mesaRepository.updateEstado(mesa.id, nuevoEstado);
    } on AppException {
      if (!_disposed) emit(state.copyWith(errorMessage: estadoErrorMessage));
      return;
    }
    await loadMesas();
  }

  void clearError() => emit(state.copyWith(clearError: true));

  Future<void> _fetchMesas() async {
    final request = ++_mesasRequest;
    try {
      final page = await _mesaRepository.getMesas();
      if (_isStale(request)) return;
      emit(state.copyWith(mesas: page.content, loadingMesas: false));
    } on AppException {
      if (_isStale(request)) return;
      emit(state.copyWith(loadingMesas: false));
    }
  }

  bool _isStale(int request) => _disposed || request != _mesasRequest;

  void _listenRealtime() {
    if (_disposed) return;
    _realtimeService.connect();
    _realtimeSubscription = _realtimeService.pedidos.listen(
      (_) => refreshMesas(),
      onDone: _onRealtimeDone,
    );
  }

  void _onRealtimeDone() {
    _realtimeSubscription = null;
    _listenRealtime();
  }

  @override
  Future<void> close() async {
    _disposed = true;
    final subscription = _realtimeSubscription;
    _realtimeSubscription = null;
    unawaited(subscription?.cancel());
    await _realtimeService.disconnect();
    return super.close();
  }
}
