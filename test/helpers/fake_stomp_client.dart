import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class FakeStompClient extends Fake implements StompClientAdapter {
  FakeStompClient(this.config);

  final StompConfig config;
  int activateCalls = 0;
  int deactivateCalls = 0;
  bool isConnected = false;
  final Map<String, StompFrameCallback> callbacks = {};
  final List<String> subscribeCalls = [];
  final List<String> unsubscribed = [];

  @override
  bool get connected => isConnected;

  @override
  void activate() => activateCalls++;

  @override
  void deactivate() {
    deactivateCalls++;
    isConnected = false;
  }

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
  }) {
    subscribeCalls.add(destination);
    callbacks[destination] = callback;
    return ({Map<String, String>? unsubscribeHeaders}) {
      unsubscribed.add(destination);
      callbacks.remove(destination);
    };
  }

  void simulateConnect() {
    isConnected = true;
    config.onConnect(StompFrame(command: 'CONNECTED'));
  }

  void simulateDrop() {
    isConnected = false;
    callbacks.clear();
    config.onWebSocketDone();
  }

  void emit(String destination, String? body) {
    callbacks[destination]!(
      StompFrame(
        command: 'MESSAGE',
        headers: {'destination': destination},
        body: body,
      ),
    );
  }
}

Map<String, dynamic> pedidoJson({
  int id = 7,
  String estado = 'ABIERTO',
  String tipo = 'SALON',
  int? numeroMesa = 5,
}) => {
  'id': id,
  'idMesa': 3,
  'numeroMesa': numeroMesa,
  'estado': estado,
  'tipo': tipo,
  'fechaApertura': '2026-11-13T10:15:00',
  'detalles': [
    {
      'id': 1,
      'idPedido': id,
      'idPlato': 10,
      'nombrePlato': 'Ceviche',
      'cantidad': 2,
      'precioUnitario': 8.5,
      'subtotal': 17.0,
      'estado': 'PENDIENTE',
    },
  ],
};
