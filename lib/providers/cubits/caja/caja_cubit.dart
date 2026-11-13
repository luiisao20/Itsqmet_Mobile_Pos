import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/caja/caja_state.dart';

class CajaCubit extends Cubit<CajaState> {
  CajaCubit({
    required this._pedidoRepository,
    required this._facturaRepository,
    Random? random,
  }) : _random = random ?? Random(),
       super(const CajaState());

  static const int pedidosPageSize = 50;
  static const int facturasPageSize = 10;
  static const String defaultClienteId = '9960cfbb-50ec-4caa-bad3-1c0fb0b2a43e';
  static const String emitirErrorFallback = 'Error al emitir factura';
  static const String pagoErrorFallback = 'Error al registrar el pago';

  final PedidoRepository _pedidoRepository;
  final FacturaRepository _facturaRepository;
  final Random _random;
  int _messageSequence = 0;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    await Future.wait([_loadPedidos(), _loadFacturas()]);
  }

  Future<void> _loadPedidos() async {
    try {
      final page = await _pedidoRepository.getPedidos(
        page: 0,
        size: pedidosPageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          pedidos: page.content.where(_isPorCobrar).toList(),
        ),
      );
    } on AppException {
      if (isClosed) return;
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _loadFacturas() async {
    try {
      final page = await _facturaRepository.getFacturas(
        page: 0,
        size: facturasPageSize,
      );
      if (isClosed) return;
      emit(state.copyWith(facturas: page.content));
    } on AppException {
      return;
    }
  }

  void openFacturar(Pedido pedido) {
    final sequence = 100000 + _random.nextInt(900000);
    emit(
      state.copyWith(
        facturar: () => FacturarForm(
          pedido: pedido,
          numeroSecuencial: '001-001-000$sequence',
        ),
      ),
    );
  }

  void changeNumeroSecuencial(String value) {
    final form = state.facturar;
    if (form == null) return;
    emit(
      state.copyWith(facturar: () => form.copyWith(numeroSecuencial: value)),
    );
  }

  void changePropina(String value) {
    final form = state.facturar;
    if (form == null) return;
    emit(state.copyWith(facturar: () => form.copyWith(propina: _parse(value))));
  }

  void cancelFacturar() => emit(state.copyWith(facturar: () => null));

  Future<bool> emitirFactura() async {
    final form = state.facturar;
    if (form == null || form.submitting) return false;
    emit(state.copyWith(facturar: () => form.copyWith(submitting: true)));

    final idCliente = form.pedido.idCliente;
    final draft = FacturaDraft(
      idPedido: form.pedido.id,
      idCliente: idCliente == null || idCliente.isEmpty
          ? defaultClienteId
          : idCliente,
      numeroSecuencial: form.numeroSecuencial.trim(),
      propina: form.propina,
    );

    try {
      final factura = await _facturaRepository.emitirFactura(draft);
      if (isClosed) return false;
      emit(
        state.copyWith(
          facturar: () => null,
          pago: () => PagoForm(factura: factura, monto: factura.total),
        ),
      );
      unawaited(load());
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          facturar: () => form.copyWith(submitting: false),
          message: _error(error, emitirErrorFallback),
        ),
      );
      return false;
    }
  }

  void openPago(Factura factura) {
    emit(
      state.copyWith(
        pago: () => PagoForm(factura: factura, monto: factura.total),
      ),
    );
  }

  void changeMetodoPago(MetodoPago metodoPago) {
    final form = state.pago;
    if (form == null) return;
    emit(state.copyWith(pago: () => form.copyWith(metodoPago: metodoPago)));
  }

  void changeMonto(String value) {
    final form = state.pago;
    if (form == null) return;
    emit(state.copyWith(pago: () => form.copyWith(monto: _parse(value))));
  }

  void changeReferencia(String value) {
    final form = state.pago;
    if (form == null) return;
    emit(state.copyWith(pago: () => form.copyWith(referencia: value)));
  }

  void cancelPago() => emit(state.copyWith(pago: () => null));

  Future<bool> registrarPago() async {
    final form = state.pago;
    if (form == null || form.submitting) return false;
    emit(state.copyWith(pago: () => form.copyWith(submitting: true)));

    final referencia = form.referencia.trim();
    final draft = PagoDraft(
      idFactura: form.factura.id,
      metodoPago: form.metodoPago,
      monto: form.monto,
      referenciaTransaccion: referencia.isEmpty ? null : referencia,
    );

    try {
      await _facturaRepository.registrarPago(draft);
      if (isClosed) return false;
      final total = CurrencyFormat.format(form.factura.total);
      emit(
        state.copyWith(
          pago: () => null,
          message: CajaMessage(
            ++_messageSequence,
            '¡Pago de $total registrado exitosamente!',
          ),
        ),
      );
      unawaited(load());
      return true;
    } on AppException catch (error) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          pago: () => form.copyWith(submitting: false),
          message: _error(error, pagoErrorFallback),
        ),
      );
      return false;
    }
  }

  CajaMessage _error(AppException error, String fallback) {
    final text = error.message.trim().isEmpty ? fallback : error.message;
    return CajaMessage(++_messageSequence, text, isError: true);
  }

  static double _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;

  static bool _isPorCobrar(Pedido pedido) =>
      pedido.estado == EstadoPedido.servido ||
      (pedido.tipo == TipoPedido.llevar &&
          pedido.estado != EstadoPedido.facturado &&
          pedido.estado != EstadoPedido.anulado);
}
