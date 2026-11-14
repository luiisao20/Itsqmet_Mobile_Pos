import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cliente_pedidos/cliente_pedidos.dart';
import 'package:material_ui/material_ui.dart';

class PaquetesSorpresaTab extends StatelessWidget {
  const PaquetesSorpresaTab({
    super.key,
    required this.loading,
    required this.paquetes,
    required this.rescatandoId,
  });

  final bool loading;
  final List<PaqueteSorpresa> paquetes;
  final int? rescatandoId;

  @override
  Widget build(BuildContext context) {
    if (loading && paquetes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.emerald600),
            AppSpacing.h16,
            Text(
              'Buscando paquetes sorpresa disponibles...',
              style: AppTextStyles.sm.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    final columns = context.atLeastMd ? 2 : 1;
    final rows = <Widget>[];
    for (var start = 0; start < paquetes.length; start += columns) {
      final chunk = paquetes.skip(start).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < columns; index++) ...[
                if (index > 0) AppSpacing.w16,
                Expanded(
                  child: index < chunk.length
                      ? _PaqueteCard(
                          paquete: chunk[index],
                          isRescuing: rescatandoId == chunk[index].id,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ODS12Banner(),
        AppSpacing.h20,
        if (paquetes.isEmpty)
          const _SinPaquetes()
        else
          ...[
            for (final (index, row) in rows.indexed) ...[
              if (index > 0) AppSpacing.h16,
              row,
            ],
          ],
      ],
    );
  }
}

class _ODS12Banner extends StatelessWidget {
  const _ODS12Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.emerald200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.emerald600,
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Rescate de Alimentos • ODS 12',
                      style: AppTextStyles.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.emerald700,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        'Cero Desperdicio',
                        style: AppTextStyles.xs.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Salva paquetes de comida fresca y deliciosa preparada hoy a una fracción de su valor antes del cierre. ¡Cuidas tu bolsillo y el medio ambiente!',
                  style: AppTextStyles.xs.copyWith(
                    color: AppColors.emerald800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaqueteCard extends StatelessWidget {
  const _PaqueteCard({
    required this.paquete,
    required this.isRescuing,
  });

  final PaqueteSorpresa paquete;
  final bool isRescuing;

  String _formatCountdown(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final agotado = paquete.cantidadDisponible <= 0;
    final porAbrir = !paquete.disponibleAhora && paquete.segundosParaApertura > 0;
    final disponible = paquete.disponibleAhora && !agotado;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: disponible ? AppColors.emerald200 : AppColors.gray200,
          width: disponible ? 1.5 : 1.0,
        ),
        boxShadow: disponible ? AppShadows.md : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen con badging
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 54,
                    color: AppColors.emerald500,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      borderRadius: AppRadius.mdAll,
                      boxShadow: AppShadows.sm,
                    ),
                    child: Text(
                      '-${paquete.porcentajeDescuento}% DTO',
                      style: AppTextStyles.xs.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald900.withAlpha(200),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Retiro hasta ${paquete.horaFinRecogida}',
                          style: AppTextStyles.xs.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado en vivo
                if (agotado) ...[
                  const _BadgeStatus(
                    icon: Icons.cancel_outlined,
                    color: AppColors.gray500,
                    bgColor: AppColors.gray100,
                    text: 'Agotado por hoy',
                  ),
                ] else if (porAbrir) ...[
                  _BadgeStatus(
                    icon: Icons.lock_clock_outlined,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                    text: 'Se habilita a las ${paquete.horaInicioVisibilidad} (Faltan ${_formatCountdown(paquete.segundosParaApertura)})',
                  ),
                ] else ...[
                  _BadgeStatus(
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.emerald700,
                    bgColor: const Color(0xFFD1FAE5),
                    text: '¡Disponible Ahora! • Quedan ${paquete.cantidadDisponible} pack(s)',
                  ),
                ],
                AppSpacing.h12,

                Text(
                  paquete.titulo,
                  style: AppTextStyles.base.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paquete.descripcion ??
                      'Contenido sorpresa elaborado con ingredientes frescos del día para reducir el desperdicio alimentario.',
                  style: AppTextStyles.xs.copyWith(
                    color: AppColors.gray600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.h16,

                // Precios y Botón Rescatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor habitual: ${CurrencyFormat.format(paquete.precioEstimadoOriginal)}',
                          style: AppTextStyles.xs.copyWith(
                            color: AppColors.gray400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Rescate: ',
                              style: AppTextStyles.xs.copyWith(
                                color: AppColors.emerald800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              CurrencyFormat.format(paquete.precioRescate),
                              style: AppTextStyles.lg.copyWith(
                                color: AppColors.emerald700,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppButton(
                      label: agotado
                          ? 'Agotado'
                          : porAbrir
                              ? 'Bloqueado'
                              : 'Rescatar',
                      leading: Icons.card_giftcard_rounded,
                      size: AppButtonSize.sm,
                      variant: disponible
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      loading: isRescuing,
                      onPressed: disponible
                          ? () => _openRescueModal(context, paquete)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRescueModal(BuildContext context, PaqueteSorpresa paquete) {
    final cubit = context.read<ClientePedidosCubit>();
    showAppModal<void>(
      context: context,
      title: 'Rescatar Paquete Sorpresa',
      body: _RescueModalContent(paquete: paquete, cubit: cubit),
    );
  }
}

class _BadgeStatus extends StatelessWidget {
  const _BadgeStatus({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.xs.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RescueModalContent extends StatefulWidget {
  const _RescueModalContent({
    required this.paquete,
    required this.cubit,
  });

  final PaqueteSorpresa paquete;
  final ClientePedidosCubit cubit;

  @override
  State<_RescueModalContent> createState() => _RescueModalContentState();
}

class _RescueModalContentState extends State<_RescueModalContent> {
  int _cantidad = 1;
  final _obsController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _submitting = true);
    final ok = await widget.cubit.rescatarPaquete(
      widget.paquete.id,
      cantidad: _cantidad,
      observaciones: _obsController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.paquete.precioRescate * _cantidad;
    final maxDisponibles = widget.paquete.cantidadDisponible;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.paquete.titulo,
            style: AppTextStyles.base.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hora límite de recogida: Hoy hasta las ${widget.paquete.horaFinRecogida}',
            style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
          ),
          AppSpacing.h16,

          // Cantidad Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad de paquetes',
                      style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$maxDisponibles disponibles',
                      style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.emerald700,
                      onPressed: _cantidad > 1
                          ? () => setState(() => _cantidad--)
                          : null,
                    ),
                    Text(
                      '$_cantidad',
                      style: AppTextStyles.base.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.emerald700,
                      onPressed: _cantidad < maxDisponibles
                          ? () => setState(() => _cantidad++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h16,

          AppTextField(
            controller: _obsController,
            label: 'Observaciones o Alergias (Opcional)',
            hint: 'Ej: Alérgico a mariscos, sin cubiertos plásticos...',
            maxLines: 2,
          ),
          AppSpacing.h16,

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.emerald200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar:',
                  style: AppTextStyles.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald900,
                  ),
                ),
                Text(
                  CurrencyFormat.format(total),
                  style: AppTextStyles.lg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald800,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h24,

          AppButton(
            label: 'Confirmar Rescate',
            leading: Icons.check_circle_outline_rounded,
            loading: _submitting,
            onPressed: _confirmar,
          ),
        ],
      ),
    );
  }
}

class _SinPaquetes extends StatelessWidget {
  const _SinPaquetes();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_outlined,
            size: 48,
            color: AppColors.emerald500,
          ),
          AppSpacing.h16,
          Text(
            '¡No hay paquetes sorpresa disponibles por ahora!',
            style: AppTextStyles.base.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.h8,
          Text(
            'Los paquetes sorpresa se activan automáticamente cada tarde/noche cerca a la hora de cierre del restaurante. ¡Revisa más tarde o pide tus platos favoritos a la carta!',
            style: AppTextStyles.sm.copyWith(color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
