import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

class _MockMesas extends Mock implements MesaRepository {}

class _MockUsuarios extends Mock implements UsuarioRepository {}

class _MockInsumos extends Mock implements InsumoRepository {}

Plato _plato(int id) => Plato(
  id: id,
  idCategoria: 1,
  nombre: 'Plato $id',
  precioUnitario: 5,
  aplicaIva: true,
  disponible: true,
);

Mesa _mesa(int id) =>
    Mesa(id: id, numeroMesa: id, capacidad: 4, estado: EstadoMesa.libre);

Insumo _insumo(int id) => Insumo(
  id: id,
  nombre: 'Insumo $id',
  unidadMedida: UnidadMedida.kg,
  stockActual: 10,
  stockMinimo: 5,
  costoPromedio: 1,
  stockBajo: false,
);

void main() {
  late _MockCatalogo catalogo;
  late _MockMesas mesas;
  late _MockUsuarios usuarios;
  late _MockInsumos insumos;
  late AdminChanges changes;

  AdminMetricsCubit build() => AdminMetricsCubit(
    catalogoRepository: catalogo,
    mesaRepository: mesas,
    usuarioRepository: usuarios,
    insumoRepository: insumos,
    changes: changes,
  );

  setUp(() {
    catalogo = _MockCatalogo();
    mesas = _MockMesas();
    usuarios = _MockUsuarios();
    insumos = _MockInsumos();
    changes = AdminChanges();
    when(() => catalogo.getPlatos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_plato(1), _plato(2)]));
    when(() => mesas.getMesas(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_mesa(1)]));
    when(() => usuarios.getUsuarios(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    when(() => insumos.getInsumos(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([_insumo(1), _insumo(2), _insumo(3)]),
    );
  });

  test('counts the loaded platos, mesas, personal and insumos', () async {
    final cubit = build();

    await cubit.load();

    expect(
      cubit.state,
      const AdminMetricsState(platos: 2, mesas: 1, personal: 0, insumos: 3),
    );
    await cubit.close();
  });

  test('a failing source counts zero and the rest still load', () async {
    when(() => mesas.getMesas(page: 0, size: 100))
        .thenThrow(const ServerException());
    final cubit = build();

    await cubit.load();

    expect(cubit.state.mesas, 0);
    expect(cubit.state.platos, 2);
    await cubit.close();
  });

  test('a catalog change reloads the counts', () async {
    final cubit = build();
    await cubit.load();
    when(() => catalogo.getPlatos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_plato(1)]));

    changes.notify();
    await pumpEventQueue();

    expect(cubit.state.platos, 1);
    await cubit.close();
  });

  test('changes after close are ignored', () async {
    final cubit = build();
    await cubit.load();
    await cubit.close();

    changes.notify();
    await pumpEventQueue();

    verify(() => catalogo.getPlatos(page: 0, size: 100)).called(1);
  });
}
