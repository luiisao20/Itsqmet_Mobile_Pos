import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';

class AdminMetricsState extends Equatable {
  const AdminMetricsState({
    this.platos = 0,
    this.mesas = 0,
    this.personal = 0,
    this.insumos = 0,
  });

  final int platos;
  final int mesas;
  final int personal;
  final int insumos;

  AdminMetricsState copyWith({
    int? platos,
    int? mesas,
    int? personal,
    int? insumos,
  }) {
    return AdminMetricsState(
      platos: platos ?? this.platos,
      mesas: mesas ?? this.mesas,
      personal: personal ?? this.personal,
      insumos: insumos ?? this.insumos,
    );
  }

  @override
  List<Object?> get props => [platos, mesas, personal, insumos];
}

class AdminMetricsCubit extends Cubit<AdminMetricsState> {
  AdminMetricsCubit({
    required this._catalogoRepository,
    required this._mesaRepository,
    required this._usuarioRepository,
    required this._insumoRepository,
    required this._changes,
  }) : super(const AdminMetricsState());

  static const int pageSize = 100;

  final CatalogoRepository _catalogoRepository;
  final MesaRepository _mesaRepository;
  final UsuarioRepository _usuarioRepository;
  final InsumoRepository _insumoRepository;
  final AdminChanges _changes;
  StreamSubscription<void>? _subscription;

  Future<void> load() async {
    _subscription ??= _changes.stream.listen((_) => load());
    await Future.wait([
      _count(
        () => _catalogoRepository.getPlatos(page: 0, size: pageSize),
        (count) => state.copyWith(platos: count),
      ),
      _count(
        () => _mesaRepository.getMesas(page: 0, size: pageSize),
        (count) => state.copyWith(mesas: count),
      ),
      _count(
        () => _usuarioRepository.getUsuarios(page: 0, size: pageSize),
        (count) => state.copyWith(personal: count),
      ),
      _count(
        () => _insumoRepository.getInsumos(page: 0, size: pageSize),
        (count) => state.copyWith(insumos: count),
      ),
    ]);
  }

  Future<void> _count(
    Future<PageResult<Object>> Function() request,
    AdminMetricsState Function(int count) apply,
  ) async {
    try {
      final page = await request();
      if (isClosed) return;
      emit(apply(page.content.length));
    } on AppException {
      return;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
