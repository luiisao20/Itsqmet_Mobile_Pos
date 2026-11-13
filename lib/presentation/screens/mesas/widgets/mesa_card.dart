import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class MesaCard extends StatelessWidget {
  const MesaCard({
    super.key,
    required this.mesa,
    required this.onTap,
    required this.onCambiarEstado,
  });

  static const double height = 176;
  static const String defaultUbicacion = 'Zona Principal';

  final Mesa mesa;
  final VoidCallback onTap;
  final ValueChanged<EstadoMesa> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final palette = _MesaPalette.of(mesa.estado);
    final ubicacion = mesa.ubicacion;
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(palette.tint, AppColors.white),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: palette.border, width: 2),
        boxShadow: AppShadows.xs,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xlAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Mesa ${mesa.numeroMesa}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.x2l.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: AppColors.emerald950,
                          ),
                        ),
                      ),
                      AppSpacing.w4,
                      Flexible(
                        child: StatusBadge(
                          BadgeSpec(
                            variant: StatusBadges.mesa(mesa.estado.toJson())
                                .variant,
                            label: mesa.estado.toJson(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Capacidad: ',
                        children: [
                          TextSpan(
                            text: '${mesa.capacidad} personas',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xs.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    Text(
                      ubicacion == null || ubicacion.isEmpty
                          ? defaultUbicacion
                          : ubicacion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text11.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: AppSpacing.s2),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.gray100)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: _MesaAction(
                    estado: mesa.estado,
                    onCambiarEstado: onCambiarEstado,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MesaAction extends StatelessWidget {
  const _MesaAction({required this.estado, required this.onCambiarEstado});

  final EstadoMesa estado;
  final ValueChanged<EstadoMesa> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return switch (estado) {
      EstadoMesa.libre => const _ActionLabel(
        text: '+ Tomar Comanda',
        color: AppColors.emerald700,
      ),
      EstadoMesa.ocupada => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onCambiarEstado(EstadoMesa.cuenta),
        child: const _ActionLabel(
          text: 'Pedir Cuenta',
          color: AppColors.sky700,
        ),
      ),
      EstadoMesa.cuenta => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onCambiarEstado(EstadoMesa.libre),
        child: const _ActionLabel(text: 'Liberar', color: AppColors.emerald700),
      ),
    };
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.text11.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

class _MesaPalette {
  const _MesaPalette({required this.border, required this.tint});

  final Color border;
  final Color tint;

  static _MesaPalette of(EstadoMesa estado) => switch (estado) {
    EstadoMesa.libre => _MesaPalette(
      border: AppColors.emerald200,
      tint: AppColors.emerald50.withValues(alpha: 0.4),
    ),
    EstadoMesa.ocupada => _MesaPalette(
      border: AppColors.amber200,
      tint: AppColors.amber50.withValues(alpha: 0.4),
    ),
    EstadoMesa.cuenta => _MesaPalette(
      border: AppColors.sky200,
      tint: AppColors.sky50.withValues(alpha: 0.4),
    ),
  };
}
