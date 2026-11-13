import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/mappers.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final date = DateTime(2025, 11, 12, 10, 30);

  group('AuthMapper', () {
    test('toEntity maps the auth response to an AuthUser', () {
      const model = AuthResponseModel(
        uuid: 'u-1',
        nombre: 'Ana',
        apellido: 'Pérez',
        email: 'ana@itsqmet.edu.ec',
        rol: Rol.mesero,
        activo: true,
        message: 'ok',
      );

      expect(AuthMapper.toEntity(model), authUser());
    });

    test('fromEntity -> toEntity round-trips (session snapshot)', () {
      final user = authUser(rol: Rol.admin, activo: false);

      expect(AuthMapper.toEntity(AuthMapper.fromEntity(user)), user);
    });

    test('userToJson / userFromJson round-trip through plain JSON', () {
      final user = authUser(rol: Rol.cocina);

      expect(AuthMapper.userFromJson(AuthMapper.userToJson(user)), user);
    });
  });

  test('CategoriaPlatoMapper', () {
    final entity = CategoriaPlatoMapper.toEntity(
      CategoriaPlatoModel(
        id: 1,
        nombre: 'Entradas',
        areaImpresion: AreaImpresion.cocina,
        ordenVisual: 1,
        createdAt: date,
      ),
    );

    expect(entity, categoriaFixture(createdAt: date));
  });

  test('PlatoMapper', () {
    final entity = PlatoMapper.toEntity(
      PlatoModel(
        id: 10,
        idCategoria: 1,
        nombreCategoria: 'Entradas',
        nombre: 'Ceviche',
        descripcion: 'Con limón',
        precioUnitario: 8.5,
        aplicaIva: true,
        disponible: true,
        createdAt: date,
      ),
    );

    expect(entity, platoFixture(createdAt: date));
  });

  test('MesaMapper', () {
    final entity = MesaMapper.toEntity(
      MesaModel(
        id: 3,
        numeroMesa: 3,
        capacidad: 4,
        ubicacion: 'Terraza',
        estado: EstadoMesa.libre,
        createdAt: date,
      ),
    );

    expect(entity, mesaFixture(createdAt: date));
  });

  test('DetallePedidoMapper', () {
    const model = DetallePedidoModel(
      id: 100,
      idPedido: 50,
      idPlato: 10,
      nombrePlato: 'Ceviche',
      cantidad: 2,
      precioUnitario: 8.5,
      subtotal: 17,
      estado: EstadoDetallePedido.pendiente,
    );

    expect(DetallePedidoMapper.toEntity(model), detalleFixture());
  });

  test('PedidoMapper maps the nested lines', () {
    final entity = PedidoMapper.toEntity(
      const PedidoModel(
        id: 50,
        idMesa: 3,
        numeroMesa: 3,
        idUsuario: 'u-1',
        nombreUsuario: 'Ana Pérez',
        estado: EstadoPedido.abierto,
        tipo: TipoPedido.salon,
        detalles: [
          DetallePedidoModel(
            id: 100,
            idPedido: 50,
            idPlato: 10,
            nombrePlato: 'Ceviche',
            cantidad: 2,
            precioUnitario: 8.5,
            subtotal: 17,
            estado: EstadoDetallePedido.pendiente,
          ),
        ],
      ),
    );

    expect(entity, pedidoFixture());
    expect(entity.total, 17);
  });

  test('FacturaMapper', () {
    final entity = FacturaMapper.toEntity(
      const FacturaModel(
        id: 7,
        idPedido: 50,
        numeroSecuencial: '001-001-000000007',
        subtotal: 17,
        subtotalIva: 2.55,
        propina: 0.45,
        total: 20,
        estado: EstadoFactura.emitida,
      ),
    );

    expect(entity, facturaFixture());
  });

  test('PagoMapper', () {
    final entity = PagoMapper.toEntity(
      const PagoModel(
        id: 9,
        idFactura: 7,
        metodoPago: MetodoPago.efectivo,
        monto: 20,
      ),
    );

    expect(entity, pagoFixture());
  });

  test('UsuarioMapper', () {
    final entity = UsuarioMapper.toEntity(
      const UsuarioModel(
        uuid: 'u-1',
        nombre: 'Ana',
        apellido: 'Pérez',
        cedula: '1712345678',
        email: 'ana@itsqmet.edu.ec',
        rol: Rol.mesero,
        activo: true,
      ),
    );

    expect(entity, usuarioFixture());
  });

  test('ClienteMapper', () {
    final entity = ClienteMapper.toEntity(
      const ClienteModel(
        uuid: 'c-1',
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '1712345678',
        razonSocial: 'Juan Cliente',
      ),
    );

    expect(entity, clienteFixture());
  });

  group('InsumoMapper', () {
    InsumoModel model({bool? stockBajo, double actual = 10}) => InsumoModel(
      id: 4,
      nombre: 'Arroz',
      unidadMedida: UnidadMedida.kg,
      stockActual: actual,
      stockMinimo: 5,
      costoPromedio: 1.2,
      stockBajo: stockBajo,
    );

    test('keeps the backend stockBajo when present', () {
      expect(InsumoMapper.toEntity(model(stockBajo: false)), insumoFixture());
      expect(InsumoMapper.toEntity(model(stockBajo: true)).stockBajo, isTrue);
    });

    test('computes stockBajo (<= minimum) when the backend omits it', () {
      expect(InsumoMapper.toEntity(model(actual: 10)).stockBajo, isFalse);
      expect(InsumoMapper.toEntity(model(actual: 5)).stockBajo, isTrue);
      expect(InsumoMapper.toEntity(model(actual: 1)).stockBajo, isTrue);
    });
  });

  test('DistribuidorMapper', () {
    final entity = DistribuidorMapper.toEntity(
      const DistribuidorModel(
        id: 2,
        ruc: '1790012345001',
        razonSocial: 'Distribuidora S.A.',
      ),
    );

    expect(entity, distribuidorFixture());
  });
}
