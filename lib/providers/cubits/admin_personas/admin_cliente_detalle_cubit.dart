import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

enum AdminClienteDetalleTab { pedidos, facturas }

class AdminClienteDetalleState extends Equatable {
  const AdminClienteDetalleState({
    required this.cliente,
    this.loading = false,
    this.pedidos = const [],
    this.facturas = const [],
    this.tab = AdminClienteDetalleTab.pedidos,
    this.errorMessage,
  });

  final Cliente cliente;
  final bool loading;
  final List<Pedido> pedidos;
  final List<Factura> facturas;
  final AdminClienteDetalleTab tab;
  final String? errorMessage;

  double get totalFacturado => facturas
      .where((f) => f.estado == EstadoFactura.emitida)
      .fold(0.0, (acc, f) => acc + f.total);

  int get pedidosCount => pedidos.length;
  int get facturasCount => facturas.length;

  AdminClienteDetalleState copyWith({
    Cliente? cliente,
    bool? loading,
    List<Pedido>? pedidos,
    List<Factura>? facturas,
    AdminClienteDetalleTab? tab,
    String? errorMessage,
  }) {
    return AdminClienteDetalleState(
      cliente: cliente ?? this.cliente,
      loading: loading ?? this.loading,
      pedidos: pedidos ?? this.pedidos,
      facturas: facturas ?? this.facturas,
      tab: tab ?? this.tab,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    cliente,
    loading,
    pedidos,
    facturas,
    tab,
    errorMessage,
  ];
}

class AdminClienteDetalleCubit extends Cubit<AdminClienteDetalleState> {
  AdminClienteDetalleCubit({
    required Cliente cliente,
    required PedidoRepository pedidoRepository,
    required FacturaRepository facturaRepository,
  })  : _pedidos = pedidoRepository,
        _facturas = facturaRepository,
        super(AdminClienteDetalleState(cliente: cliente));

  final PedidoRepository _pedidos;
  final FacturaRepository _facturas;

  Future<void> load() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        _pedidos.searchPedidos(clienteUuid: state.cliente.uuid, size: 50),
        _facturas.searchFacturas(
          clienteFiltro: state.cliente.identificacion,
          size: 50,
        ),
      ]);
      if (isClosed) return;

      final pedidosPage = results[0] as PageResult<Pedido>;
      final facturasPage = results[1] as PageResult<Factura>;

      emit(
        state.copyWith(
          loading: false,
          pedidos: pedidosPage.content,
          facturas: facturasPage.content,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(loading: false, errorMessage: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Error al cargar el historial del cliente',
        ),
      );
    }
  }

  void setTab(AdminClienteDetalleTab tab) {
    emit(state.copyWith(tab: tab));
  }
}
