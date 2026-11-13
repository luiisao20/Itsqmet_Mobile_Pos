enum MetodoPago {
  efectivo('EFECTIVO', 'Efectivo'),
  transferencia('TRANSFERENCIA', 'Transferencia'),
  tarjeta('TARJETA', 'Tarjeta');

  const MetodoPago(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static MetodoPago fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para MetodoPago: "$value"');
  }
}
