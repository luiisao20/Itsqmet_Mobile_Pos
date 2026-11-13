enum UnidadMedida {
  kg('KG', 'KG (Kilogramos)'),
  lt('LT', 'LT (Litros)'),
  unidad('UNIDAD', 'UNIDAD (Piezas)');

  const UnidadMedida(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static UnidadMedida fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para UnidadMedida: "$value"');
  }
}
