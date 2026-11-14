import 'dart:async';
import 'dart:convert';

import 'package:itsqmet_mobile_pos/config/constants/app_environment.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/paquete_sorpresa.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/pedido.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/paquete_sorpresa_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/pedido_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/paquete_sorpresa_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime_service.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime_topics.dart';
import 'package:itsqmet_mobile_pos/services/realtime/stomp_client_adapter.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompRealtimeService extends RealtimeService {
  StompRealtimeService({this.url, StompClientFactory? clientFactory})
    : _clientFactory = clientFactory ?? DefaultStompClientAdapter.new;

  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration heartbeat = Duration(seconds: 4);

  final String? url;
  final StompClientFactory _clientFactory;
  final Map<String, StreamController<Pedido>> _controllers = {};
  final Map<String, StreamController<PaqueteSorpresa>> _paqueteControllers = {};
  int _users = 0;
  int _generation = 0;
  final Map<String, StompUnsubscribe> _subscriptions = {};

  StompClientAdapter? _client;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  void connect() {
    _users++;
    if (_client != null) return;
    final generation = ++_generation;
    bool current() => generation == _generation;
    final client = _clientFactory(
      StompConfig(
        url: url ?? AppEnvironment.wsUrl,
        reconnectDelay: reconnectDelay,
        heartbeatIncoming: heartbeat,
        heartbeatOutgoing: heartbeat,
        onConnect: (frame) {
          if (current()) _onConnect(frame);
        },
        onDisconnect: (_) {
          if (current()) _onConnectionLost();
        },
        onWebSocketDone: () {
          if (current()) _onConnectionLost();
        },
        onWebSocketError: (_) {
          if (current()) _onConnectionLost();
        },
      ),
    );
    _client = client;
    client.activate();
  }

  @override
  Future<void> disconnect() async {
    if (_users > 0) _users--;
    if (_users > 0) return;
    final client = _client;
    if (client != null && _connected) {
      for (final unsubscribe in _subscriptions.values) {
        try {
          unsubscribe();
        } catch (_) {}
      }
    }
    _subscriptions.clear();
    _client = null;
    _connected = false;
    client?.deactivate();
    final controllers = [..._controllers.values];
    final paqueteControllers = [..._paqueteControllers.values];
    _controllers.clear();
    _paqueteControllers.clear();
    await Future.wait([
      ...controllers.map((controller) => controller.close()),
      ...paqueteControllers.map((controller) => controller.close()),
    ]);
  }

  @override
  Stream<Pedido> watch(String topic) {
    final existing = _controllers[topic];
    if (existing != null) return existing.stream;
    final controller = StreamController<Pedido>.broadcast();
    _controllers[topic] = controller;
    if (_connected) _subscribe(topic);
    return controller.stream;
  }

  @override
  Stream<PaqueteSorpresa> watchPaquetes([
    String topic = RealtimeTopics.paquetesSorpresa,
  ]) {
    final existing = _paqueteControllers[topic];
    if (existing != null) return existing.stream;
    final controller = StreamController<PaqueteSorpresa>.broadcast();
    _paqueteControllers[topic] = controller;
    if (_connected) _subscribe(topic);
    return controller.stream;
  }

  void _onConnect(StompFrame frame) {
    _connected = true;
    _subscriptions.clear();
    final topics = <String>{..._controllers.keys, ..._paqueteControllers.keys};
    for (final topic in topics) {
      _subscribe(topic);
    }
  }

  void _onConnectionLost() {
    _connected = false;
    _subscriptions.clear();
  }

  void _subscribe(String topic) {
    final client = _client;
    if (client == null) return;
    _subscriptions[topic] = client.subscribe(
      destination: topic,
      callback: (frame) => _handleFrame(topic, frame),
    );
  }

  void _handleFrame(String topic, StompFrame frame) {
    final pedidoController = _controllers[topic];
    if (pedidoController != null && !pedidoController.isClosed) {
      final pedido = _parse(frame.body);
      if (pedido != null) pedidoController.add(pedido);
    }

    final paqueteController = _paqueteControllers[topic];
    if (paqueteController != null && !paqueteController.isClosed) {
      final paquete = _parsePaquete(frame.body);
      if (paquete != null) paqueteController.add(paquete);
    }
  }

  Pedido? _parse(String? body) {
    if (body == null || body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return PedidoMapper.toEntity(PedidoModel.fromJson(decoded));
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  PaqueteSorpresa? _parsePaquete(String? body) {
    if (body == null || body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return PaqueteSorpresaMapper.toEntity(
        PaqueteSorpresaModel.fromJson(decoded),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
