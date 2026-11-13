import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';

class BadgeSpec extends Equatable {
  const BadgeSpec({required this.variant, required this.label});

  final BadgeVariant variant;
  final String label;

  @override
  List<Object?> get props => [variant, label];
}

abstract final class StatusBadges {
  static BadgeSpec mesa(String? estado) => _lookup(estado, _mesa);

  static BadgeSpec pedido(String? estado) => _lookup(estado, _pedido);

  static BadgeSpec factura(String? estado) => _lookup(estado, _factura);

  static BadgeSpec disponible(bool value) => value
      ? const BadgeSpec(variant: BadgeVariant.success, label: 'Disponible')
      : const BadgeSpec(variant: BadgeVariant.danger, label: 'Agotado');

  static BadgeSpec activo(bool value) => value
      ? const BadgeSpec(variant: BadgeVariant.success, label: 'Activo')
      : const BadgeSpec(variant: BadgeVariant.neutral, label: 'Inactivo');

  static const Map<String, BadgeSpec> _mesa = {
    'LIBRE': BadgeSpec(variant: BadgeVariant.success, label: 'Libre'),
    'OCUPADA': BadgeSpec(variant: BadgeVariant.warning, label: 'Ocupada'),
    'CUENTA': BadgeSpec(variant: BadgeVariant.info, label: 'Cuenta'),
  };

  static const Map<String, BadgeSpec> _pedido = {
    'ABIERTO': BadgeSpec(variant: BadgeVariant.info, label: 'Abierto'),
    'EN_PREPARACION': BadgeSpec(
      variant: BadgeVariant.warning,
      label: 'En Preparación',
    ),
    'SERVIDO': BadgeSpec(variant: BadgeVariant.success, label: 'Servido'),
    'FACTURADO': BadgeSpec(variant: BadgeVariant.success, label: 'Facturado'),
    'ANULADO': BadgeSpec(variant: BadgeVariant.danger, label: 'Anulado'),
  };

  static const Map<String, BadgeSpec> _factura = {
    'EMITIDA': BadgeSpec(variant: BadgeVariant.success, label: 'Emitida'),
    'ANULADA': BadgeSpec(variant: BadgeVariant.danger, label: 'Anulada'),
  };

  static BadgeSpec _lookup(String? raw, Map<String, BadgeSpec> table) {
    if (raw == null) {
      return const BadgeSpec(variant: BadgeVariant.neutral, label: '-');
    }
    final key = raw.trim().toUpperCase();
    return table[key] ?? BadgeSpec(variant: BadgeVariant.neutral, label: raw);
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.spec, {super.key});

  final BadgeSpec spec;

  @override
  Widget build(BuildContext context) =>
      AppBadge(label: spec.label, variant: spec.variant);
}
