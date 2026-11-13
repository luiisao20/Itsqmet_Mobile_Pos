enum EstadoFactura {
  emitida('EMITIDA', 'Emitida'),
  anulada('ANULADA', 'Anulada');

  const EstadoFactura(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static EstadoFactura fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para EstadoFactura: "$value"');
  }
}
