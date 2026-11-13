import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/cocina/cocina.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  late _MockAudioPlayer player;

  setUpAll(() => registerFallbackValue(AssetSource('fallback')));

  setUp(() {
    player = _MockAudioPlayer();
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.play(any())).thenAnswer((_) async {});
  });

  test('plays the bundled kitchen bell asset from the start', () async {
    await AudioplayersKitchenBell(player: player).ring();

    verifyInOrder([
      () => player.stop(),
      () => player.play(
        any(
          that: isA<AssetSource>().having(
            (source) => source.path,
            'path',
            'sounds/kitchen_bell.wav',
          ),
        ),
      ),
    ]);
  });

  test('an audio failure never reaches the caller', () async {
    when(() => player.play(any())).thenThrow(Exception('audio blocked'));

    await expectLater(
      AudioplayersKitchenBell(player: player).ring(),
      completes,
    );
  });
}
