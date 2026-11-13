import 'package:itsqmet_mobile_pos/data/domain/entities/cliente.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';

abstract interface class ClienteRepository {
  Future<PageResult<Cliente>> getClientes({int page = 0, int size = 100});

  Future<Cliente> getCliente(String uuid);

  Future<Cliente> getByIdentificacion(String identificacion);

  Future<PageResult<Cliente>> searchClientes(
    String filtro, {
    int page = 0,
    int size = 50,
  });

  Future<Cliente> createCliente(ClienteDraft draft);

  Future<Cliente> updateCliente(String uuid, ClienteDraft draft);

  Future<void> deleteCliente(String uuid);
}
