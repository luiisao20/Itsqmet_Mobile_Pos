import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos_state.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';

class ClientePedidosCubit extends Cubit<ClientePedidosState> {
  ClientePedidosCubit({
    required this._catalogoRepository,
    required this._pedidoRepository,
    required this._facturaRepository,
    required this._paqueteRepository,
    required this._realtime,
    this._successDelay = defaultSuccessDelay,
  }) : super(const ClientePedidosState());

  static const Duration defaultSuccessDelay = Duration(milliseconds: 1800);
  static const int platosPageSize = 50;
  static const int listPageSize = 20;
  static const String orderErrorFallback =
      'Error al procesar el pedido para llevar.';

  final CatalogoRepository _catalogoRepository;
  final PedidoRepository _pedidoRepository;
  final FacturaRepository _facturaRepository;
  final PaqueteSorpresaRepository _paqueteRepository;
  final RealtimeService _realtime;
  final Duration _successDelay;

  StreamSubscription<Pedido>? _subscription;
  StreamSubscription<PaqueteSorpresa>? _paquetesSubscription;
  Timer? _successTimer;
  Timer? _countdownTimer;
  int _errorSequence = 0;

  Future<void> load() async {
    _listenRealtime();
    await Future.wait([
      _loadCategorias(),
      _loadPlatos(),
      loadMisPedidos(),
      loadMisFacturas(),
      loadPaquetes(),
    ]);
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await _catalogoRepository.getCategorias();
      if (isClosed) return;
      emit(state.copyWith(categorias: categorias));
    } on AppException {
      return;
    }
  }

  Future<void> _loadPlatos() async {
    final idCategoria = state.selectedCategoriaId;
    try {
      final page = idCategoria == null
          ? await _catalogoRepository.getPlatos(page: 0, size: platosPageSize)
          : await _catalogoRepository.getPlatosByCategoria(
              idCategoria,
              page: 0,
              size: platosPageSize,
            );
      if (isClosed || state.selectedCategoriaId != idCategoria) return;
      emit(state.copyWith(platos: page.content));
    } on AppException {
      return;
    }
  }

  Future<void> loadMisPedidos() async {
    emit(state.copyWith(loadingList: true));
    try {
      final page = await _pedidoRepository.getMisPedidos(
        page: 0,
        size: listPageSize,
      );
      if (isClosed) return;
      emit(state.copyWith(loadingList: false, misPedidos: page.content));
    } on AppException {
      if (isClosed) return;
      emit(state.copyWith(loadingList: false));
    }
  }

  Future<void> loadMisFacturas() async {
    try {
      final page = await _facturaRepository.getMisFacturas(
        page: 0,
        size: listPageSize,
      );
      if (isClosed) return;
      emit(state.copyWith(misFacturas: page.content));
    } on AppException {
      return;
    }
  }

  Future<void> loadPaquetes() async {
    emit(state.copyWith(loadingPaquetes: true));
    try {
      final paquetes = await _paqueteRepository.getDisponibles();
      if (isClosed) return;
      emit(state.copyWith(loadingPaquetes: false, paquetes: paquetes));
      _startCountdownTimer();
    } on AppException {
      if (isClosed) return;
      emit(state.copyWith(loadingPaquetes: false));
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    final hasCountdowns = state.paquetes.any((p) => p.segundosParaApertura > 0);
    if (!hasCountdowns) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) {
        _countdownTimer?.cancel();
        return;
      }
      bool anyRemaining = false;
      final updated = state.paquetes.map((p) {
        if (p.segundosParaApertura > 0) {
          final next = p.segundosParaApertura - 1;
          if (next > 0) anyRemaining = true;
          return p.copyWith(
            segundosParaApertura: next,
            disponibleAhora: next == 0 ? true : p.disponibleAhora,
          );
        }
        return p;
      }).toList();

      emit(state.copyWith(paquetes: updated));
      if (!anyRemaining) {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> filterCategoria(int? idCategoria) {
    emit(state.copyWith(selectedCategoriaId: () => idCategoria));
    return _loadPlatos();
  }

  Future<void> changeTab(ClienteTab tab) async {
    emit(state.copyWith(tab: tab));
    switch (tab) {
      case ClienteTab.paquetes:
        await loadPaquetes();
      case ClienteTab.historial:
        await loadMisPedidos();
      case ClienteTab.facturas:
        await loadMisFacturas();
      case ClienteTab.nuevo:
        return;
    }
  }

  void addPlato(Plato plato) =>
      emit(state.copyWith(cart: state.cart.add(plato)));

  void changeQuantity(int index, int delta) =>
      emit(state.copyWith(cart: state.cart.changeQuantity(index, delta)));

  void removeItem(int index) =>
      emit(state.copyWith(cart: state.cart.remove(index)));

  void updateNotes(int index, String notes) =>
      emit(state.copyWith(cart: state.cart.updateNotes(index, notes)));

  void updateObservaciones(String value) =>
      emit(state.copyWith(observaciones: value));

  Future<bool> submitOrder() async {
    if (state.cart.isEmpty || state.loadingOrder) return false;
    emit(state.copyWith(loadingOrder: true, successMessage: () => null));

    final observaciones = state.observaciones.trim();
    final draft = PedidoClienteDraft(
      observaciones: observaciones.isEmpty ? null : observaciones,
      detalles: state.cart.toDetalles(),
    );

    try {
      final created = await _pedidoRepository.createPedidoCliente(draft);
      if (isClosed) return false;
      emit(
        state.copyWith(
          loadingOrder: false,
          cart: state.cart.clear(),
          observaciones: '',
          successMessage: () =>
              '¡Pedido #${created.id} enviado exitosamente a la cocina!',
        ),
      );
      unawaited(loadMisPedidos());
      _successTimer?.cancel();
      _successTimer = Timer(_successDelay, _showHistorial);
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      final message = error.message.trim().isEmpty
          ? orderErrorFallback
          : error.message;
      emit(
        state.copyWith(
          loadingOrder: false,
          error: ClientePedidosError(++_errorSequence, message),
        ),
      );
      return false;
    }
  }

  Future<bool> rescatarPaquete(
    int id, {
    int cantidad = 1,
    String? observaciones,
  }) async {
    if (state.rescatandoPaqueteId != null) return false;
    emit(state.copyWith(
      rescatandoPaqueteId: () => id,
      successMessage: () => null,
    ));

    try {
      final result = await _paqueteRepository.rescatar(
        id,
        cantidad: cantidad,
        observaciones: observaciones,
      );
      if (isClosed) return false;
      emit(
        state.copyWith(
          rescatandoPaqueteId: () => null,
          successMessage: () => result.mensaje,
        ),
      );
      unawaited(loadMisPedidos());
      unawaited(loadPaquetes());
      _successTimer?.cancel();
      _successTimer = Timer(_successDelay, _showHistorial);
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      final message = error.message.trim().isEmpty
          ? 'Error al rescatar el paquete sorpresa.'
          : error.message;
      emit(
        state.copyWith(
          rescatandoPaqueteId: () => null,
          error: ClientePedidosError(++_errorSequence, message),
        ),
      );
      return false;
    }
  }

  void _showHistorial() {
    if (isClosed) return;
    emit(state.copyWith(tab: ClienteTab.historial, successMessage: () => null));
  }

  void _listenRealtime() {
    if (_subscription != null) return;
    _realtime.connect();
    _subscription = _realtime.pedidos.listen(_handleIncoming);
    _paquetesSubscription =
        _realtime.paquetesSorpresa.listen(_handleIncomingPaquete);
  }

  void _handleIncoming(Pedido pedido) {
    if (isClosed) return;
    if (!state.misPedidos.any((item) => item.id == pedido.id)) return;
    emit(
      state.copyWith(
        misPedidos: [
          for (final item in state.misPedidos)
            item.id == pedido.id ? pedido : item,
        ],
      ),
    );
  }

  void _handleIncomingPaquete(PaqueteSorpresa paquete) {
    if (isClosed) return;
    final exists = state.paquetes.any((item) => item.id == paquete.id);
    final updatedList = exists
        ? [for (final p in state.paquetes) p.id == paquete.id ? paquete : p]
        : [...state.paquetes, paquete];
    emit(state.copyWith(paquetes: updatedList));
    _startCountdownTimer();
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    _successTimer?.cancel();
    final subscription = _subscription;
    _subscription = null;
    final paquetesSub = _paquetesSubscription;
    _paquetesSubscription = null;
    await paquetesSub?.cancel();
    if (subscription != null) {
      await subscription.cancel();
      await _realtime.disconnect();
    }
    return super.close();
  }
}
