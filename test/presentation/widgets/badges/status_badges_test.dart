import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/app_colors.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/role_chip.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';

void main() {
  BadgeSpec spec(BadgeVariant variant, String label) =>
      BadgeSpec(variant: variant, label: label);

  group('StatusBadges.mesa', () {
    test('maps every mesa state', () {
      expect(StatusBadges.mesa('LIBRE'), spec(BadgeVariant.success, 'Libre'));
      expect(
        StatusBadges.mesa('OCUPADA'),
        spec(BadgeVariant.warning, 'Ocupada'),
      );
      expect(StatusBadges.mesa('CUENTA'), spec(BadgeVariant.info, 'Cuenta'));
    });

    test('is case-insensitive and trims the raw value', () {
      expect(StatusBadges.mesa(' libre '), spec(BadgeVariant.success, 'Libre'));
    });

    test('falls back to neutral with the raw value for unknown states', () {
      expect(
        StatusBadges.mesa('MANTENIMIENTO'),
        spec(BadgeVariant.neutral, 'MANTENIMIENTO'),
      );
    });

    test('falls back to neutral dash for null', () {
      expect(StatusBadges.mesa(null), spec(BadgeVariant.neutral, '-'));
    });
  });

  group('StatusBadges.pedido', () {
    test('maps every pedido state', () {
      expect(
        StatusBadges.pedido('ABIERTO'),
        spec(BadgeVariant.info, 'Abierto'),
      );
      expect(
        StatusBadges.pedido('EN_PREPARACION'),
        spec(BadgeVariant.warning, 'En Preparación'),
      );
      expect(
        StatusBadges.pedido('SERVIDO'),
        spec(BadgeVariant.success, 'Servido'),
      );
      expect(
        StatusBadges.pedido('FACTURADO'),
        spec(BadgeVariant.success, 'Facturado'),
      );
      expect(
        StatusBadges.pedido('ANULADO'),
        spec(BadgeVariant.danger, 'Anulado'),
      );
    });

    test('falls back to neutral for unknown states', () {
      expect(StatusBadges.pedido('OTRO'), spec(BadgeVariant.neutral, 'OTRO'));
    });
  });

  group('StatusBadges.factura', () {
    test('maps every factura state', () {
      expect(
        StatusBadges.factura('EMITIDA'),
        spec(BadgeVariant.success, 'Emitida'),
      );
      expect(
        StatusBadges.factura('ANULADA'),
        spec(BadgeVariant.danger, 'Anulada'),
      );
    });

    test('falls back to neutral for unknown states', () {
      expect(
        StatusBadges.factura('PENDIENTE'),
        spec(BadgeVariant.neutral, 'PENDIENTE'),
      );
    });
  });

  group('StatusBadges booleans', () {
    test('disponible', () {
      expect(
        StatusBadges.disponible(true),
        spec(BadgeVariant.success, 'Disponible'),
      );
      expect(
        StatusBadges.disponible(false),
        spec(BadgeVariant.danger, 'Agotado'),
      );
    });

    test('activo', () {
      expect(StatusBadges.activo(true), spec(BadgeVariant.success, 'Activo'));
      expect(
        StatusBadges.activo(false),
        spec(BadgeVariant.neutral, 'Inactivo'),
      );
    });
  });

  group('BadgeColors', () {
    test('success uses emerald 50/800/200', () {
      final colors = BadgeColors.of(BadgeVariant.success);
      expect(colors.background, AppColors.emerald50);
      expect(colors.foreground, AppColors.emerald800);
      expect(colors.border, AppColors.emerald200);
    });

    test('warning uses amber 50/800/200', () {
      final colors = BadgeColors.of(BadgeVariant.warning);
      expect(colors.background, AppColors.amber50);
      expect(colors.foreground, AppColors.amber800);
      expect(colors.border, AppColors.amber200);
    });

    test('danger uses rose 50/800/200', () {
      final colors = BadgeColors.of(BadgeVariant.danger);
      expect(colors.background, AppColors.rose50);
      expect(colors.foreground, AppColors.rose800);
      expect(colors.border, AppColors.rose200);
    });

    test('info uses sky 50/800/200', () {
      final colors = BadgeColors.of(BadgeVariant.info);
      expect(colors.background, AppColors.sky50);
      expect(colors.foreground, AppColors.sky800);
      expect(colors.border, AppColors.sky200);
    });

    test('neutral uses gray 100/700/200', () {
      final colors = BadgeColors.of(BadgeVariant.neutral);
      expect(colors.background, AppColors.gray100);
      expect(colors.foreground, AppColors.gray700);
      expect(colors.border, AppColors.gray200);
    });
  });

  group('RoleChip.colorsFor', () {
    test('maps each role to its web colors', () {
      expect(
        RoleChip.colorsFor('ADMIN'),
        const RoleChipColors(
          background: AppColors.purple100,
          foreground: AppColors.purple800,
        ),
      );
      expect(
        RoleChip.colorsFor('MESERO'),
        const RoleChipColors(
          background: AppColors.emerald100,
          foreground: AppColors.emerald800,
        ),
      );
      expect(
        RoleChip.colorsFor('COCINA'),
        const RoleChipColors(
          background: AppColors.amber100,
          foreground: AppColors.amber800,
        ),
      );
      expect(
        RoleChip.colorsFor('CLIENTE'),
        const RoleChipColors(
          background: AppColors.blue100,
          foreground: AppColors.blue800,
        ),
      );
    });

    test('falls back to neutral gray for unknown roles', () {
      final colors = RoleChip.colorsFor('OTRO');
      expect(colors.background, AppColors.gray100);
      expect(colors.foreground, AppColors.gray700);
    });

    test('colors are plain Color values', () {
      expect(RoleChip.colorsFor('ADMIN').background, isA<Color>());
    });
  });
}
