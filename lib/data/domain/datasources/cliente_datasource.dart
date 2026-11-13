import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/cliente_model.dart';

abstract interface class ClienteDatasource {
  Future<PageResult<ClienteModel>> getClientes({int page = 0, int size = 100});

  Future<ClienteModel> getCliente(String uuid);

  Future<ClienteModel> getByIdentificacion(String identificacion);

  Future<PageResult<ClienteModel>> searchClientes(
    String filtro, {
    int page = 0,
    int size = 50,
  });

  Future<ClienteModel> createCliente(ClienteRequest request);

  Future<ClienteModel> updateCliente(String uuid, ClienteRequest request);

  Future<void> deleteCliente(String uuid);
}
