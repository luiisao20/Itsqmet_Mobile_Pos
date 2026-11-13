enum TipoPedido {
  salon('SALON', 'Salón'),
  llevar('LLEVAR', 'Para Llevar');

  const TipoPedido(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static TipoPedido fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para TipoPedido: "$value"');
  }
}
