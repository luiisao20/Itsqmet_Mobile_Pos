import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
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

Map<String, dynamic> pedidoJson({int id = 7, String estado = 'ABIERTO'}) => {
  'id': id,
  'idMesa': 3,
  'numeroMesa': 5,
  'estado': estado,
  'tipo': 'SALON',
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

void main() {
  late List<FakeStompClient> clients;
  late StompRealtimeService service;

  FakeStompClient client() => clients.last;

  setUp(() {
    clients = [];
    service = StompRealtimeService(
      url: 'ws://pos.test/ws-pos',
      clientFactory: (config) {
        final fake = FakeStompClient(config);
        clients.add(fake);
        return fake;
      },
    );
  });

  tearDown(() => service.disconnect());

  group('configuration', () {
    test('uses the given url, reconnect 5s and heartbeat 4s in/out', () {
      service.connect();

      final config = client().config;
      expect(config.url, 'ws://pos.test/ws-pos');
      expect(config.useSockJS, isFalse);
      expect(config.reconnectDelay, const Duration(seconds: 5));
      expect(config.heartbeatIncoming, const Duration(seconds: 4));
      expect(config.heartbeatOutgoing, const Duration(seconds: 4));
      expect(StompRealtimeService.reconnectDelay, const Duration(seconds: 5));
      expect(StompRealtimeService.heartbeat, const Duration(seconds: 4));
    });

    test('falls back to AppEnvironment.wsUrl when no url is given', () {
      StompConfig? captured;
      final defaultService = StompRealtimeService(
        clientFactory: (config) {
          captured = config;
          return FakeStompClient(config);
        },
      );

      defaultService.connect();

      expect(captured!.url, AppEnvironment.wsUrl);
      expect(captured!.url, AppEnvironment.defaultWsUrl);
      defaultService.disconnect();
    });

    test('topics match the backend destinations', () {
      expect(RealtimeTopics.pedidos, '/topic/pedidos');
      expect(RealtimeTopics.cocina, '/topic/cocina');
    });
  });

  group('lifecycle', () {
    test('connect activates the client once even if called twice', () {
      service.connect();
      service.connect();

      expect(clients, hasLength(1));
      expect(client().activateCalls, 1);
    });

    test('isConnected follows the STOMP connection', () {
      expect(service.isConnected, isFalse);

      service.connect();
      expect(service.isConnected, isFalse);

      client().simulateConnect();
      expect(service.isConnected, isTrue);

      client().simulateDrop();
      expect(service.isConnected, isFalse);
    });

    test('disconnect unsubscribes, deactivates and closes streams', () async {
      service.connect();
      client().simulateConnect();
      final pedidosDone = expectLater(
        service.watch(RealtimeTopics.pedidos),
        emitsDone,
      );
      final cocinaDone = expectLater(service.cocina, emitsDone);
      final fake = client();

      await service.disconnect();

      await pedidosDone;
      await cocinaDone;
      expect(
        fake.unsubscribed,
        unorderedEquals(['/topic/pedidos', '/topic/cocina']),
      );
      expect(fake.deactivateCalls, 1);
      expect(service.isConnected, isFalse);
    });

    test('disconnect without connect completes', () async {
      await expectLater(service.disconnect(), completes);
    });

    test('connect after disconnect creates a new client', () async {
      service.connect();
      await service.disconnect();

      service.connect();

      expect(clients, hasLength(2));
      expect(client().activateCalls, 1);
    });
  });

  group('subscriptions', () {
    test('watch before connecting subscribes once connected', () {
      service.watch(RealtimeTopics.pedidos);
      service.connect();
      expect(client().subscribeCalls, isEmpty);

      client().simulateConnect();

      expect(client().subscribeCalls, ['/topic/pedidos']);
    });

    test('watch while connected subscribes immediately', () {
      service.connect();
      client().simulateConnect();

      service.watch(RealtimeTopics.cocina);

      expect(client().subscribeCalls, ['/topic/cocina']);
    });

    test('watching the same topic twice shares one subscription', () {
      service.connect();
      client().simulateConnect();

      final first = service.watch(RealtimeTopics.pedidos);
      final second = service.pedidos;

      expect(client().subscribeCalls, ['/topic/pedidos']);
      expect(first, second);
    });

    test('reconnect re-subscribes every watched topic', () {
      service.connect();
      service.watch(RealtimeTopics.pedidos);
      service.watch(RealtimeTopics.cocina);
      client().simulateConnect();

      client().simulateDrop();
      client().simulateConnect();

      expect(client().subscribeCalls, [
        '/topic/pedidos',
        '/topic/cocina',
        '/topic/pedidos',
        '/topic/cocina',
      ]);
    });

    test('messages after a reconnect still reach the stream', () async {
      service.connect();
      final stream = service.pedidos;
      client().simulateConnect();
      client().simulateDrop();
      client().simulateConnect();
      final next = stream.first;

      client().emit('/topic/pedidos', jsonEncode(pedidoJson(id: 99)));

      expect((await next).id, 99);
    });
  });

  group('payload parsing and routing', () {
    test(
      'parses a message into a Pedido through PedidoModel and PedidoMapper',
      () async {
        service.connect();
        client().simulateConnect();
        final next = service.pedidos.first;

        client().emit(
          '/topic/pedidos',
          jsonEncode(pedidoJson(id: 7, estado: 'EN_PREPARACION')),
        );

        final pedido = await next;
        expect(pedido.id, 7);
        expect(pedido.numeroMesa, 5);
        expect(pedido.estado, EstadoPedido.enPreparacion);
        expect(pedido.tipo, TipoPedido.salon);
        expect(pedido.detalles.single.nombrePlato, 'Ceviche');
        expect(pedido.detalles.single.cantidad, 2);
        expect(pedido.fechaApertura, DateTime(2026, 11, 13, 10, 15));
      },
    );

    test('routes each message only to the stream of its topic', () async {
      service.connect();
      client().simulateConnect();
      final pedidos = <int>[];
      final cocina = <int>[];
      final subA = service.pedidos.listen((p) => pedidos.add(p.id));
      final subB = service.cocina.listen((p) => cocina.add(p.id));

      client().emit('/topic/pedidos', jsonEncode(pedidoJson(id: 1)));
      client().emit('/topic/cocina', jsonEncode(pedidoJson(id: 2)));
      client().emit('/topic/cocina', jsonEncode(pedidoJson(id: 3)));
      await pumpEventQueue();

      expect(pedidos, [1]);
      expect(cocina, [2, 3]);
      await subA.cancel();
      await subB.cancel();
    });

    test('ignores null, malformed and non-object payloads', () async {
      service.connect();
      client().simulateConnect();
      final received = <int>[];
      final errors = <Object>[];
      final sub = service.pedidos.listen(
        (p) => received.add(p.id),
        onError: errors.add,
      );

      client().emit('/topic/pedidos', null);
      client().emit('/topic/pedidos', 'not json');
      client().emit('/topic/pedidos', '[1, 2]');
      client().emit('/topic/pedidos', '"texto"');
      client().emit('/topic/pedidos', jsonEncode(pedidoJson(id: 4)));
      await pumpEventQueue();

      expect(received, [4]);
      expect(errors, isEmpty);
      await sub.cancel();
    });

    test(
      'streams are broadcast so several listeners receive the same Pedido',
      () async {
        service.connect();
        client().simulateConnect();
        final a = service.cocina.first;
        final b = service.cocina.first;

        client().emit('/topic/cocina', jsonEncode(pedidoJson(id: 12)));

        expect((await a).id, 12);
        expect((await b).id, 12);
      },
    );
  });

  test('StompRealtimeService is a RealtimeService', () {
    expect(service, isA<RealtimeService>());
    expect(service.pedidos, isA<Stream<Pedido>>());
  });
}
