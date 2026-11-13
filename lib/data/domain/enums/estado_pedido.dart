enum EstadoPedido {
  abierto('ABIERTO', 'Abierto'),
  enPreparacion('EN_PREPARACION', 'En Preparación'),
  servido('SERVIDO', 'Servido'),
  facturado('FACTURADO', 'Facturado'),
  anulado('ANULADO', 'Anulado');

  const EstadoPedido(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static EstadoPedido fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para EstadoPedido: "$value"');
  }
}
