import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_checkbox_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class PlatosTab extends StatelessWidget {
  const PlatosTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlatosCubit>(
      create: (_) => getIt<PlatosCubit>()..load(),
      child: PlatosView(createRequests: createRequests),
    );
  }
}

class PlatosView extends StatelessWidget {
  const PlatosView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(BuildContext context, {Plato? plato}) async {
    final cubit = context.read<PlatosCubit>();
    final form = PlatoFormController(cubit.draftFor(plato));
    await showAdminFormModal<Plato>(
      context: context,
      cubit: cubit,
      title: plato == null ? 'Nuevo Plato' : 'Editar Plato',
      submitLabel: 'Guardar Plato',
      body: PlatoFormBody(form: form, categorias: cubit.categorias),
      onSubmit: () => cubit.savePlato(form.toDraft(), id: plato?.id),
    );
  }

  Future<void> _delete(BuildContext context, Plato plato) async {
    final cubit = context.read<PlatosCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar el plato "${plato.nombre}"?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deletePlato(plato);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<PlatosCubit, Plato>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Plato>(
        title: 'Catálogo de Platos del Menú',
        countLabel: '${state.items.length} registrados',
        emptyMessage: 'No hay platos registrados',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Plato',
            cellBuilder: (_, plato) => _PlatoCell(plato: plato),
          ),
          ResponsiveColumn(
            label: 'Categoría',
            cellBuilder: (_, plato) =>
                _CategoriaChip(label: plato.nombreCategoria ?? 'General'),
          ),
          ResponsiveColumn(
            label: 'Precio',
            cellBuilder: (_, plato) => Text(
              CurrencyFormat.format(plato.precioUnitario),
              style: AppTextStyles.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.emerald800,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'IVA',
            cellBuilder: (_, plato) => Text(
              plato.aplicaIva ? '15%' : '0%',
              style: AppTextStyles.text11.copyWith(
                fontWeight: FontWeight.w600,
                color: plato.aplicaIva
                    ? AppColors.emerald700
                    : AppColors.gray400,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Estado',
            cellBuilder: (context, plato) => Tooltip(
              message: 'Clic para cambiar disponibilidad',
              child: InkWell(
                onTap: () =>
                    context.read<PlatosCubit>().toggleDisponible(plato),
                borderRadius: AppRadius.fullAll,
                child: StatusBadge(StatusBadges.disponible(plato.disponible)),
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, plato) => AdminRowActions(
              onEdit: () => _openForm(context, plato: plato),
              onDelete: () => _delete(context, plato),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatoCell extends StatelessWidget {
  const _PlatoCell({required this.plato});

  final Plato plato;

  @override
  Widget build(BuildContext context) {
    final url = plato.urlImagen;
    final descripcion = plato.descripcion;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (url != null && url.isNotEmpty) ...[
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: Image.network(
              url,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(width: 36, height: 36),
            ),
          ),
          AppSpacing.w12,
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plato.nombre,
                style: AppTextStyles.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                descripcion == null || descripcion.isEmpty
                    ? 'Sin descripción'
                    : descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text11.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  const _CategoriaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.text11.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.gray700,
        ),
      ),
    );
  }
}

class PlatoFormController extends ChangeNotifier {
  PlatoFormController(PlatoDraft draft)
    : nombre = TextEditingController(text: draft.nombre),
      precio = TextEditingController(
        text: CurrencyFormat.plain(draft.precioUnitario),
      ),
      descripcion = TextEditingController(text: draft.descripcion ?? ''),
      urlImagen = TextEditingController(text: draft.urlImagen ?? ''),
      _idCategoria = draft.idCategoria,
      _aplicaIva = draft.aplicaIva,
      _disponible = draft.disponible;

  final TextEditingController nombre;
  final TextEditingController precio;
  final TextEditingController descripcion;
  final TextEditingController urlImagen;
  int _idCategoria;
  bool _aplicaIva;
  bool _disponible;

  int get idCategoria => _idCategoria;
  bool get aplicaIva => _aplicaIva;
  bool get disponible => _disponible;

  set idCategoria(int value) {
    _idCategoria = value;
    notifyListeners();
  }

  set aplicaIva(bool value) {
    _aplicaIva = value;
    notifyListeners();
  }

  set disponible(bool value) {
    _disponible = value;
    notifyListeners();
  }

  PlatoDraft toDraft() => PlatoDraft(
    idCategoria: _idCategoria,
    nombre: nombre.text,
    descripcion: descripcion.text,
    precioUnitario:
        double.tryParse(precio.text.trim().replaceAll(',', '.')) ?? 0,
    aplicaIva: _aplicaIva,
    disponible: _disponible,
    urlImagen: urlImagen.text,
  );

  @override
  void dispose() {
    nombre.dispose();
    precio.dispose();
    descripcion.dispose();
    urlImagen.dispose();
    super.dispose();
  }
}

class PlatoFormBody extends StatefulWidget {
  const PlatoFormBody({
    super.key,
    required this.form,
    required this.categorias,
  });

  final PlatoFormController form;
  final List<CategoriaPlato> categorias;

  @override
  State<PlatoFormBody> createState() => _PlatoFormBodyState();
}

class _PlatoFormBodyState extends State<PlatoFormBody> {
  PlatoFormController get form => widget.form;
  List<CategoriaPlato> get categorias => widget.categorias;

  @override
  void dispose() {
    widget.form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('plato.nombre'),
            label: 'Nombre del Plato',
            required: true,
            hint: 'Ej: Seco de Chivo',
            controller: form.nombre,
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdownField<int>(
                  label: 'Categoría',
                  required: true,
                  value: categorias.any((c) => c.id == form.idCategoria)
                      ? form.idCategoria
                      : null,
                  onChanged: (value) {
                    if (value != null) form.idCategoria = value;
                  },
                  items: [
                    for (final categoria in categorias)
                      DropdownMenuItem(
                        value: categoria.id,
                        child: Text(
                          categoria.nombre,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('plato.precio'),
                  label: 'Precio (\$)',
                  required: true,
                  controller: form.precio,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('plato.descripcion'),
            label: 'Descripción',
            hint: 'Ingredientes principales, guarniciones...',
            controller: form.descripcion,
            maxLines: 2,
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('plato.url'),
            label: 'URL Imagen',
            hint: 'https://...',
            controller: form.urlImagen,
            keyboardType: TextInputType.url,
          ),
          AppSpacing.h16,
          Wrap(
            spacing: AppSpacing.s6,
            runSpacing: AppSpacing.s2,
            children: [
              AppCheckboxField(
                label: 'Aplica IVA (15%)',
                value: form.aplicaIva,
                onChanged: (value) => form.aplicaIva = value,
              ),
              AppCheckboxField(
                label: 'Disponible en Menú',
                value: form.disponible,
                onChanged: (value) => form.disponible = value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
