import 'package:drift/drift.dart' as drift;
import '../database/drift_database.dart';

/// 🚀 SERVICIO DE BASE DE DATOS CON DRIFT
///
/// Este servicio es un wrapper sobre AppDatabase (Drift)
/// para facilitar el uso en toda la aplicación.
///
/// VENTAJAS DE DRIFT:
/// - ✅ Type-safe (detecta errores en tiempo de compilación)
/// - ✅ Autocompletado en IDE
/// - ✅ Generación automática de código
/// - ✅ Streams reactivos
/// - ✅ Migraciones automáticas

class DriftService {
  /// ✅ Crear un nuevo rol en la base de datos
  ///
  /// Recibe los datos del rol y los inserta en la tabla Roles.
  Future<int> crearRol({
    required String id,
    required String nombre,
    required String descripcion,
    required String permisos,
    bool accesoTodosModulos = false,
    bool informacionTiempoReal = false,
    bool accesoInventarios = false,
    bool accesoPuntoVenta = false,
    bool accesoConsultas = false,
    bool accesoReportes = false,
    bool gestionCantidades = false,
    bool gestionPrecios = false,
    bool activo = true,
  }) async {
    return await _db
        .into(_db.roles)
        .insert(
          RolesCompanion(
            id: drift.Value(id),
            nombre: drift.Value(nombre),
            descripcion: drift.Value(descripcion),
            permisos: drift.Value(permisos),
            accesoTodosModulos: drift.Value(accesoTodosModulos),
            informacionTiempoReal: drift.Value(informacionTiempoReal),
            accesoInventarios: drift.Value(accesoInventarios),
            accesoPuntoVenta: drift.Value(accesoPuntoVenta),
            accesoConsultas: drift.Value(accesoConsultas),
            accesoReportes: drift.Value(accesoReportes),
            gestionCantidades: drift.Value(gestionCantidades),
            gestionPrecios: drift.Value(gestionPrecios),
            activo: drift.Value(activo),
            fechaCreacion: drift.Value(DateTime.now()),
          ),
        );
  }

  // 🔒 Singleton pattern
  static final DriftService _instance = DriftService._internal();
  factory DriftService() => _instance;
  DriftService._internal();

  // 💾 Instancia de la base de datos
  final AppDatabase _db = AppDatabase();

  /// Obtiene la instancia de la base de datos
  AppDatabase get database => _db;

  /// 🔍 Contar referencias maestras
  Future<int> contarReferenciasMaestras() async {
    final total = await _db
        .customSelect('SELECT COUNT(*) AS total FROM referencias_maestras')
        .getSingleOrNull();
    return total != null ? total.data['total'] as int : 0;
  }

  /// ➕ Insertar referencias maestras en lote
  Future<void> insertarReferenciasMaestrasLote(
    List<ReferenciasMaestrasCompanion> referencias,
  ) async {
    for (final ref in referencias) {
      await _db.into(_db.referenciasMaestras).insert(ref);
    }
  }

  /// 🔍 Buscar referencia maestra por código
  Future<ReferenciasMaestra?> buscarReferenciaMaestraPorCodigo(
    String codRef,
  ) async {
    return await (_db.select(
      _db.referenciasMaestras,
    )..where((tbl) => tbl.codRef.equals(codRef))).getSingleOrNull();
  }

  /// 📖 Obtener todos los roles
  Future<List<Role>> obtenerRoles() => _db.obtenerRoles();

  /// 🔍 Buscar rol por ID
  Future<Role?> obtenerRolPorId(String id) => _db.obtenerRolPorId(id);

  /// 🔍 Obtener roles activos
  Future<List<Role>> obtenerRolesActivos() => _db.obtenerRolesActivos();

  /// ✏️ Actualizar rol
  Future<bool> actualizarRol(Role rol) => _db.actualizarRol(rol);

  /// 🗑️ Eliminar rol
  Future<int> eliminarRol(String id) => _db.eliminarRol(id);

  /// 👀 Stream de roles
  Stream<List<Role>> watchRoles() => _db.watchRoles();

  // ==================== LOCALES ====================

  /// 📝 Crear local
  Future<int> crearLocal({
    required String id,
    required String nombre,
    required String tipo, // "tienda" o "bodega"
    String? direccion,
    String? telefono,
    String? ciudad,
    bool activo = true,
  }) async {
    final local = LocalesCompanion(
      id: drift.Value(id),
      nombre: drift.Value(nombre),
      tipo: drift.Value(tipo),
      direccion: drift.Value(direccion),
      telefono: drift.Value(telefono),
      ciudad: drift.Value(ciudad),
      activo: drift.Value(activo),
      fechaCreacion: drift.Value(DateTime.now()),
    );

    return await _db.crearLocal(local);
  }

  /// 📖 Obtener todos los locales
  Future<List<Locale>> obtenerLocales() => _db.obtenerLocales();

  /// 🔍 Buscar local por ID
  Future<Locale?> obtenerLocalPorId(String id) => _db.obtenerLocalPorId(id);

  /// 🏪 Obtener locales activos
  Future<List<Locale>> obtenerLocalesActivos() => _db.obtenerLocalesActivos();

  /// 🏪 Obtener locales por tipo
  Future<List<Locale>> obtenerLocalesPorTipo(String tipo) =>
      _db.obtenerLocalesPorTipo(tipo);

  /// ✏️ Actualizar local
  Future<bool> actualizarLocal(Locale local) => _db.actualizarLocal(local);

  /// 🗑️ Eliminar local
  Future<int> eliminarLocal(String id) => _db.eliminarLocal(id);

  /// 👀 Stream de locales
  Stream<List<Locale>> watchLocales() => _db.watchLocales();

  // ==================== USUARIOS ====================

  /// 📝 Crear usuario
  Future<int> crearUsuario({
    required String cedula,
    required String nombresApellidos,
    required String nombreUsuario,
    String? telefono,
    required String contrasena, // Hash de contraseña
    required String rolId,
    required String localAsignado, // LC_01, BD_01, etc.
    required String codigo,
    bool activo = true,
  }) async {
    final usuario = UsuariosCompanion(
      cedula: drift.Value(cedula),
      nombresApellidos: drift.Value(nombresApellidos),
      nombreUsuario: drift.Value(nombreUsuario),
      telefono: drift.Value(telefono),
      contrasena: drift.Value(contrasena),
      rolId: drift.Value(rolId),
      localAsignado: drift.Value(localAsignado),
      codigo: drift.Value(codigo),
      activo: drift.Value(activo),
      fechaCreacion: drift.Value(DateTime.now()),
    );

    return await _db.crearUsuario(usuario);
  }

  /// 📖 Obtener todos los usuarios
  Future<List<Usuario>> obtenerUsuarios() => _db.obtenerUsuarios();

  /// 🔍 Buscar usuario por cédula (PK)
  Future<Usuario?> obtenerUsuarioPorCedula(String cedula) =>
      _db.obtenerUsuarioPorCedula(cedula);

  /// 🔍 Buscar usuario por nombre de usuario
  Future<Usuario?> obtenerUsuarioPorNombreUsuario(String nombreUsuario) =>
      _db.obtenerUsuarioPorNombreUsuario(nombreUsuario);

  /// 🔍 Obtener usuarios por rol
  Future<List<Usuario>> obtenerUsuariosPorRol(String rolId) =>
      _db.obtenerUsuariosPorRol(rolId);

  /// 🔍 Obtener usuarios activos
  Future<List<Usuario>> obtenerUsuariosActivos() =>
      _db.obtenerUsuariosActivos();

  /// 🔍 Obtener usuarios por local asignado
  Future<List<Usuario>> obtenerUsuariosPorLocal(String localId) =>
      _db.obtenerUsuariosPorLocal(localId);

  /// 🔍 Buscar usuarios por texto
  Future<List<Usuario>> buscarUsuarios(String texto) =>
      _db.buscarUsuarios(texto);

  /// ✏️ Actualizar usuario
  Future<bool> actualizarUsuario(Usuario usuario) =>
      _db.actualizarUsuario(usuario);

  /// ✏️ Actualizar usuario parcialmente (por mapa de cambios)
  Future<int> actualizarUsuarioParcial(
    String cedula,
    Map<String, dynamic> cambios,
  ) => _db.actualizarUsuarioParcial(cedula, cambios);

  /// 🗑️ Eliminar usuario por cédula
  Future<int> eliminarUsuario(String cedula) => _db.eliminarUsuario(cedula);

  /// 🔐 Validar login
  Future<Usuario?> validarLogin(String nombreUsuario, String contrasenaHash) =>
      _db.validarLogin(nombreUsuario, contrasenaHash);

  /// 📊 Contar usuarios activos
  Future<int> contarUsuariosActivos() => _db.contarUsuariosActivos();

  /// 👀 Stream de usuarios (actualización en tiempo real)
  Stream<List<Usuario>> watchUsuarios() => _db.watchUsuarios();

  // ==================== PRODUCTOS ====================

  /// 📝 Crear producto
  Future<int> crearProducto({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String categoria,
    required double precio,
    int stock = 0,
    int stockMinimo = 10,
    required String tiendaId,
    bool activo = true,
  }) async {
    final producto = ProductosCompanion(
      id: drift.Value(id),
      codigo: drift.Value(codigo),
      nombre: drift.Value(nombre),
      descripcion: drift.Value(descripcion),
      categoria: drift.Value(categoria),
      precio: drift.Value(precio),
      stock: drift.Value(stock),
      stockMinimo: drift.Value(stockMinimo),
      tiendaId: drift.Value(tiendaId),
      activo: drift.Value(activo),
      fechaCreacion: drift.Value(DateTime.now()),
    );

    return await _db.crearProducto(producto);
  }

  /// 📖 Obtener todos los productos
  Future<List<Producto>> obtenerProductos() => _db.obtenerProductos();

  /// 🔍 Buscar producto por código
  Future<Producto?> obtenerProductoPorCodigo(String codigo) =>
      _db.obtenerProductoPorCodigo(codigo);

  /// 🔍 Productos con stock bajo
  Future<List<Producto>> obtenerProductosStockBajo() =>
      _db.obtenerProductosStockBajo();

  /// ✏️ Actualizar stock
  Future<int> actualizarStockProducto(String id, int nuevoStock) =>
      _db.actualizarStockProducto(id, nuevoStock);

  /// 👀 Stream de productos activos
  Stream<List<Producto>> watchProductosActivos() => _db.watchProductosActivos();

  // ==================== SESIONES DE INVENTARIO ====================

  /// 📝 Crear nueva sesión de inventario
  Future<int> crearSesion({
    required String id, // sesion-001, sesion-002, etc.
    required String nombreLocal,
    required String localId,
    required String usuarioCreador, // Cédula del usuario
    required int totalReferencias,
    required int totalPrendas, // Suma de SAL_REF de todas las referencias
    String? observaciones,
  }) async {
    final sesion = SesionesCompanion(
      id: drift.Value(id),
      nombreLocal: drift.Value(nombreLocal),
      localId: drift.Value(localId),
      estado: drift.Value('en_progreso'), // Inicia en progreso
      usuarioCreador: drift.Value(usuarioCreador),
      totalReferencias: drift.Value(totalReferencias),
      totalPrendas: drift.Value(totalPrendas), // Total de prendas a escanear
      referenciasEscaneadas: drift.Value(0), // Inicia en 0
      prendasEscaneadas: drift.Value(0), // Inicia en 0
      dispositivosConectados: drift.Value(1), // El dispositivo que crea
      fechaCreacion: drift.Value(DateTime.now()),
      observaciones: drift.Value(observaciones),
    );

    return await _db.crearSesion(sesion);
  }

  /// 📖 Obtener todas las sesiones
  Future<List<Sesione>> obtenerSesiones() => _db.obtenerSesiones();

  /// 🔍 Obtener sesiones por estado ('en_progreso', 'finalizada', 'cancelada')
  Future<List<Sesione>> obtenerSesionesPorEstado(String estado) =>
      _db.obtenerSesionesPorEstado(estado);

  /// 🔍 Obtener sesiones por local
  Future<List<Sesione>> obtenerSesionesPorLocal(String localId) =>
      _db.obtenerSesionesPorLocal(localId);

  /// 🔍 Obtener sesión por ID
  Future<Sesione?> obtenerSesionPorId(String id) => _db.obtenerSesionPorId(id);

  /// ✏️ Actualizar progreso de sesión (cuando se escanea un código)
  Future<int> actualizarProgresoSesion(String id, int referenciasEscaneadas) =>
      _db.actualizarProgresoSesion(id, referenciasEscaneadas);

  /// ➕ Incrementar dispositivos conectados (cuando se conecta otro TC15)
  Future<int> incrementarDispositivosConectados(String id) =>
      _db.incrementarDispositivosConectados(id);

  /// ➖ Decrementar dispositivos conectados (cuando se desconecta un TC15)
  Future<int> decrementarDispositivosConectados(String id) =>
      _db.decrementarDispositivosConectados(id);

  /// ✅ Finalizar sesión (marcar como finalizada)
  Future<int> finalizarSesion(String id) => _db.finalizarSesion(id);

  /// ❌ Cancelar sesión
  Future<int> cancelarSesion(String id) => _db.cancelarSesion(id);

  /// 📊 Actualizar total de referencias después de cargar Excel
  Future<int> actualizarTotalReferencias(String id, int totalReferencias) =>
      _db.actualizarTotalReferencias(id, totalReferencias);

  /// 🗑️ Eliminar sesión por ID
  Future<int> eliminarSesion(String id) => _db.eliminarSesion(id);

  /// 📊 Contar sesiones activas
  Future<int> contarSesionesActivas() => _db.contarSesionesActivas();

  /// 👀 Stream de sesiones (actualización en tiempo real)
  Stream<List<Sesione>> watchSesiones() => _db.watchSesiones();

  // ==================== REFERENCIAS (Productos del Excel) ====================

  /// 📝 Crear referencia individual (nueva estructura simplificada)
  Future<int> crearReferencia({
    required String id,
    required String sesionId,
    required String codRef,
    required String nomRef,
    required double valRef,
    required int salRef,
    required double valTotal,
  }) async {
    final referencia = ReferenciasCompanion(
      id: drift.Value(id),
      sesionId: drift.Value(sesionId),
      codRef: drift.Value(codRef),
      nomRef: drift.Value(nomRef),
      valRef: drift.Value(valRef),
      salRef: drift.Value(salRef),
      valTotal: drift.Value(valTotal),
      fechaImportacion: drift.Value(DateTime.now()),
    );

    return await _db.crearReferencia(referencia);
  }

  /// 📝 Insertar múltiples referencias desde Excel
  Future<void> insertarReferenciasLote(
    List<ReferenciasCompanion> listaReferencias,
  ) => _db.insertarReferenciasLote(listaReferencias);

  /// 📖 Obtener referencias de una sesión
  Future<List<Referencia>> obtenerReferenciasPorSesion(String sesionId) =>
      _db.obtenerReferenciasPorSesion(sesionId);

  /// 🔍 Buscar por código (COD_REF)
  Future<Referencia?> buscarReferenciaPorCodigo(
    String sesionId,
    String codigo,
  ) => _db.buscarReferenciaPorCodigo(sesionId, codigo);

  /// ✏️ Actualizar cantidad escaneada
  Future<int> actualizarCantidadEscaneada(String referenciaId, int cantidad) =>
      _db.actualizarCantidadEscaneada(referenciaId, cantidad);

  /// ✏️ Marcar como completada
  Future<int> marcarReferenciaCompletada(String referenciaId) =>
      _db.marcarReferenciaCompletada(referenciaId);

  /// 📊 Contar referencias totales
  Future<int> contarReferenciasEnSesion(String sesionId) =>
      _db.contarReferenciasEnSesion(sesionId);

  /// 📊 Contar referencias completadas
  Future<int> contarReferenciasCompletadas(String sesionId) =>
      _db.contarReferenciasCompletadas(sesionId);

  /// 🔍 Obtener pendientes
  Future<List<Referencia>> obtenerReferenciasPendientes(String sesionId) =>
      _db.obtenerReferenciasPendientes(sesionId);

  /// 🗑️ Eliminar todas las referencias de una sesión
  Future<int> eliminarReferenciasDeSesion(String sesionId) =>
      _db.eliminarReferenciasDeSesion(sesionId);

  /// 👀 Stream de referencias
  Stream<List<Referencia>> watchReferenciasDeSesion(String sesionId) =>
      _db.watchReferenciasDeSesion(sesionId);

  /// ✏️ Actualizar tallas escaneadas
  Future<int> actualizarTallasEscaneadas(
    String referenciaId,
    String tallasJson,
  ) => _db.actualizarTallasEscaneadas(referenciaId, tallasJson);

  /// ✏️ Registrar excedente
  Future<int> registrarExcedente(String referenciaId, int excedente) =>
      _db.registrarExcedente(referenciaId, excedente);

  // ==================== REFERENCIAS NO ENCONTRADAS ====================

  /// 📝 Crear referencia no encontrada
  Future<int> crearReferenciaNoEncontrada({
    required String id,
    required String sesionId,
    required String codRef,
    required String nomRef,
    int cantidadEscaneada = 1,
    double? valRef,
    double? valTotal,
    bool agregadoAInventario = false,
    bool encontradoEnMaestra = false,
    String? tallasEncontradas,
    String? observaciones,
  }) async {
    final referencia = ReferenciasNoEncontradasCompanion(
      id: drift.Value(id),
      sesionId: drift.Value(sesionId),
      codRef: drift.Value(codRef),
      nomRef: drift.Value(nomRef),
      cantidadEscaneada: drift.Value(cantidadEscaneada),
      valRef: drift.Value(valRef),
      valTotal: drift.Value(valTotal),
      agregadoAInventario: drift.Value(agregadoAInventario),
      encontradoEnMaestra: drift.Value(encontradoEnMaestra),
      tallasEncontradas: drift.Value(tallasEncontradas),
      observaciones: drift.Value(observaciones),
      fechaPrimerEscaneo: drift.Value(DateTime.now()),
    );

    return await _db.crearReferenciaNoEncontrada(referencia);
  }

  /// 📖 Obtener referencias no encontradas
  Future<List<ReferenciasNoEncontrada>>
  obtenerReferenciasNoEncontradasPorSesion(String sesionId) =>
      _db.obtenerReferenciasNoEncontradasPorSesion(sesionId);

  /// 🔍 Buscar referencia no encontrada por código
  Future<ReferenciasNoEncontrada?> buscarReferenciaNoEncontrada(
    String sesionId,
    String codigo,
  ) => _db.buscarReferenciaNoEncontrada(sesionId, codigo);

  /// ✏️ Actualizar cantidad de referencia no encontrada
  Future<int> actualizarCantidadNoEncontrada(String id, int nuevaCantidad) =>
      _db.actualizarCantidadNoEncontrada(id, nuevaCantidad);

  /// ✏️ Marcar como agregada al inventario
  Future<int> marcarAgregadaAInventario(String id) =>
      _db.marcarAgregadaAInventario(id);

  /// 📊 Contar referencias no encontradas
  Future<int> contarReferenciasNoEncontradas(String sesionId) =>
      _db.contarReferenciasNoEncontradas(sesionId);

  /// 💰 Calcular valor de referencias no encontradas
  Future<double> calcularValorNoEncontrado(String sesionId) =>
      _db.calcularValorNoEncontrado(sesionId);

  /// 🗑️ Eliminar referencias no encontradas de sesión
  Future<int> eliminarReferenciasNoEncontradasDeSesion(String sesionId) =>
      _db.eliminarReferenciasNoEncontradasDeSesion(sesionId);

  /// 👀 Stream de referencias no encontradas
  Stream<List<ReferenciasNoEncontrada>> watchReferenciasNoEncontradas(
    String sesionId,
  ) => _db.watchReferenciasNoEncontradas(sesionId);

  // ==================== REFERENCIAS MAESTRAS (NUEVA ESTRUCTURA) ====================

  /// 📦 CREAR REFERENCIA MAESTRA
  ///
  /// Crea una nueva referencia en la tabla maestra.
  /// - Valida que no exista duplicado por COD_REF ni COD_BARRA.
  /// - Retorna el ID insertado o lanza excepción si hay duplicado.
  Future<int> crearReferenciaMaestra(
    ReferenciasMaestrasCompanion referencia,
  ) async {
    // Verificar duplicado por COD_REF
    final existeRef =
        await (_db.select(_db.referenciasMaestras)
              ..where((tbl) => tbl.codRef.equals(referencia.codRef.value)))
            .getSingleOrNull();
    if (existeRef != null)
      throw Exception('Ya existe una referencia con ese COD_REF');

    // Verificar duplicado por COD_BARRA
    if (referencia.codBarra.present) {
      final existeBarra =
          await (_db.select(
                _db.referenciasMaestras,
              )..where((tbl) => tbl.codBarra.equals(referencia.codBarra.value)))
              .getSingleOrNull();
      if (existeBarra != null)
        throw Exception('Ya existe una referencia con ese COD_BARRA');
    }

    return await _db.into(_db.referenciasMaestras).insert(referencia);
  }

  /// 📦 CREAR REFERENCIAS MAESTRAS MASIVO
  ///
  /// Importa una lista de referencias (por ejemplo, desde Excel).
  /// - Omite duplicados y retorna lista de errores.
  Future<List<String>> crearReferenciasMaestrasMasivo(
    List<ReferenciasMaestrasCompanion> referencias,
  ) async {
    final errores = <String>[];
    for (final ref in referencias) {
      try {
        await crearReferenciaMaestra(ref);
      } catch (e) {
        errores.add('${ref.codRef.value}: ${e.toString()}');
      }
    }
    return errores;
  }

  /// 🔍 OBTENER TODAS LAS REFERENCIAS MAESTRAS
  ///
  /// Devuelve todas las referencias ordenadas por nombre.
  Future<List<ReferenciasMaestra>> obtenerReferenciasMaestras() async {
    return await (_db.select(
      _db.referenciasMaestras,
    )..orderBy([(tbl) => drift.OrderingTerm(expression: tbl.nomRef)])).get();
  }

  /// ✏️ ACTUALIZAR REFERENCIA MAESTRA
  ///
  /// Actualiza campos específicos de una referencia por COD_REF.
  Future<int> actualizarReferenciaMaestra(
    String codRef,
    ReferenciasMaestrasCompanion cambios,
  ) async {
    return await (_db.update(
      _db.referenciasMaestras,
    )..where((tbl) => tbl.codRef.equals(codRef))).write(cambios);
  }

  /// 🗑️ ELIMINAR REFERENCIA MAESTRA
  ///
  /// Elimina una referencia por COD_REF.
  Future<int> eliminarReferenciaMaestra(String codRef) async {
    return await (_db.delete(
      _db.referenciasMaestras,
    )..where((tbl) => tbl.codRef.equals(codRef))).go();
  }

  /// 📤 EXPORTAR REFERENCIAS MAESTRAS A EXCEL
  ///
  /// Exporta todas las referencias a un archivo Excel.
  /// - Usa el paquete 'excel' para generar el archivo.
  Future<void> exportarReferenciasMaestrasAExcel(String rutaArchivo) async {
    final referencias = await obtenerReferenciasMaestras();
    // Lógica para crear archivo Excel con el paquete 'excel'
    // ...
  }

  /// 🔍 BUSCAR REFERENCIA POR COD_BARRA
  ///
  /// Busca una referencia por código de barras.
  Future<ReferenciasMaestra?> buscarReferenciaPorCodBarra(
    String codBarra,
  ) async {
    return await (_db.select(
      _db.referenciasMaestras,
    )..where((tbl) => tbl.codBarra.equals(codBarra))).getSingleOrNull();
  }

  // ==================== INDICADORES DE INVENTARIO ====================

  /// 📊 Calcular todos los indicadores de una sesión
  Future<Map<String, dynamic>> calcularIndicadoresInventario(String sesionId) =>
      _db.calcularIndicadoresInventario(sesionId);

  // ==================== UTILIDADES ====================

  /// 🔐 Hash simple de contraseña (desarrollo)
  /// ⚠️ En producción usar bcrypt o similar
  String hashPassword(String password) {
    return password.hashCode.toString();
  }

  /// 🧹 Cerrar base de datos
  Future<void> cerrar() async {
    await _db.close();
    print('✅ Base de datos Drift cerrada');
  }
}
