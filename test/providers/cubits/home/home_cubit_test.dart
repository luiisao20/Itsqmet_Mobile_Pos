import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/home/home_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockCatalogoRepository catalogo;
  late _MockAuthRepository auth;

  final entradas = categoriaFixture(id: 1, nombre: 'Entradas');
  final fondos = categoriaFixture(id: 2, nombre: 'Fondos');
  final ceviche = platoFixture(id: 10, nombre: 'Ceviche');
  final seco = platoFixture(id: 11, nombre: 'Seco de pollo', idCategoria: 2);

  HomeCubit build() =>
      HomeCubit(catalogoRepository: catalogo, authRepository: auth);

  setUp(() {
    catalogo = _MockCatalogoRepository();
    auth = _MockAuthRepository();
  });

  test('initial state is loading with no data, no category and empty term', () {
    final cubit = build();
    expect(cubit.state, const HomeState());
    expect(cubit.state.loading, isTrue);
    expect(cubit.state.categorias, isEmpty);
    expect(cubit.state.platos, isEmpty);
    expect(cubit.state.selectedCategoriaId, isNull);
    expect(cubit.state.searchTerm, '');
    cubit.close();
  });

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'loads categorias and all platos with page size 50',
      setUp: () {
        when(() => catalogo.getCategorias())
            .thenAnswer((_) async => [entradas, fondos]);
        when(() => catalogo.getPlatos(size: 50))
            .thenAnswer((_) async => PageResult.single([ceviche, seco]));
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.categorias, [entradas, fondos]);
        expect(cubit.state.platos, [ceviche, seco]);
        expect(cubit.state.loading, isFalse);
        verify(() => catalogo.getPlatos(size: 50)).called(1);
        verifyNever(
          () => catalogo.getPlatosByCategoria(any(), size: any(named: 'size')),
        );
      },
    );

    blocTest<HomeCubit, HomeState>(
      'ignores a categorias failure and still shows platos',
      setUp: () {
        when(() => catalogo.getCategorias())
            .thenThrow(const NetworkException());
        when(() => catalogo.getPlatos(size: 50))
            .thenAnswer((_) async => PageResult.single([ceviche]));
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.categorias, isEmpty);
        expect(cubit.state.platos, [ceviche]);
        expect(cubit.state.loading, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'stops loading and keeps platos empty when platos fail',
      setUp: () {
        when(() => catalogo.getCategorias()).thenAnswer((_) async => []);
        when(() => catalogo.getPlatos(size: 50))
            .thenThrow(const NetworkException());
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.platos, isEmpty);
        expect(cubit.state.loading, isFalse);
      },
    );
  });

  group('filterByCategoria', () {
    blocTest<HomeCubit, HomeState>(
      'selects the category, clears the term and loads its platos',
      setUp: () {
        when(() => catalogo.getPlatosByCategoria(2, size: 50))
            .thenAnswer((_) async => PageResult.single([seco]));
      },
      build: build,
      seed: () =>
          HomeState(loading: false, platos: [ceviche, seco], searchTerm: 'cev'),
      act: (cubit) => cubit.filterByCategoria(2),
      expect: () => [
        HomeState(
          loading: true,
          platos: [ceviche, seco],
          selectedCategoriaId: 2,
        ),
        HomeState(loading: false, platos: [seco], selectedCategoriaId: 2),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'null selects all platos again',
      setUp: () {
        when(() => catalogo.getPlatos(size: 50))
            .thenAnswer((_) async => PageResult.single([ceviche, seco]));
      },
      build: build,
      seed: () =>
          HomeState(loading: false, platos: [seco], selectedCategoriaId: 2),
      act: (cubit) => cubit.filterByCategoria(null),
      verify: (cubit) {
        expect(cubit.state.selectedCategoriaId, isNull);
        expect(cubit.state.platos, [ceviche, seco]);
        expect(cubit.state.loading, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'keeps previous platos when the category request fails',
      setUp: () {
        when(() => catalogo.getPlatosByCategoria(2, size: 50))
            .thenThrow(const NetworkException());
      },
      build: build,
      seed: () => HomeState(loading: false, platos: [ceviche]),
      act: (cubit) => cubit.filterByCategoria(2),
      verify: (cubit) {
        expect(cubit.state.platos, [ceviche]);
        expect(cubit.state.loading, isFalse);
        expect(cubit.state.selectedCategoriaId, 2);
      },
    );
  });

  group('search', () {
    blocTest<HomeCubit, HomeState>(
      'searchTermChanged stores the term without loading',
      build: build,
      seed: () => const HomeState(loading: false),
      act: (cubit) => cubit.searchTermChanged('cev'),
      expect: () => [const HomeState(loading: false, searchTerm: 'cev')],
    );

    blocTest<HomeCubit, HomeState>(
      'searches the trimmed term within the selected category',
      setUp: () {
        when(() => catalogo.searchPlatos(nombre: 'cev', idCategoria: 1))
            .thenAnswer((_) async => PageResult.single([ceviche]));
      },
      build: build,
      seed: () => HomeState(
        loading: false,
        platos: [ceviche, seco],
        selectedCategoriaId: 1,
        searchTerm: '  cev  ',
      ),
      act: (cubit) => cubit.search(),
      verify: (cubit) {
        expect(cubit.state.platos, [ceviche]);
        expect(cubit.state.loading, isFalse);
        verify(() => catalogo.searchPlatos(nombre: 'cev', idCategoria: 1))
            .called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'searches without category when none is selected',
      setUp: () {
        when(() => catalogo.searchPlatos(nombre: 'seco'))
            .thenAnswer((_) async => PageResult.single([seco]));
      },
      build: build,
      seed: () => const HomeState(loading: false, searchTerm: 'seco'),
      act: (cubit) => cubit.search(),
      verify: (cubit) {
        expect(cubit.state.platos, [seco]);
        verify(() => catalogo.searchPlatos(nombre: 'seco')).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'an empty term reloads the platos of the selected category',
      setUp: () {
        when(() => catalogo.getPlatosByCategoria(1, size: 50))
            .thenAnswer((_) async => PageResult.single([ceviche]));
      },
      build: build,
      seed: () => const HomeState(
        loading: false,
        selectedCategoriaId: 1,
        searchTerm: '   ',
      ),
      act: (cubit) => cubit.search(),
      verify: (cubit) {
        expect(cubit.state.platos, [ceviche]);
        verifyNever(
          () => catalogo.searchPlatos(
            nombre: any(named: 'nombre'),
            idCategoria: any(named: 'idCategoria'),
          ),
        );
      },
    );

    blocTest<HomeCubit, HomeState>(
      'stops loading when the search fails',
      setUp: () {
        when(() => catalogo.searchPlatos(nombre: 'x'))
            .thenThrow(const NetworkException());
      },
      build: build,
      seed: () => HomeState(loading: false, platos: [ceviche], searchTerm: 'x'),
      act: (cubit) => cubit.search(),
      verify: (cubit) {
        expect(cubit.state.platos, [ceviche]);
        expect(cubit.state.loading, isFalse);
      },
    );
  });

  group('addToCartDestination', () {
    test(
      'without session goes to login returning to cliente pedidos',
      () async {
        when(() => auth.me()).thenThrow(const UnauthorizedException());
        final cubit = build();
        expect(
          await cubit.addToCartDestination(),
          '/login?returnUrl=%2Fcliente%2Fpedidos',
        );
        await cubit.close();
      },
    );

    final cases = <Rol, String?>{
      Rol.cliente: '/cliente/pedidos',
      Rol.mesero: '/mesas',
      Rol.admin: '/mesas',
      Rol.cocina: null,
    };
    for (final entry in cases.entries) {
      test('${entry.key.name} goes to ${entry.value}', () async {
        when(() => auth.me()).thenAnswer((_) async => authUser(rol: entry.key));
        final cubit = build();
        expect(await cubit.addToCartDestination(), entry.value);
        await cubit.close();
      });
    }
  });

  group('orderDestination', () {
    test('without session goes to login', () async {
      when(() => auth.me()).thenThrow(const NetworkException());
      final cubit = build();
      expect(await cubit.orderDestination(), '/login');
      await cubit.close();
    });

    final cases = <Rol, String>{
      Rol.cliente: '/cliente/pedidos',
      Rol.mesero: '/mesas',
      Rol.admin: '/mesas',
      Rol.cocina: '/mesas',
    };
    for (final entry in cases.entries) {
      test('${entry.key.name} goes to ${entry.value}', () async {
        when(() => auth.me()).thenAnswer((_) async => authUser(rol: entry.key));
        final cubit = build();
        expect(await cubit.orderDestination(), entry.value);
        await cubit.close();
      });
    }
  });
}
