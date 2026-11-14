import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

enum ClienteTab { nuevo, paquetes, historial, facturas }

class ClientePedidosError extends Equatable {
  const ClientePedidosError(this.id, this.message);

  final int id;
  final String message;

  @override
  List<Object?> get props => [id, message];
}

class ClientePedidosState extends Equatable {
  const ClientePedidosState({
    this.tab = ClienteTab.nuevo,
    this.categorias = const [],
    this.platos = const [],
    this.selectedCategoriaId,
    this.cart = const ShoppingCart(),
    this.observaciones = '',
    this.loadingOrder = false,
    this.successMessage,
    this.misPedidos = const [],
    this.misFacturas = const [],
    this.loadingList = false,
    this.paquetes = const [],
    this.loadingPaquetes = false,
    this.rescatandoPaqueteId,
    this.error,
  });

  final ClienteTab tab;
  final List<CategoriaPlato> categorias;
  final List<Plato> platos;
  final int? selectedCategoriaId;
  final ShoppingCart cart;
  final String observaciones;
  final bool loadingOrder;
  final String? successMessage;
  final List<Pedido> misPedidos;
  final List<Factura> misFacturas;
  final bool loadingList;
  final List<PaqueteSorpresa> paquetes;
  final bool loadingPaquetes;
  final int? rescatandoPaqueteId;
  final ClientePedidosError? error;

  ClientePedidosState copyWith({
    ClienteTab? tab,
    List<CategoriaPlato>? categorias,
    List<Plato>? platos,
    int? Function()? selectedCategoriaId,
    ShoppingCart? cart,
    String? observaciones,
    bool? loadingOrder,
    String? Function()? successMessage,
    List<Pedido>? misPedidos,
    List<Factura>? misFacturas,
    bool? loadingList,
    List<PaqueteSorpresa>? paquetes,
    bool? loadingPaquetes,
    int? Function()? rescatandoPaqueteId,
    ClientePedidosError? error,
  }) {
    return ClientePedidosState(
      tab: tab ?? this.tab,
      categorias: categorias ?? this.categorias,
      platos: platos ?? this.platos,
      selectedCategoriaId: selectedCategoriaId == null
          ? this.selectedCategoriaId
          : selectedCategoriaId(),
      cart: cart ?? this.cart,
      observaciones: observaciones ?? this.observaciones,
      loadingOrder: loadingOrder ?? this.loadingOrder,
      successMessage: successMessage == null
          ? this.successMessage
          : successMessage(),
      misPedidos: misPedidos ?? this.misPedidos,
      misFacturas: misFacturas ?? this.misFacturas,
      loadingList: loadingList ?? this.loadingList,
      paquetes: paquetes ?? this.paquetes,
      loadingPaquetes: loadingPaquetes ?? this.loadingPaquetes,
      rescatandoPaqueteId: rescatandoPaqueteId == null
          ? this.rescatandoPaqueteId
          : rescatandoPaqueteId(),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    tab,
    categorias,
    platos,
    selectedCategoriaId,
    cart,
    observaciones,
    loadingOrder,
    successMessage,
    misPedidos,
    misFacturas,
    loadingList,
    paquetes,
    loadingPaquetes,
    rescatandoPaqueteId,
    error,
  ];
}
