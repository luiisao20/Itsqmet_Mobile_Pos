import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/clientes_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/distribuidores_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/personal_tab.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_personas.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockUsuarios extends Mock implements UsuarioRepository {}

class _MockClientes extends Mock implements ClienteRepository {}

class _MockDistribuidores extends Mock implements DistribuidorRepository {}

const _ana = Usuario(
  uuid: 'u-1',
  nombre: 'Anastasia Maria',
  apellido: 'Paz Villacreses',
  cedula: '1700000001',
  email: 'anastasia.villacreses@restaurante.com',
  rol: Rol.cocina,
  activo: true,
);
const _cli = Cliente(
  uuid: 'c-1',
  tipoIdentificacion: TipoIdentificacion.consumidorFinal,
  identificacion: '9999999999999',
  razonSocial: 'Comercializadora Internacional del Pacifico S.A.',
  email: 'facturacion@comercializadora.com',
  telefono: '0999999999',
  direccion: 'Av. Amazonas',
);
const _dis = Distribuidor(
  id: 1,
  ruc: '1790000000001',
  razonSocial: 'Pronaca Procesadora Nacional de Alimentos C.A.',
  nombreContacto: 'Juan Perez',
  telefono: '022222222',
  email: 'ventas@pronaca.com',
  direccion: 'Quito',
  categoriaProveedor: 'Carnes, Lacteos, Abarrotes',
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  scaffoldMessengerKey: NotificationsService.messengerKey,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Finder _editable(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(EditableText),
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UsuarioDraft(
        nombre: '',
        apellido: '',
        cedula: '',
        email: '',
        rol: Rol.mesero,
        activo: true,
      ),
    );
    registerFallbackValue(
      const ClienteDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '',
        razonSocial: '',
      ),
    );
    registerFallbackValue(const DistribuidorDraft(ruc: '', razonSocial: ''));
  });

  for (final (device, size) in [
    ('phone', TestScreens.phone),
    ('tablet', TestScreens.tabletLandscape),
  ]) {
    testWidgets(
      'personal forms on $device keep passwords hidden and never resend a blank one',
      (tester) async {
        final repo = _MockUsuarios();
        when(() => repo.getUsuarios(page: 0, size: 100))
            .thenAnswer((_) async => PageResult.single(const [_ana]));
        when(() => repo.createUsuario(any())).thenAnswer((_) async => _ana);
        when(() => repo.updateUsuario(any(), any()))
            .thenAnswer((_) async => _ana);
        final cubit = AdminUsuariosCubit(
          usuarioRepository: repo,
          changes: AdminChanges(),
        );
        final req = StreamController<void>.broadcast();
        tester.setScreenSize(size);
        await cubit.load();
        await tester.pumpWidget(
          _app(
            BlocProvider.value(
              value: cubit,
              child: PersonalView(createRequests: req.stream),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        req.add(null);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<EditableText>(_editable('usuario.password'))
              .obscureText,
          isTrue,
        );
        await tester.enterText(
          find.byKey(const ValueKey('usuario.nombre')),
          'E',
        );
        await tester.enterText(
          find.byKey(const ValueKey('usuario.apellido')),
          'R',
        );
        await tester.enterText(
          find.byKey(const ValueKey('usuario.cedula')),
          '1',
        );
        await tester.enterText(
          find.byKey(const ValueKey('usuario.email')),
          'e@m',
        );
        await tester.enterText(
          find.byKey(const ValueKey('usuario.password')),
          'Secret99',
        );
        await tester.tap(find.text('Guardar Empleado'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final created =
            verify(() => repo.createUsuario(captureAny())).captured.single
                as UsuarioDraft;
        expect(created.password, 'Secret99');
        expect(
          find.textContaining('Secret99', findRichText: true),
          findsNothing,
        );

        await tester.ensureVisible(find.text('Editar').first);
        await tester.tap(find.text('Editar').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final pwd = tester.widget<EditableText>(_editable('usuario.password'));
        expect(pwd.controller.text, '');
        expect(pwd.obscureText, isTrue);
        await tester.enterText(
          find.byKey(const ValueKey('usuario.password')),
          '   ',
        );
        await tester.tap(find.text('Guardar Empleado'));
        await tester.pumpAndSettle();
        final upd =
            verify(() => repo.updateUsuario('u-1', captureAny()))
                    .captured
                    .single
                as UsuarioDraft;
        expect(upd.password, isNull);
        expect(upd.cedula, '1700000001');
        expect(upd.rol, Rol.cocina);
        await cubit.close();
        await req.close();
      },
    );

    testWidgets('clientes form on $device saves without credentials', (
      tester,
    ) async {
      final repo = _MockClientes();
      when(() => repo.getClientes(page: 0, size: 100))
          .thenAnswer((_) async => PageResult.single(const [_cli]));
      when(() => repo.updateCliente(any(), any()))
          .thenAnswer((_) async => _cli);
      final cubit = AdminClientesCubit(
        clienteRepository: repo,
        changes: AdminChanges(),
      );
      final req = StreamController<void>.broadcast();
      tester.setScreenSize(size);
      await cubit.load();
      await tester.pumpWidget(
        _app(
          BlocProvider.value(
            value: cubit,
            child: ClientesView(createRequests: req.stream),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Editar').first);
      await tester.tap(find.text('Editar').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Guardar Cliente'));
      await tester.pumpAndSettle();
      final d =
          verify(() => repo.updateCliente('c-1', captureAny())).captured.single
              as ClienteDraft;
      expect(d.password, isNull);
      expect(d.activo, isNull);
      expect(d.tipoIdentificacion, TipoIdentificacion.consumidorFinal);
      await cubit.close();
      await req.close();
    });

    testWidgets('distribuidores forms on $device open without overflow', (
      tester,
    ) async {
      final repo = _MockDistribuidores();
      when(() => repo.getDistribuidores(page: 0, size: 100))
          .thenAnswer((_) async => PageResult.single(const [_dis]));
      final cubit = DistribuidoresCubit(
        distribuidorRepository: repo,
        changes: AdminChanges(),
      );
      final req = StreamController<void>.broadcast();
      tester.setScreenSize(size);
      await cubit.load();
      await tester.pumpWidget(
        _app(
          BlocProvider.value(
            value: cubit,
            child: DistribuidoresView(createRequests: req.stream),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Editar').first);
      await tester.tap(find.text('Editar').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      req.add(null);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await cubit.close();
      await req.close();
    });
  }
}
