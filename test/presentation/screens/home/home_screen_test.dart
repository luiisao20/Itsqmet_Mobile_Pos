import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/feedback/skeleton_box.dart';
import 'package:itsqmet_mobile_pos/services/locator/home_locator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

class _MockCatalogoRepository extends Mock implements CatalogoRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockCatalogoRepository catalogo;
  late _MockAuthRepository auth;

  final entradas = categoriaFixture(id: 1, nombre: 'Entradas');
  final fondos = categoriaFixture(id: 2, nombre: 'Fondos');
  final ceviche = platoFixture(id: 10, nombre: 'Ceviche');
  final seco = platoFixture(id: 11, nombre: 'Seco de pollo', idCategoria: 2);

  setUp(() {
    catalogo = _MockCatalogoRepository();
    auth = _MockAuthRepository();
    GetIt.instance
      ..registerSingleton<CatalogoRepository>(catalogo)
      ..registerSingleton<AuthRepository>(auth);
    registerHomeDependencies(GetIt.instance);

    when(() => catalogo.getCategorias())
        .thenAnswer((_) async => [entradas, fondos]);
    when(() => catalogo.getPlatos(size: 50))
        .thenAnswer((_) async => PageResult.single([ceviche, seco]));
    when(() => auth.me()).thenThrow(const UnauthorizedException());
  });

  tearDown(() => GetIt.instance.reset());

  Future<GoRouter> pumpHome(
    WidgetTester tester, {
    Size size = TestScreens.phone,
    bool settle = true,
  }) async {
    tester.setScreenSize(size);
    Widget stub(GoRouterState state) =>
        Scaffold(body: Text('route:${state.uri}'));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: HomeScreen()),
        ),
        GoRoute(path: '/login', builder: (_, state) => stub(state)),
        GoRoute(path: '/mesas', builder: (_, state) => stub(state)),
        GoRoute(path: '/cliente/pedidos', builder: (_, state) => stub(state)),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    if (settle) await tester.pumpAndSettle();
    return router;
  }

  Finder richText(String text) => find.textContaining(text, findRichText: true);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('renders the hero, the category pills and the platos', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Experiencia Gastronómica & Pedidos Online'), findsOne);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    expect(richText('Sabores Auténticos,'), findsOneWidget);
    expect(richText('Preparados al Momento.'), findsOneWidget);
    expect(
      find.text(
        'Explora nuestro menú artesanal. Pide directamente para llevar o disfruta en nuestro salón atendido por nuestro equipo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Realizar Pedido para Llevar'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

    expect(find.text('Todos los Platos'), findsOneWidget);
    expect(find.text('Entradas'), findsWidgets);
    expect(find.text('Fondos'), findsOneWidget);
    expect(find.text('Buscar plato o ingrediente...'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    expect(find.byType(PlatoCard), findsNWidgets(2));
    expect(find.text('Ceviche'), findsOneWidget);
    expect(find.text('Seco de pollo'), findsOneWidget);
  });

  testWidgets('shows 8 skeleton cards while the platos load', (tester) async {
    final pending = Completer<PageResult<Plato>>();
    when(() => catalogo.getPlatos(size: 50)).thenAnswer((_) => pending.future);

    await pumpHome(tester, settle: false);
    await tester.pump();

    expect(find.byKey(const ValueKey('home-skeleton-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-skeleton-card')), findsNWidgets(8));
    expect(find.byType(SkeletonBox), findsNWidgets(24));
    expect(find.byType(PlatoCard), findsNothing);

    pending.complete(PageResult.single([ceviche]));
    await tester.pumpAndSettle();

    expect(find.byType(PlatoCard), findsOneWidget);
  });

  testWidgets('uses the web columns while cards are at least 256 wide', (
    tester,
  ) async {
    final expected = <double, int>{
      390: 1,
      700: 2,
      800: 2,
      900: 3,
      1024: 3,
      1200: 4,
    };
    for (final entry in expected.entries) {
      await pumpHome(tester, size: Size(entry.key, 900));
      final grid = tester.widget<GridView>(
        find.byKey(const ValueKey('home-platos-grid')),
      );
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, entry.value, reason: '${entry.key}');
      expect(delegate.crossAxisSpacing, 24);
      expect(delegate.mainAxisSpacing, 24);
      expect(tester.takeException(), isNull, reason: '${entry.key}');
    }
  });

  testWidgets('selecting a category loads its platos', (tester) async {
    when(() => catalogo.getPlatosByCategoria(2, size: 50))
        .thenAnswer((_) async => PageResult.single([seco]));
    await pumpHome(tester);

    await tapVisible(tester, find.text('Fondos'));

    verify(() => catalogo.getPlatosByCategoria(2, size: 50)).called(1);
    expect(find.byType(PlatoCard), findsOneWidget);
    expect(find.text('Seco de pollo'), findsOneWidget);
  });

  testWidgets('submitting the search queries the backend', (tester) async {
    when(() => catalogo.searchPlatos(nombre: 'cev'))
        .thenAnswer((_) async => PageResult.single([ceviche]));
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), ' cev ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    verify(() => catalogo.searchPlatos(nombre: 'cev')).called(1);
    expect(find.byType(PlatoCard), findsOneWidget);
  });

  testWidgets('selecting a category clears the search field', (tester) async {
    when(() => catalogo.getPlatosByCategoria(1, size: 50))
        .thenAnswer((_) async => PageResult.single([ceviche]));
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'cev');
    await tester.pump();
    await tapVisible(tester, find.text('Entradas').first);

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('shows the empty state and resets the filter from it', (
    tester,
  ) async {
    when(() => catalogo.getPlatos(size: 50))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpHome(tester);

    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.text('No se encontraron platos'), findsOneWidget);
    expect(
      find.text(
        'Prueba buscando con otro término o selecciona otra categoría.',
      ),
      findsOneWidget,
    );

    await tapVisible(tester, find.text('Ver todos los platos'));

    verify(() => catalogo.getPlatos(size: 50)).called(2);
  });

  testWidgets('adding a plato without session goes to login', (tester) async {
    await pumpHome(tester);

    await tapVisible(tester, find.text('+ Agregar').first);

    expect(
      find.text('route:/login?returnUrl=%2Fcliente%2Fpedidos'),
      findsOneWidget,
    );
  });

  testWidgets('adding a plato as mesero goes to mesas', (tester) async {
    when(() => auth.me()).thenAnswer((_) async => authUser(rol: Rol.mesero));
    await pumpHome(tester);

    await tapVisible(tester, find.text('+ Agregar').first);

    expect(find.text('route:/mesas'), findsOneWidget);
  });

  testWidgets('adding a plato as cocina stays on home', (tester) async {
    when(() => auth.me()).thenAnswer((_) async => authUser(rol: Rol.cocina));
    await pumpHome(tester);

    await tapVisible(tester, find.text('+ Agregar').first);

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('ordering as cliente goes to cliente pedidos', (tester) async {
    when(() => auth.me()).thenAnswer((_) async => authUser(rol: Rol.cliente));
    await pumpHome(tester);

    await tester.tap(find.text('Realizar Pedido para Llevar'));
    await tester.pumpAndSettle();

    expect(find.text('route:/cliente/pedidos'), findsOneWidget);
  });

  testWidgets('ordering without session goes to login', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Realizar Pedido para Llevar'));
    await tester.pumpAndSettle();

    expect(find.text('route:/login'), findsOneWidget);
  });

  testWidgets('renders without overflow on tablet landscape', (tester) async {
    await pumpHome(tester, size: TestScreens.tabletLandscape);

    expect(tester.takeException(), isNull);
    expect(find.byType(PlatoCard), findsNWidgets(2));
  });
}
