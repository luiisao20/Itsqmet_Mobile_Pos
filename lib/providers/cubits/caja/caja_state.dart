import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja_totals.dart';

class CajaMessage extends Equatable {
  const CajaMessage(this.id, this.text, {this.isError = false});

  final int id;
  final String text;
  final bool isError;

  @override
  List<Object?> get props => [id, text, isError];
}

class FacturarForm extends Equatable {
  const FacturarForm({
    required this.pedido,
    required this.numeroSecuencial,
    this.propina = 0,
    this.submitting = false,
  });

  final Pedido pedido;
  final String numeroSecuencial;
  final double propina;
  final bool submitting;

  CajaTotals get totals => CajaTotals.of(pedido, propina);

  FacturarForm copyWith({
    String? numeroSecuencial,
    double? propina,
    bool? submitting,
  }) {
    return FacturarForm(
      pedido: pedido,
      numeroSecuencial: numeroSecuencial ?? this.numeroSecuencial,
      propina: propina ?? this.propina,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [pedido, numeroSecuencial, propina, submitting];
}

class PagoForm extends Equatable {
  const PagoForm({
    required this.factura,
    required this.monto,
    this.metodoPago = MetodoPago.efectivo,
    this.referencia = '',
    this.submitting = false,
  });

  final Factura factura;
  final MetodoPago metodoPago;
  final double monto;
  final String referencia;
  final bool submitting;

  PagoForm copyWith({
    MetodoPago? metodoPago,
    double? monto,
    String? referencia,
    bool? submitting,
  }) {
    return PagoForm(
      factura: factura,
      metodoPago: metodoPago ?? this.metodoPago,
      monto: monto ?? this.monto,
      referencia: referencia ?? this.referencia,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [
    factura,
    metodoPago,
    monto,
    referencia,
    submitting,
  ];
}

class CajaState extends Equatable {
  const CajaState({
    this.loading = false,
    this.pedidos = const [],
    this.facturas = const [],
    this.facturar,
    this.pago,
    this.message,
  });

  final bool loading;
  final List<Pedido> pedidos;
  final List<Factura> facturas;
  final FacturarForm? facturar;
  final PagoForm? pago;
  final CajaMessage? message;

  CajaState copyWith({
    bool? loading,
    List<Pedido>? pedidos,
    List<Factura>? facturas,
    FacturarForm? Function()? facturar,
    PagoForm? Function()? pago,
    CajaMessage? message,
  }) {
    return CajaState(
      loading: loading ?? this.loading,
      pedidos: pedidos ?? this.pedidos,
      facturas: facturas ?? this.facturas,
      facturar: facturar == null ? this.facturar : facturar(),
      pago: pago == null ? this.pago : pago(),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    pedidos,
    facturas,
    facturar,
    pago,
    message,
  ];
}
