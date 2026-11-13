enum EstadoDetallePedido {
  pendiente('PENDIENTE', 'Pendiente'),
  impreso('IMPRESO', 'Impreso'),
  listo('LISTO', 'Listo'),
  entregado('ENTREGADO', 'Entregado');

  const EstadoDetallePedido(this._wire, this.label);

  final String _wire;

  final String label;

  String toJson() => _wire;

  static EstadoDetallePedido fromJson(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in values) {
      if (item._wire == normalized) return item;
    }
    throw FormatException(
      'Valor desconocido para EstadoDetallePedido: "$value"',
    );
  }
}
