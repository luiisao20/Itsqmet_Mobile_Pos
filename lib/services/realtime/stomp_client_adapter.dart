import 'package:stomp_dart_client/stomp_dart_client.dart';

abstract interface class StompClientAdapter {
  bool get connected;

  void activate();

  void deactivate();

  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
  });
}

typedef StompClientFactory = StompClientAdapter Function(StompConfig config);

class DefaultStompClientAdapter implements StompClientAdapter {
  DefaultStompClientAdapter(StompConfig config)
    : _client = StompClient(config: config);

  final StompClient _client;

  @override
  bool get connected => _client.connected;

  @override
  void activate() => _client.activate();

  @override
  void deactivate() => _client.deactivate();

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
  }) {
    return _client.subscribe(destination: destination, callback: callback);
  }
}
