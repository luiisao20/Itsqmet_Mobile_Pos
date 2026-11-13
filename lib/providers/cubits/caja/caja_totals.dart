import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

class CajaTotals extends Equatable {
  const CajaTotals({
    required this.subtotal,
    required this.iva,
    required this.propina,
    required this.total,
  });

  factory CajaTotals.of(Pedido pedido, double propina) {
    final subtotal = pedido.detalles.fold<double>(
      0,
      (sum, detalle) => sum + detalle.subtotal,
    );
    final iva = _round2(subtotal * CartTotals.ivaRate);
    return CajaTotals(
      subtotal: subtotal,
      iva: iva,
      propina: propina,
      total: _round2(subtotal + iva + propina),
    );
  }

  final double subtotal;
  final double iva;
  final double propina;
  final double total;

  static double _round2(double value) => double.parse(value.toStringAsFixed(2));

  @override
  List<Object?> get props => [subtotal, iva, propina, total];
}
