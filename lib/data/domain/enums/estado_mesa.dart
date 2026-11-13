enum EstadoMesa {
  libre('LIBRE', 'Libre'),
  ocupada('OCUPADA', 'Ocupada'),
  cuenta('CUENTA', 'Cuenta');

  const EstadoMesa(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static EstadoMesa fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para EstadoMesa: "$value"');
  }
}
