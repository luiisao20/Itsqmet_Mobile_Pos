import 'package:itsqmet_mobile_pos/data/domain/entities/pedido.dart';
import 'package:itsqmet_mobile_pos/services/realtime/realtime_topics.dart';

abstract class RealtimeService {
  bool get isConnected;

  void connect();

  Future<void> disconnect();

  Stream<Pedido> watch(String topic);

  Stream<Pedido> get pedidos => watch(RealtimeTopics.pedidos);

  Stream<Pedido> get cocina => watch(RealtimeTopics.cocina);
}
