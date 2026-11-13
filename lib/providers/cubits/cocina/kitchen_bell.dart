import 'package:audioplayers/audioplayers.dart';

abstract interface class KitchenBell {
  Future<void> ring();
}

class AudioplayersKitchenBell implements KitchenBell {
  AudioplayersKitchenBell({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  static const String asset = 'sounds/kitchen_bell.wav';

  final AudioPlayer _player;

  @override
  Future<void> ring() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } on Object {
      return;
    }
  }
}
