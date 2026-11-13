import 'package:itsqmet_mobile_pos/data/domain/domain.dart';

AuthUser authUser({
  String uuid = 'u-1',
  String nombre = 'Ana',
  String apellido = 'Pérez',
  String email = 'ana@itsqmet.edu.ec',
  Rol rol = Rol.mesero,
  bool activo = true,
}) => AuthUser(
  uuid: uuid,
  nombre: nombre,
  apellido: apellido,
  email: email,
  rol: rol,
  activo: activo,
);

CategoriaPlato categoriaFixture({
  int id = 1,
  String nombre = 'Entradas',
  AreaImpresion areaImpresion = AreaImpresion.cocina,
  int? ordenVisual = 1,
  DateTime? createdAt,
}) => CategoriaPlato(
  id: id,
  nombre: nombre,
  areaImpresion: areaImpresion,
  ordenVisual: ordenVisual,
  createdAt: createdAt,
);

Plato platoFixture({
  int id = 10,
  int idCategoria = 1,
  String? nombreCategoria = 'Entradas',
  String nombre = 'Ceviche',
  String? descripcion = 'Con limón',
  double precioUnitario = 8.5,
  bool aplicaIva = true,
  bool disponible = true,
  String? urlImagen,
  DateTime? createdAt,
}) => Plato(
  id: id,
  idCategoria: idCategoria,
  nombreCategoria: nombreCategoria,
  nombre: nombre,
  descripcion: descripcion,
  precioUnitario: precioUnitario,
  aplicaIva: aplicaIva,
  disponible: disponible,
  urlImagen: urlImagen,
  createdAt: createdAt,
);

Mesa mesaFixture({
  int id = 3,
  int numeroMesa = 3,
  int capacidad = 4,
  String? ubicacion = 'Terraza',
  EstadoMesa estado = EstadoMesa.libre,
  DateTime? createdAt,
}) => Mesa(
  id: id,
  numeroMesa: numeroMesa,
  capacidad: capacidad,
  ubicacion: ubicacion,
  estado: estado,
  createdAt: createdAt,
);

DetallePedido detalleFixture({
  int? id = 100,
  int? idPedido = 50,
  int idPlato = 10,
  String nombrePlato = 'Ceviche',
  int cantidad = 2,
  double precioUnitario = 8.5,
  double subtotal = 17,
  String? notasPreparacion,
  EstadoDetallePedido estado = EstadoDetallePedido.pendiente,
}) => DetallePedido(
  id: id,
  idPedido: idPedido,
  idPlato: idPlato,
  nombrePlato: nombrePlato,
  cantidad: cantidad,
  precioUnitario: precioUnitario,
  subtotal: subtotal,
  notasPreparacion: notasPreparacion,
  estado: estado,
);

Pedido pedidoFixture({
  int id = 50,
  int? idMesa = 3,
  int? numeroMesa = 3,
  List<DetallePedido>? detalles,
  EstadoPedido estado = EstadoPedido.abierto,
  TipoPedido tipo = TipoPedido.salon,
}) => Pedido(
  id: id,
  idMesa: idMesa,
  numeroMesa: numeroMesa,
  idUsuario: 'u-1',
  nombreUsuario: 'Ana Pérez',
  estado: estado,
  tipo: tipo,
  detalles: detalles ?? [detalleFixture()],
);

Factura facturaFixture({
  int id = 7,
  int idPedido = 50,
  double total = 20,
  EstadoFactura estado = EstadoFactura.emitida,
}) => Factura(
  id: id,
  idPedido: idPedido,
  numeroSecuencial: '001-001-000000007',
  subtotal: 17,
  subtotalIva: 2.55,
  propina: 0.45,
  total: total,
  estado: estado,
);

Pago pagoFixture({
  int id = 9,
  int idFactura = 7,
  MetodoPago metodoPago = MetodoPago.efectivo,
  double monto = 20,
}) => Pago(id: id, idFactura: idFactura, metodoPago: metodoPago, monto: monto);

Usuario usuarioFixture({
  String uuid = 'u-1',
  bool activo = true,
  Rol rol = Rol.mesero,
}) => Usuario(
  uuid: uuid,
  nombre: 'Ana',
  apellido: 'Pérez',
  cedula: '1712345678',
  email: 'ana@itsqmet.edu.ec',
  rol: rol,
  activo: activo,
);

Cliente clienteFixture({
  String uuid = 'c-1',
  String razonSocial = 'Juan Cliente',
}) => Cliente(
  uuid: uuid,
  tipoIdentificacion: TipoIdentificacion.cedula,
  identificacion: '1712345678',
  razonSocial: razonSocial,
);

Insumo insumoFixture({
  int id = 4,
  double stockActual = 10,
  double stockMinimo = 5,
  bool stockBajo = false,
}) => Insumo(
  id: id,
  nombre: 'Arroz',
  unidadMedida: UnidadMedida.kg,
  stockActual: stockActual,
  stockMinimo: stockMinimo,
  costoPromedio: 1.2,
  stockBajo: stockBajo,
);

Distribuidor distribuidorFixture({int id = 2, String ruc = '1790012345001'}) =>
    Distribuidor(id: id, ruc: ruc, razonSocial: 'Distribuidora S.A.');
