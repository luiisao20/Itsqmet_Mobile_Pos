import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/widgets/comanda_modal_body.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/widgets/mesa_card.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/widgets/mesas_legend.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/mesas/mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class MesasScreen extends StatelessWidget {
  const MesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MesasCubit>(
      create: (_) => getIt<MesasCubit>()..start(),
      child: const MesasView(),
    );
  }
}

class MesasView extends StatelessWidget {
  const MesasView({super.key});

  static const String title = 'Mapa de Mesas & Salón';
  static const String subtitle =
      'Visualiza el estado de las mesas en tiempo real y asigna comandas de salón';

  @override
  Widget build(BuildContext context) {
    return BlocListener<MesasCubit, MesasState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        NotificationsService.showError(state.errorMessage!);
        context.read<MesasCubit>().clearError();
      },
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: title,
              subtitle: subtitle,
              actions: [MesasLegend()],
            ),
            BlocBuilder<MesasCubit, MesasState>(
              buildWhen: (previous, current) =>
                  previous.loadingMesas != current.loadingMesas ||
                  previous.mesas != current.mesas,
              builder: (context, state) => state.loadingMesas
                  ? const _LoadingMesas()
                  : _MesasGrid(mesas: state.mesas),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMesas extends StatelessWidget {
  const _LoadingMesas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Text(
        'Cargando mesas del salón...',
        textAlign: TextAlign.center,
        style: AppTextStyles.base.copyWith(color: AppColors.gray400),
      ),
    );
  }
}

class _MesasGrid extends StatelessWidget {
  const _MesasGrid({required this.mesas});

  final List<Mesa> mesas;

  static int columnsFor(BuildContext context) {
    if (context.atLeastLg) return 6;
    if (context.atLeastMd) return 4;
    if (context.atLeastSm) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnsFor(context),
        mainAxisExtent: MesaCard.height,
        crossAxisSpacing: AppSpacing.s5,
        mainAxisSpacing: AppSpacing.s5,
      ),
      itemCount: mesas.length,
      itemBuilder: (context, index) {
        final mesa = mesas[index];
        return MesaCard(
          key: ValueKey(mesa.id),
          mesa: mesa,
          onTap: () => _openComanda(context, mesa),
          onCambiarEstado: (estado) =>
              context.read<MesasCubit>().cambiarEstadoMesa(mesa, estado),
        );
      },
    );
  }

  Future<void> _openComanda(BuildContext context, Mesa mesa) async {
    final cubit = context.read<MesasCubit>()..openComanda(mesa);
    await showAppModal<void>(
      context: context,
      title: 'Tomar Comanda - Mesa ${mesa.numeroMesa}',
      body: BlocProvider.value(
        value: cubit,
        child: ComandaModalBody(numeroMesa: mesa.numeroMesa),
      ),
      footer: Builder(
        builder: (footerContext) => AppButton(
          label: 'Cerrar',
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          onPressed: () => closeAppModal<void>(footerContext),
        ),
      ),
    );
    if (!cubit.isClosed) cubit.closeComanda();
  }
}
