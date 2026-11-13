import 'package:itsqmet_mobile_pos/config/helpers/date_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/widgets/kds_action_button.dart';
import 'package:material_ui/material_ui.dart';

class CocinaPedidoCard extends StatelessWidget {
  const CocinaPedidoCard({
    super.key,
    required this.pedido,
    required this.onUpdateEstado,
  });

  final Pedido pedido;
  final void Function(Pedido pedido, EstadoPedido estado) onUpdateEstado;

  @override
  Widget build(BuildContext context) {
    final (border, ring) = switch (pedido.estado) {
      EstadoPedido.abierto => (AppColors.sky300, AppColors.sky100),
      EstadoPedido.enPreparacion => (AppColors.amber300, AppColors.amber100),
      _ => (AppColors.emerald200, null),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          if (ring != null) BoxShadow(color: ring, spreadRadius: 2),
          ...AppShadows.sm,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(pedido: pedido),
              _Staff(pedido: pedido),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, detalle) in pedido.detalles.indexed)
                      _Line(detalle: detalle, divided: index > 0),
                  ],
                ),
              ),
              if (_hasText(pedido.observaciones))
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.s2),
                  padding: const EdgeInsets.all(AppSpacing.s2),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Nota general: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: pedido.observaciones),
                      ],
                    ),
                    style: AppTextStyles.xs.copyWith(color: AppColors.gray700),
                  ),
                ),
            ],
          ),
          _Actions(pedido: pedido, onUpdateEstado: onUpdateEstado),
        ],
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

class _Header extends StatelessWidget {
  const _Header({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final fecha = pedido.fechaApertura;
    final salon = pedido.tipo == TipoPedido.salon;

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${pedido.id}',
                  style: AppTextStyles.lg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald950,
                  ),
                ),
                if (fecha != null)
                  Text(
                    AppDateFormat.time(fecha),
                    style: AppTextStyles.text11.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: salon ? AppColors.emerald100 : AppColors.purple100,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!salon) ...[
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: AppColors.purple900,
                  ),
                  AppSpacing.w4,
                ],
                Text(
                  salon ? 'Mesa ${pedido.numeroMesa ?? ''}' : 'Para Llevar',
                  style: AppTextStyles.xs.copyWith(
                    fontWeight: FontWeight.w800,
                    color: salon ? AppColors.emerald900 : AppColors.purple900,
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

class _Staff extends StatelessWidget {
  const _Staff({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.text11.copyWith(color: AppColors.gray500);
    const strong = TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.gray700,
    );
    final cliente = pedido.razonSocialCliente;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.s2,
        runSpacing: AppSpacing.s1,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Atendido por: '),
                TextSpan(text: pedido.nombreUsuario ?? '', style: strong),
              ],
            ),
            style: style,
          ),
          if (_hasText(cliente))
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Cliente: '),
                  TextSpan(text: cliente, style: strong),
                ],
              ),
              style: style,
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.detalle, required this.divided});

  final DetallePedido detalle;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final notas = detalle.notasPreparacion;

    return Container(
      margin: EdgeInsets.only(top: divided ? AppSpacing.s2 : 0),
      padding: const EdgeInsets.only(top: AppSpacing.s2),
      decoration: BoxDecoration(
        border: divided
            ? const Border(top: BorderSide(color: AppColors.gray100))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.emerald600,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              '${detalle.cantidad}',
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
          AppSpacing.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  detalle.nombrePlato,
                  style: AppTextStyles.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: AppColors.gray900,
                  ),
                ),
                if (_hasText(notas))
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.s1),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.amber50,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(color: AppColors.amber200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.amber900,
                        ),
                        AppSpacing.w4,
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Instrucción: ',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: notas),
                              ],
                            ),
                            style: AppTextStyles.xs.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.amber900,
                            ),
                          ),
                        ),
                      ],
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

class _Actions extends StatelessWidget {
  const _Actions({required this.pedido, required this.onUpdateEstado});

  final Pedido pedido;
  final void Function(Pedido pedido, EstadoPedido estado) onUpdateEstado;

  @override
  Widget build(BuildContext context) {
    final Widget? main = switch (pedido.estado) {
      EstadoPedido.abierto => KdsActionButton(
        label: 'Iniciar Preparación',
        icon: Icons.local_fire_department_outlined,
        color: AppColors.amber600,
        pressedColor: AppColors.amber700,
        onPressed: () => onUpdateEstado(pedido, EstadoPedido.enPreparacion),
      ),
      EstadoPedido.enPreparacion => KdsActionButton(
        label: 'Marcar Servido / Listo',
        icon: Icons.check_circle_outline,
        color: AppColors.emerald600,
        pressedColor: AppColors.emerald700,
        onPressed: () => onUpdateEstado(pedido, EstadoPedido.servido),
      ),
      EstadoPedido.servido => Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.emerald200),
        ),
        child: Text(
          'Listo para Despacho / Mesa',
          textAlign: TextAlign.center,
          style: AppTextStyles.xs.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.emerald700,
          ),
        ),
      ),
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s3),
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(child: main ?? const SizedBox.shrink()),
          AppSpacing.w8,
          TextButton(
            onPressed: () => onUpdateEstado(pedido, EstadoPedido.anulado),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.rose500,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smAll,
              ),
              textStyle: AppTextStyles.xs.copyWith(fontWeight: FontWeight.w600),
            ),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
  }
}
