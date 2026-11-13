enum Rol {
  admin('ADMIN', 'Administrador'),
  mesero('MESERO', 'Mesero'),
  cocina('COCINA', 'Cocina'),
  cliente('CLIENTE', 'Cliente');

  const Rol(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static Rol fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException('Valor desconocido para Rol: "$value"');
  }
}
