import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';

class _TestCrudCubit extends AdminCrudCubit<String> {
  _TestCrudCubit(super.changes);

  Future<List<String>> Function() fetcher = () async => ['a', 'b'];
  int fetchCalls = 0;

  @override
  Future<List<String>> fetch() {
    fetchCalls++;
    return fetcher();
  }
}

void main() {
  late AdminChanges changes;
  late List<void> notified;
  late StreamSubscription<void> subscription;

  setUp(() {
    changes = AdminChanges();
    notified = [];
    subscription = changes.stream.listen(notified.add);
  });

  tearDown(() => subscription.cancel());

  group('load', () {
    test('loads the items', () async {
      final cubit = _TestCrudCubit(changes);

      await cubit.load();

      expect(cubit.state.items, ['a', 'b']);
      expect(cubit.state.loading, isFalse);
      await cubit.close();
    });

    test('is loading while the request is pending', () async {
      final completer = Completer<List<String>>();
      final cubit = _TestCrudCubit(changes)..fetcher = () => completer.future;

      final future = cubit.load();
      expect(cubit.state.loading, isTrue);

      completer.complete(['x']);
      await future;
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.items, ['x']);
      await cubit.close();
    });

    test('an error ends loading and keeps the previous items', () async {
      final cubit = _TestCrudCubit(changes);
      await cubit.load();
      cubit.fetcher = () async => throw const ServerException();

      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.items, ['a', 'b']);
      expect(cubit.state.error, isNull);
      await cubit.close();
    });

    test('a response after close is ignored', () async {
      final completer = Completer<List<String>>();
      final cubit = _TestCrudCubit(changes)..fetcher = () => completer.future;

      final future = cubit.load();
      await cubit.close();
      completer.complete(['x']);

      await expectLater(future, completes);
    });
  });

  group('save', () {
    test('success clears submitting, notifies changes and reloads', () async {
      final cubit = _TestCrudCubit(changes);

      final ok = await cubit.save(() async {}, fallback: 'Error');
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(cubit.state.submitting, isFalse);
      expect(cubit.fetchCalls, 1);
      expect(notified, hasLength(1));
      await cubit.close();
    });

    test('is submitting while pending and ignores a second save', () async {
      final completer = Completer<void>();
      final cubit = _TestCrudCubit(changes);
      var calls = 0;

      final future = cubit.save(() {
        calls++;
        return completer.future;
      }, fallback: 'Error');
      expect(cubit.state.submitting, isTrue);
      expect(await cubit.save(() async => calls++, fallback: 'Error'), isFalse);

      completer.complete();
      await future;
      expect(calls, 1);
      await cubit.close();
    });

    test('an error reports the backend message and does not notify', () async {
      final cubit = _TestCrudCubit(changes);

      final ok = await cubit.save(
        () async => throw const BadRequestException('Nombre duplicado'),
        fallback: 'Error al guardar',
      );
      await pumpEventQueue();

      expect(ok, isFalse);
      expect(cubit.state.submitting, isFalse);
      expect(cubit.state.error!.message, 'Nombre duplicado');
      expect(notified, isEmpty);
      expect(cubit.fetchCalls, 0);
      await cubit.close();
    });

    test('an error without message uses the fallback', () async {
      final cubit = _TestCrudCubit(changes);

      await cubit.save(
        () async => throw const BadRequestException(' '),
        fallback: 'Error al guardar',
      );

      expect(cubit.state.error!.message, 'Error al guardar');
      await cubit.close();
    });
  });

  group('run', () {
    test('success notifies changes and reloads before completing', () async {
      final cubit = _TestCrudCubit(changes);

      final ok = await cubit.run(() async {}, fallback: 'Error');
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(cubit.fetchCalls, 1);
      expect(notified, hasLength(1));
      await cubit.close();
    });

    test('an error reports the fallback when the message is blank', () async {
      final cubit = _TestCrudCubit(changes);

      final ok = await cubit.run(
        () async => throw const ServerException(''),
        fallback: 'Error al eliminar',
      );

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al eliminar');
      await cubit.close();
    });
  });

  test('reject reports a validation message with a new id each time', () async {
    final cubit = _TestCrudCubit(changes)..reject('Ingresa un nombre');
    final first = cubit.state.error!;

    cubit.reject('Ingresa un nombre');

    expect(cubit.state.error!.message, 'Ingresa un nombre');
    expect(cubit.state.error, isNot(first));
    await cubit.close();
  });
}
