enum TipoIdentificacion {
  cedula('CEDULA', 'Cédula'),
  ruc('RUC', 'RUC'),
  pasaporte('PASAPORTE', 'Pasaporte'),
  consumidorFinal('CONSUMIDOR_FINAL', 'Consumidor Final');

  const TipoIdentificacion(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static TipoIdentificacion fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException(
      'Valor desconocido para TipoIdentificacion: "$value"',
    );
  }
}
