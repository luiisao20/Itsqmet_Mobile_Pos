enum AreaImpresion {
  cocina('COCINA', 'Cocina'),
  bar('BAR', 'Bar'),
  caja('CAJA', 'Caja');

  const AreaImpresion(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static AreaImpresion fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para AreaImpresion: "$value"');
  }
}
