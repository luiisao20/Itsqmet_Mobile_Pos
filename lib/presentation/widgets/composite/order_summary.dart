import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/cart/cart.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/cards/app_card.dart';
import 'package:material_ui/material_ui.dart';

typedef QuantityChangeCallback = void Function(int index, int delta);
typedef NotesChangeCallback = void Function(int index, String notes);

class OrderSummary extends StatefulWidget {
  const OrderSummary({
    super.key,
    required this.items,
    this.observaciones = '',
    this.loading = false,
    this.title = 'Resumen del Pedido',
    this.submitLabel = 'Confirmar Pedido',
    this.onQuantityChange,
    this.onRemoveItem,
    this.onNotesChange,
    this.onObservacionesChange,
    this.onSubmit,
  });

  static const double listMaxHeight = 380;

  final List<CartItem> items;
  final String observaciones;
  final bool loading;
  final String title;
  final String submitLabel;
  final QuantityChangeCallback? onQuantityChange;
  final ValueChanged<int>? onRemoveItem;
  final NotesChangeCallback? onNotesChange;
  final ValueChanged<String>? onObservacionesChange;
  final VoidCallback? onSubmit;

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final Map<int, TextEditingController> _notes = {};
  late final TextEditingController _observaciones = TextEditingController(
    text: widget.observaciones,
  );

  @override
  void initState() {
    super.initState();
    _syncNotes();
  }

  @override
  void didUpdateWidget(OrderSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncText(_observaciones, widget.observaciones);
    _syncNotes();
  }

  @override
  void dispose() {
    _observaciones.dispose();
    for (final controller in _notes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncNotes() {
    final ids = <int>{};
    for (final item in widget.items) {
      ids.add(item.plato.id);
      final controller = _notes[item.plato.id];
      if (controller == null) {
        _notes[item.plato.id] = TextEditingController(
          text: item.notasPreparacion,
        );
      } else {
        _syncText(controller, item.notasPreparacion);
      }
    }
    final stale = _notes.keys.where((id) => !ids.contains(id)).toList();
    for (final id in stale) {
      _notes.remove(id)?.dispose();
    }
  }

  void _syncText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: widget.title, count: items.length),
          if (items.isEmpty) const _EmptyCart() else ..._content(items),
        ],
      ),
    );
  }

  List<Widget> _content(List<CartItem> items) {
    final totals = CartTotals.fromItems(items);
    final busy = widget.loading;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: OrderSummary.listMaxHeight,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.gray100,
            ),
            itemBuilder: (context, index) => _CartLine(
              key: ValueKey(items[index].plato.id),
              item: items[index],
              notesController: _notes[items[index].plato.id]!,
              onQuantityChange: widget.onQuantityChange == null
                  ? null
                  : (delta) => widget.onQuantityChange!(index, delta),
              onRemove: widget.onRemoveItem == null
                  ? null
                  : () => widget.onRemoveItem!(index),
              onNotesChange: widget.onNotesChange == null
                  ? null
                  : (notes) => widget.onNotesChange!(index, notes),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Observaciones generales del pedido:',
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h4,
            _SummaryField(
              controller: _observaciones,
              hint: 'Ej: Empacar salsas por separado, cubiertos extras...',
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s3,
                vertical: AppSpacing.s2,
              ),
              filled: false,
              onChanged: widget.onObservacionesChange,
            ),
          ],
        ),
      ),
      _Totals(totals: totals),
      AppSpacing.h16,
      AppButton(
        label: busy ? 'Procesando...' : widget.submitLabel,
        expand: true,
        onPressed: busy ? null : widget.onSubmit,
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.base.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
          ),
          AppSpacing.w8,
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: AppRadius.fullAll,
              border: Border.all(color: AppColors.emerald200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s2,
                vertical: 2,
              ),
              child: Text(
                '$count items',
                style: AppTextStyles.xs.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.emerald800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.emerald50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 22,
              color: AppColors.emerald600,
            ),
          ),
          AppSpacing.h8,
          Text(
            'No hay platos agregados',
            textAlign: TextAlign.center,
            style: AppTextStyles.sm.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.h4,
          Text(
            'Selecciona platos del menú para armar el pedido',
            textAlign: TextAlign.center,
            style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    super.key,
    required this.item,
    required this.notesController,
    this.onQuantityChange,
    this.onRemove,
    this.onNotesChange,
  });

  final CartItem item;
  final TextEditingController notesController;
  final ValueChanged<int>? onQuantityChange;
  final VoidCallback? onRemove;
  final ValueChanged<String>? onNotesChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.plato.nombre,
                      style: AppTextStyles.sm.copyWith(
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    Text(
                      '${CurrencyFormat.format(item.plato.precioUnitario)} c/u',
                      style: AppTextStyles.xs.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.w8,
              _QuantityControl(
                cantidad: item.cantidad,
                onChange: onQuantityChange,
              ),
              AppSpacing.w8,
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormat.format(item.subtotal),
                      style: AppTextStyles.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onRemove,
                      child: Text(
                        'Eliminar',
                        style: AppTextStyles.text11.copyWith(
                          color: AppColors.rose500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          _SummaryField(
            controller: notesController,
            hint: 'Instrucción de cocina (ej: sin cebolla, término medio...)',
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            filled: true,
            onChanged: onNotesChange,
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.cantidad, this.onChange});

  final int cantidad;
  final ValueChanged<int>? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.7),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            symbol: '-',
            onTap: onChange == null ? null : () => onChange!(-1),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 20,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.emerald950,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _StepButton(
            symbol: '+',
            onTap: onChange == null ? null : () => onChange!(1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.symbol, this.onTap});

  final String symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Text(
              symbol,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.emerald800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryField extends StatelessWidget {
  const _SummaryField({
    required this.controller,
    required this.hint,
    required this.padding,
    required this.filled,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final EdgeInsets padding;
  final bool filled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: AppRadius.smAll,
      borderSide: BorderSide(color: color),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.xs.copyWith(color: AppColors.gray800),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppTextStyles.xs.copyWith(color: AppColors.gray400),
        contentPadding: padding,
        filled: true,
        fillColor: filled
            ? AppColors.gray50.withValues(alpha: 0.5)
            : AppColors.white,
        enabledBorder: border(AppColors.gray200),
        border: border(AppColors.gray200),
        focusedBorder: border(AppColors.emerald500),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.totals});

  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.xs.copyWith(color: AppColors.gray500);
    final value = AppTextStyles.xs.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.gray800,
    );

    Widget line(String label, double amount) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: muted),
        Text(CurrencyFormat.format(amount), style: value),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s4),
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line('Subtotal', totals.subtotal),
          const SizedBox(height: 6),
          line('IVA (15%)', totals.iva),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.emerald100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar',
                  style: AppTextStyles.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald950,
                  ),
                ),
                Text(
                  CurrencyFormat.format(totals.total),
                  style: AppTextStyles.base.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700,
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
