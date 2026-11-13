import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';

void main() {
  test('notifyExpired emits to every listener (broadcast)', () async {
    final notifier = SessionExpiredNotifier();
    var first = 0;
    var second = 0;
    notifier.onExpired.listen((_) => first++);
    notifier.onExpired.listen((_) => second++);

    notifier.notifyExpired();
    notifier.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    expect(first, 2);
    expect(second, 2);
    notifier.dispose();
  });

  test('notifying without listeners does not throw', () {
    final notifier = SessionExpiredNotifier();

    expect(notifier.notifyExpired, returnsNormally);
    notifier.dispose();
  });

  test('notifying after dispose is a safe no-op', () {
    final notifier = SessionExpiredNotifier()..dispose();

    expect(notifier.notifyExpired, returnsNormally);
  });

  test('dispose completes the stream', () async {
    final notifier = SessionExpiredNotifier();
    final done = notifier.onExpired.toList();

    notifier.dispose();

    expect(await done, isEmpty);
  });
}
