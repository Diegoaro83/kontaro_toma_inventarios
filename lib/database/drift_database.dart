import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_database.g.dart';

/// 👔 TABLA DE ROLES
///
/// Define los roles del sistema con sus permisos específicos.
/// Cada rol tiene acceso a diferentes módulos y funcionalidades.
class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().unique().withLength(min: 3, max: 50)();
  TextColumn get descripcion => text()();
  TextColumn get permisos =>
      text()(); // JSON de permisos: ["admin", "pos", ...]
  BoolColumn get accesoTodosModulos =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get informacionTiempoReal =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get accesoInventarios =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get accesoPuntoVenta =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get accesoConsultas =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get accesoReportes =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get gestionCantidades =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get gestionPrecios =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 🏪 TABLA DE LOCALES
///
/// Define los locales/tiendas del sistema (puntos de venta físicos).
/// Incluye tanto tiendas (LC_) como bodegas (BD_).
class Locales extends Table {
  TextColumn get id => text()(); // LC_01, BD_01, etc.
  TextColumn get nombre => text().withLength(min: 3, max: 100)();
  TextColumn get tipo => text()(); // "tienda" o "bodega"
  TextColumn get direccion => text().nullable()();
  TextColumn get telefono => text().nullable()();
  TextColumn get ciudad => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 👤 TABLA DE USUARIOS
///
/// Define la estructura de la tabla usuarios en la base de datos.
/// Campos según especificación del sistema:
/// - Cedula: Documento de identidad (PK)
/// - Nombres_Apellidos: Nombre completo
/// - Nombre de Usuario: Username para login
/// - Telefono: Contacto
/// - Contraseña: Hash de contraseña
/// - Rol: ID del rol asignado
/// - LC_asignado: Local asignado (tienda/bodega)
/// - Activo/inactivo: Estado del usuario
/// - Codigo: Código único del usuario
class Usuarios extends Table {
  TextColumn get cedula => text()(); // Documento de identidad (PK)
  TextColumn get nombresApellidos => text().withLength(min: 3, max: 100)();
  TextColumn get nombreUsuario => text().unique().withLength(min: 3, max: 50)();
  TextColumn get telefono => text().nullable()();
  TextColumn get contrasena => text()(); // Hash de contraseña
  TextColumn get rolId => text()(); // FK a tabla Roles
  TextColumn get localAsignado =>
      text()(); // FK a tabla Locales (LC_01, BD_01, etc.)
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  TextColumn get codigo => text().unique()(); // Código único del usuario
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {cedula};
}

/// 📦 TABLA DE PRODUCTOS (para futuras implementaciones)
class Productos extends Table {
  TextColumn get id => text()();
  TextColumn get codigo => text().unique()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get categoria => text()();
  RealColumn get precio => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get stockMinimo => integer().withDefault(const Constant(10))();
  TextColumn get tiendaId => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 📦 TABLA DE SESIONES DE INVENTARIO
///
/// Gestiona las sesiones de conteo de inventario donde:
/// - Múltiples dispositivos pueden conectarse a una misma sesión
/// - Se registra el progreso en tiempo real (referencias escaneadas vs totales)
/// - Estados: 'en_progreso', 'finalizada', 'cancelada'
class Sesiones extends Table {
  TextColumn get id => text()(); // sesion-001, sesion-002, etc.
  TextColumn get nombreLocal => text()(); // Nombre del local (ej: "Restrepo")
  TextColumn get localId => text()(); // FK a Locales (LC_01, BD_01, etc.)
  TextColumn get estado => text()(); // 'en_progreso', 'finalizada', 'cancelada'
  TextColumn get usuarioCreador => text()(); // FK a Usuarios (cédula)
  IntColumn get totalReferencias => integer().withDefault(
    const Constant(0),
  )(); // Total de líneas del Excel (número de referencias únicas)
  IntColumn get totalPrendas => integer().withDefault(
    const Constant(0),
  )(); // Suma total de SAL_REF (todas las prendas a contar)
  IntColumn get referenciasEscaneadas =>
      integer().withDefault(const Constant(0))(); // Productos ya escaneados
  IntColumn get prendasEscaneadas => integer().withDefault(
    const Constant(0),
  )(); // Total de prendas escaneadas (acumulado)
  IntColumn get dispositivosConectados => integer().withDefault(
    const Constant(1),
  )(); // Número de dispositivos activos
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaFinalizacion => dateTime().nullable()();
  TextColumn get observaciones => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 📋 TABLA DE REFERENCIAS (Productos del Excel)
///
/// Almacena las referencias/productos importadas desde Excel para cada sesión.
/// Estructura basada en las 5 columnas del Excel:
/// - COD_REF: Código de barras
/// - NOM_REF: Nombre/descripción de la prenda
/// - VAL_REF: Valor unitario al mayor
/// - SAL_REF: Cantidad en inventario del local
/// - Val_total: VAL_REF * SAL_REF
class Referencias extends Table {
  TextColumn get id => text()(); // PK autogenerado: sesion-001-ref-0001
  TextColumn get sesionId => text()(); // FK a Sesiones

  // 📊 Campos del Excel (obligatorios)
  TextColumn get codRef => text()(); // COD_REF - Código de barras
  TextColumn get nomRef =>
      text()(); // NOM_REF - Nombre/descripción de la prenda
  RealColumn get valRef => real()(); // VAL_REF - Valor unitario al mayor
  IntColumn get salRef =>
      integer()(); // SAL_REF - Cantidad en inventario del local
  RealColumn get valTotal => real()(); // Val_total - VAL_REF * SAL_REF

  // 📱 Campos de control de escaneo
  IntColumn get cantidadEscaneada => integer().withDefault(
    const Constant(0),
  )(); // Cantidad ya escaneada de esta referencia
  IntColumn get excedente => integer().withDefault(
    const Constant(0),
  )(); // Cantidad escaneada por encima de salRef (sobrantes)
  BoolColumn get completado => boolean().withDefault(
    const Constant(false),
  )(); // true cuando cantidadEscaneada == salRef

  // 👕 Control de tallas
  TextColumn get tallasDisponibles =>
      text().nullable()(); // JSON: ["S","M","L","XL"]
  TextColumn get tallasEscaneadas =>
      text().nullable()(); // JSON: ["S","M"] - Tallas encontradas

  // 📅 Metadatos
  DateTimeColumn get fechaImportacion =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaPrimerEscaneo =>
      dateTime().nullable()(); // Cuando se escaneó por primera vez
  DateTimeColumn get fechaUltimoEscaneo =>
      dateTime().nullable()(); // Último escaneo de esta referencia

  @override
  Set<Column> get primaryKey => {id};
}

/// 🔍 TABLA DE REFERENCIAS NO ENCONTRADAS
///
/// Almacena productos escaneados que NO están en el inventario inicial (Excel).
/// Estos son productos "sobrantes" o nuevos que aparecen durante el conteo.
class ReferenciasNoEncontradas extends Table {
  TextColumn get id => text()(); // PK: sesion-001-noencontrada-0001
  TextColumn get sesionId => text()(); // FK a Sesiones

  // 📊 Datos del producto escaneado
  TextColumn get codRef => text()(); // Código de barras escaneado
  TextColumn get nomRef => text()(); // Descripción (de BD maestra o manual)
  IntColumn get cantidadEscaneada =>
      integer().withDefault(const Constant(1))(); // Cuántas veces se escaneó
  RealColumn get valRef =>
      real().nullable()(); // Valor unitario (si se encuentra)
  RealColumn get valTotal => real().nullable()(); // valRef × cantidadEscaneada

  // 🏪 Control de agregación al inventario local
  BoolColumn get agregadoAInventario => boolean().withDefault(
    const Constant(false),
  )(); // Si se agregó al inventario del local
  BoolColumn get encontradoEnMaestra => boolean().withDefault(
    const Constant(false),
  )(); // Si se encontró en BD maestra

  // 👕 Control de tallas
  TextColumn get tallasEncontradas => text().nullable()(); // JSON: ["S","M"]

  // 📅 Metadatos
  DateTimeColumn get fechaPrimerEscaneo =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaUltimoEscaneo => dateTime().nullable()();
  TextColumn get observaciones => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 📚 TABLA DE REFERENCIAS MAESTRAS
///
/// Base de datos completa de TODOS los productos de la empresa.
/// Se usa para buscar información cuando se escanea un código no registrado.
class ReferenciasMaestras extends Table {
  /// 📦 TABLA MAESTRA DE REFERENCIAS
  ///
  /// Catálogo global de productos/referencias. Permite importación masiva, edición y consulta.
  /// - Valida duplicados por COD_REF (PK) y COD_BARRA (único)
  /// - Usada por Dirección General

  TextColumn get codRef => text().named('COD_REF')();
  TextColumn get nomRef => text().named('NOM_REF')();
  TextColumn get codTip => text().named('COD_TIP')();
  TextColumn get codPrv => text().named('COD_PRV')();
  IntColumn get valRef => integer().named('VAL_REF')();
  TextColumn get codEmp => text().named('COD_EMP')();
  TextColumn get nomRef1 => text().named('NOM_REF1')();
  TextColumn get nomRef2 => text().named('NOM_REF2')();
  TextColumn get refPrv => text().named('REF_PRV')();
  IntColumn get valRef1 => integer().named('VAL_REF1')();
  TextColumn get codMar => text().named('COD_MAR')();
  IntColumn get vrunc => integer().named('VRUNC')();
  IntColumn get cos001 => integer().named('COS_001')();
  TextColumn get codBarra => text().named('COD_BARRA')();

  IntColumn get salRef => integer().named('SAL_REF')();
  TextColumn get tallas => text().named('TALLAS')();
  TextColumn get conRec => text().named('CON_REC')();
  IntColumn get valLista1 => integer().named('VAL_LISTA1')();
  IntColumn get valLista2 => integer().named('VAL_LISTA2')();
  IntColumn get valLista3 => integer().named('VAL_LISTA3')();

  // Campos agregados para compatibilidad con la app
  TextColumn get categoria => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  RealColumn get valorSugerido => real().nullable()();

  @override
  Set<Column> get primaryKey => {codRef};

  /// ⚠️ Validación de duplicados por COD_BARRA
  @override
  List<Set<Column>> get uniqueKeys => [
    {codBarra},
  ];
}

/// 📋 TABLA DE INVENTARIOS (OBSOLETA - Reemplazada por Sesiones)
/// Mantener por compatibilidad, migrar datos si es necesario
class Inventarios extends Table {
  TextColumn get id => text()();
  TextColumn get tiendaId => text()();
  TextColumn get usuarioId => text()();
  TextColumn get estado => text()(); // 'en_progreso', 'completado', 'cancelado'
  DateTimeColumn get fechaInicio =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaFin => dateTime().nullable()();
  TextColumn get observaciones => text().nullable()();
  IntColumn get totalProductos => integer().withDefault(const Constant(0))();
  IntColumn get productosContados => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 📊 TABLA DE DETALLES DE INVENTARIO
class DetallesInventario extends Table {
  TextColumn get id => text()();
  TextColumn get inventarioId => text()();
  TextColumn get productoId => text()();
  IntColumn get cantidadSistema => integer()();
  IntColumn get cantidadFisica => integer()();
  IntColumn get diferencia => integer()();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fechaConteo =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 💾 BASE DE DATOS DRIFT
///
/// Esta clase es el núcleo de Drift. Define todas las tablas
/// y proporciona acceso a los DAOs (Data Access Objects).
@DriftDatabase(
  tables: [
    Roles,
    Locales,
    Usuarios,
    Sesiones, // ✅ Tabla de sesiones de inventario
    Referencias, // ✅ Tabla de referencias/productos del Excel
    ReferenciasNoEncontradas, // ✅ Productos escaneados sin registro
    ReferenciasMaestras, // ✅ Catálogo completo de productos de la empresa
    Productos,
    Inventarios,
    DetallesInventario,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7; // Schema v7: Recrear tabla Referencias con estructura correcta

  /// 🔄 Migraciones de base de datos
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        print('✅ Base de datos Drift creada exitosamente');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 🔄 Migración de schema 4 a 5
        if (from < 5) {
          print('📦 Migrando base de datos de v$from a v5...');

          // Agregar nuevos campos a Referencias
          await m.addColumn(referencias, referencias.excedente);
          await m.addColumn(referencias, referencias.tallasDisponibles);
          await m.addColumn(referencias, referencias.tallasEscaneadas);

          // Crear nuevas tablas
          await m.createTable(referenciasNoEncontradas);
          await m.createTable(referenciasMaestras);

          print('✅ Migración v4→v5 completada');
        }

        // 🔄 Migración de schema 5 a 6
        if (from < 6) {
          print('📦 Migrando base de datos de v$from a v6...');

          // Agregar columnas a Sesiones (si no existen)
          try {
            await m.addColumn(sesiones, sesiones.totalPrendas);
            print('✅ Columna total_prendas agregada');
          } catch (e) {
            print('⚠️ Columna total_prendas ya existe');
          }

          try {
            await m.addColumn(sesiones, sesiones.prendasEscaneadas);
            print('✅ Columna prendas_escaneadas agregada');
          } catch (e) {
            print('⚠️ Columna prendas_escaneadas ya existe');
          }

          print('✅ Migración v5→v6 completada');
        }

        // 🔄 Migración de schema 6 a 7: Recrear tabla Referencias
        if (from < 7) {
          print('📦 Migrando base de datos de v$from a v7...');
          print('🔄 Recreando tabla Referencias con estructura correcta...');

          // Respaldar datos existentes de Referencias
          final referenciasExistentes = await customSelect(
            'SELECT * FROM referencias',
            readsFrom: {referencias},
          ).get();

          print(
            '📦 Respaldando ${referenciasExistentes.length} referencias existentes',
          );

          // Eliminar tabla anterior
          await customStatement('DROP TABLE IF EXISTS referencias');
          print('🗑️ Tabla anterior eliminada');

          // Crear tabla nueva con estructura correcta
          await m.createTable(referencias);
          print('✅ Tabla Referencias recreada');

          // Restaurar datos (si existen)
          if (referenciasExistentes.isNotEmpty) {
            print('🔄 Restaurando datos...');
            for (final row in referenciasExistentes) {
              try {
                await into(referencias).insert(
                  ReferenciasCompanion.insert(
                    id: row.read<String>('id'),
                    sesionId: row.read<String>('sesion_id'),
                    codRef: row.read<String>('cod_ref'),
                    nomRef: row.read<String>('nom_ref'),
                    valRef: row.read<double>('val_ref'),
                    salRef: row.read<int>('sal_ref'),
                    valTotal: row.read<double>('val_total'),
                    fechaImportacion: Value(
                      row.read<DateTime>('fecha_importacion'),
                    ),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
              } catch (e) {
                print(
                  '⚠️ Error restaurando referencia ${row.read<String>('id')}: $e',
                );
              }
            }
            print('✅ Datos restaurados');
          }

          print('✅ Migración v6→v7 completada');
        }
      },
      beforeOpen: (details) async {
        // Habilitar foreign keys
        await customStatement('PRAGMA foreign_keys = ON');

        if (details.wasCreated) {
          print('🎉 Primera vez abriendo la base de datos');
        }
      },
    );
  }

  // ==================== OPERACIONES CRUD DE ROLES ====================

  /// 📝 Crear un nuevo rol
  Future<int> crearRol(RolesCompanion rol) async {
    return await into(roles).insert(rol);
  }

  /// 📖 Obtener todos los roles
  Future<List<Role>> obtenerRoles() {
    return (select(
      roles,
    )..orderBy([(t) => OrderingTerm(expression: t.nombre)])).get();
  }

  /// 🔍 Buscar rol por ID
  Future<Role?> obtenerRolPorId(String id) {
    return (select(roles)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// 🔍 Obtener roles activos
  Future<List<Role>> obtenerRolesActivos() {
    return (select(roles)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .get();
  }

  /// ✏️ Actualizar rol
  Future<bool> actualizarRol(Role rol) {
    return update(roles).replace(rol);
  }

  /// 🗑️ Eliminar rol
  Future<int> eliminarRol(String id) {
    return (delete(roles)..where((t) => t.id.equals(id))).go();
  }

  /// 👀 Stream de roles activos
  Stream<List<Role>> watchRoles() {
    return (select(roles)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .watch();
  }

  // ==================== OPERACIONES CRUD DE LOCALES ====================

  /// 📝 Crear un nuevo local
  Future<int> crearLocal(LocalesCompanion local) async {
    return await into(locales).insert(local);
  }

  /// 📖 Obtener todos los locales
  Future<List<Locale>> obtenerLocales() {
    return (select(
      locales,
    )..orderBy([(t) => OrderingTerm(expression: t.nombre)])).get();
  }

  /// 🔍 Buscar local por ID
  Future<Locale?> obtenerLocalPorId(String id) {
    return (select(locales)..where((l) => l.id.equals(id))).getSingleOrNull();
  }

  /// 🏪 Obtener locales activos
  Future<List<Locale>> obtenerLocalesActivos() {
    return (select(locales)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .get();
  }

  /// 🏪 Obtener locales por tipo (tienda o bodega)
  Future<List<Locale>> obtenerLocalesPorTipo(String tipo) {
    return (select(locales)
          ..where((t) => t.tipo.equals(tipo) & t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .get();
  }

  /// ✏️ Actualizar local
  Future<bool> actualizarLocal(Locale local) {
    return update(locales).replace(local);
  }

  /// 🗑️ Eliminar local
  Future<int> eliminarLocal(String id) {
    return (delete(locales)..where((t) => t.id.equals(id))).go();
  }

  /// 👀 Stream de locales activos
  Stream<List<Locale>> watchLocales() {
    return (select(locales)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .watch();
  }

  // ==================== OPERACIONES CRUD DE USUARIOS ====================

  /// 📝 Crear un nuevo usuario
  Future<int> crearUsuario(UsuariosCompanion usuario) async {
    return await into(usuarios).insert(usuario);
  }

  /// 📖 Obtener todos los usuarios
  Future<List<Usuario>> obtenerUsuarios() {
    return (select(
      usuarios,
    )..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)])).get();
  }

  /// 🔍 Buscar usuario por cédula (PK)
  Future<Usuario?> obtenerUsuarioPorCedula(String cedula) {
    return (select(
      usuarios,
    )..where((t) => t.cedula.equals(cedula))).getSingleOrNull();
  }

  /// 🔍 Buscar usuario por nombre de usuario
  Future<Usuario?> obtenerUsuarioPorNombreUsuario(String nombreUsuario) {
    return (select(
      usuarios,
    )..where((t) => t.nombreUsuario.equals(nombreUsuario))).getSingleOrNull();
  }

  /// 🔍 Obtener usuarios por rol
  Future<List<Usuario>> obtenerUsuariosPorRol(String rolId) {
    return (select(usuarios)
          ..where((t) => t.rolId.equals(rolId))
          ..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)]))
        .get();
  }

  /// 🔍 Obtener usuarios activos
  Future<List<Usuario>> obtenerUsuariosActivos() {
    return (select(usuarios)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)]))
        .get();
  }

  /// 🔍 Buscar usuarios por texto
  Future<List<Usuario>> buscarUsuarios(String texto) {
    final textoBusqueda = '%$texto%';
    return (select(usuarios)
          ..where(
            (t) =>
                t.nombresApellidos.like(textoBusqueda) |
                t.nombreUsuario.like(textoBusqueda) |
                t.cedula.like(textoBusqueda),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)]))
        .get();
  }

  /// 🔍 Obtener usuarios por local asignado
  Future<List<Usuario>> obtenerUsuariosPorLocal(String localId) {
    return (select(usuarios)
          ..where((t) => t.localAsignado.equals(localId))
          ..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)]))
        .get();
  }

  /// ✏️ Actualizar usuario
  Future<bool> actualizarUsuario(Usuario usuario) {
    return update(usuarios).replace(usuario);
  }

  /// ✏️ Actualizar usuario parcialmente (por mapa de cambios)
  Future<int> actualizarUsuarioParcial(
    String cedula,
    Map<String, dynamic> cambios,
  ) {
    return (update(usuarios)..where((t) => t.cedula.equals(cedula))).write(
      UsuariosCompanion(
        nombresApellidos: cambios.containsKey('nombresApellidos')
            ? Value(cambios['nombresApellidos'] as String)
            : const Value.absent(),
        nombreUsuario: cambios.containsKey('nombreUsuario')
            ? Value(cambios['nombreUsuario'] as String)
            : const Value.absent(),
        telefono: cambios.containsKey('telefono')
            ? Value(cambios['telefono'] as String?)
            : const Value.absent(),
        contrasena: cambios.containsKey('contrasena')
            ? Value(cambios['contrasena'] as String)
            : const Value.absent(),
        rolId: cambios.containsKey('rolId')
            ? Value(cambios['rolId'] as String)
            : const Value.absent(),
        localAsignado: cambios.containsKey('localAsignado')
            ? Value(cambios['localAsignado'] as String)
            : const Value.absent(),
        activo: cambios.containsKey('activo')
            ? Value(cambios['activo'] as bool)
            : const Value.absent(),
      ),
    );
  }

  /// 🗑️ Eliminar usuario por cédula
  Future<int> eliminarUsuario(String cedula) {
    return (delete(usuarios)..where((t) => t.cedula.equals(cedula))).go();
  }

  /// 🔐 Validar login
  Future<Usuario?> validarLogin(
    String nombreUsuario,
    String contrasenaHash,
  ) async {
    return await (select(usuarios)..where(
          (t) =>
              t.nombreUsuario.equals(nombreUsuario) &
              t.contrasena.equals(contrasenaHash) &
              t.activo.equals(true),
        ))
        .getSingleOrNull();
  }

  /// 📊 Contar usuarios activos
  Future<int> contarUsuariosActivos() async {
    final query = selectOnly(usuarios)
      ..where(usuarios.activo.equals(true))
      ..addColumns([usuarios.cedula.count()]);

    final result = await query.getSingle();
    return result.read(usuarios.cedula.count()) ?? 0;
  }

  // ==================== OPERACIONES DE PRODUCTOS ====================

  /// 📝 Crear producto
  Future<int> crearProducto(ProductosCompanion producto) {
    return into(productos).insert(producto);
  }

  /// 📖 Obtener todos los productos
  Future<List<Producto>> obtenerProductos() {
    return (select(
      productos,
    )..orderBy([(t) => OrderingTerm(expression: t.nombre)])).get();
  }

  /// 🔍 Buscar producto por código
  Future<Producto?> obtenerProductoPorCodigo(String codigo) {
    return (select(
      productos,
    )..where((t) => t.codigo.equals(codigo))).getSingleOrNull();
  }

  /// 🔍 Productos con stock bajo
  Future<List<Producto>> obtenerProductosStockBajo() {
    return (select(productos)
          ..where((t) => t.stock.isSmallerOrEqual(t.stockMinimo))
          ..orderBy([(t) => OrderingTerm(expression: t.stock)]))
        .get();
  }

  /// ✏️ Actualizar stock de producto
  Future<int> actualizarStockProducto(String id, int nuevoStock) {
    return (update(productos)..where((t) => t.id.equals(id))).write(
      ProductosCompanion(
        stock: Value(nuevoStock),
        fechaModificacion: Value(DateTime.now()),
      ),
    );
  }

  // ==================== STREAMS REACTIVOS ====================

  /// 👀 Stream de usuarios (se actualiza automáticamente)
  Stream<List<Usuario>> watchUsuarios() {
    return (select(
      usuarios,
    )..orderBy([(t) => OrderingTerm(expression: t.nombresApellidos)])).watch();
  }

  /// 👀 Stream de productos activos
  Stream<List<Producto>> watchProductosActivos() {
    return (select(productos)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .watch();
  }

  // ==================== SESIONES DE INVENTARIO ====================

  /// 📝 Crear nueva sesión de inventario
  Future<int> crearSesion(SesionesCompanion sesion) async {
    return await into(sesiones).insert(sesion);
  }

  /// 📖 Obtener todas las sesiones ordenadas por fecha (más recientes primero)
  Future<List<Sesione>> obtenerSesiones() {
    return (select(sesiones)..orderBy([
          (t) => OrderingTerm(
            expression: t.fechaCreacion,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  /// 🔍 Obtener sesiones por estado ('en_progreso', 'finalizada', 'cancelada')
  Future<List<Sesione>> obtenerSesionesPorEstado(String estado) {
    return (select(sesiones)
          ..where((t) => t.estado.equals(estado))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.fechaCreacion,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// 🏪 Obtener sesiones por local
  Future<List<Sesione>> obtenerSesionesPorLocal(String localId) {
    return (select(sesiones)
          ..where((t) => t.localId.equals(localId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.fechaCreacion,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// 🔍 Obtener sesión por ID
  Future<Sesione?> obtenerSesionPorId(String id) {
    return (select(sesiones)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// ✏️ Actualizar progreso de sesión (cuando se escanea un código)
  Future<int> actualizarProgresoSesion(String id, int referenciasEscaneadas) {
    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(referenciasEscaneadas: Value(referenciasEscaneadas)),
    );
  }

  /// ➕ Incrementar dispositivos conectados (cuando se conecta otro TC15)
  Future<int> incrementarDispositivosConectados(String id) async {
    final sesion = await obtenerSesionPorId(id);
    if (sesion == null) return 0;

    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(
        dispositivosConectados: Value(sesion.dispositivosConectados + 1),
      ),
    );
  }

  /// ➖ Decrementar dispositivos conectados (cuando se desconecta un TC15)
  Future<int> decrementarDispositivosConectados(String id) async {
    final sesion = await obtenerSesionPorId(id);
    if (sesion == null) return 0;

    final nuevoValor = sesion.dispositivosConectados - 1;
    if (nuevoValor < 0) return 0; // No permitir negativos

    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(dispositivosConectados: Value(nuevoValor)),
    );
  }

  /// ✅ Finalizar sesión (marcar como finalizada con fecha)
  Future<int> finalizarSesion(String id) {
    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(
        estado: Value('finalizada'),
        fechaFinalizacion: Value(DateTime.now()),
      ),
    );
  }

  /// ❌ Cancelar sesión
  Future<int> cancelarSesion(String id) {
    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(estado: Value('cancelada')),
    );
  }

  /// 📊 Actualizar total de referencias después de cargar Excel
  Future<int> actualizarTotalReferencias(String id, int totalReferencias) {
    return (update(sesiones)..where((t) => t.id.equals(id))).write(
      SesionesCompanion(totalReferencias: Value(totalReferencias)),
    );
  }

  /// 🗑️ Eliminar sesión por ID
  Future<int> eliminarSesion(String id) {
    return (delete(sesiones)..where((t) => t.id.equals(id))).go();
  }

  /// 📊 Contar sesiones activas (en progreso)
  Future<int> contarSesionesActivas() async {
    final query = selectOnly(sesiones)
      ..addColumns([sesiones.id.count()])
      ..where(sesiones.estado.equals('en_progreso'));

    final resultado = await query.getSingle();
    return resultado.read(sesiones.id.count()) ?? 0;
  }

  /// 👀 Stream de sesiones (actualización en tiempo real)
  Stream<List<Sesione>> watchSesiones() {
    return (select(sesiones)..orderBy([
          (t) => OrderingTerm(
            expression: t.fechaCreacion,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  // ==================== REFERENCIAS (Productos del Excel) ====================

  /// 📝 Crear referencia individual
  Future<int> crearReferencia(ReferenciasCompanion referencia) async {
    return await into(referencias).insert(referencia);
  }

  /// 📝 Insertar múltiples referencias (desde Excel)
  Future<void> insertarReferenciasLote(
    List<ReferenciasCompanion> listaReferencias,
  ) async {
    await batch((batch) {
      batch.insertAll(referencias, listaReferencias);
    });
  }

  /// 📖 Obtener todas las referencias de una sesión
  Future<List<Referencia>> obtenerReferenciasPorSesion(String sesionId) {
    return (select(referencias)
          ..where((t) => t.sesionId.equals(sesionId))
          ..orderBy([(t) => OrderingTerm(expression: t.codRef)]))
        .get();
  }

  /// 🔍 Buscar referencia por código de barras en una sesión
  Future<Referencia?> buscarReferenciaPorCodigo(
    String sesionId,
    String codigo,
  ) {
    return (select(referencias)
          ..where((t) => t.sesionId.equals(sesionId) & t.codRef.equals(codigo)))
        .getSingleOrNull();
  }

  /// ✏️ Actualizar cantidad escaneada (cuando se escanea)
  Future<int> actualizarCantidadEscaneada(
    String referenciaId,
    int nuevaCantidad,
  ) {
    return (update(referencias)..where((t) => t.id.equals(referenciaId))).write(
      ReferenciasCompanion(
        cantidadEscaneada: Value(nuevaCantidad),
        completado: Value(nuevaCantidad > 0),
        fechaUltimoEscaneo: Value(DateTime.now()),
      ),
    );
  }

  /// ✏️ Marcar referencia como completada
  Future<int> marcarReferenciaCompletada(String referenciaId) {
    return (update(referencias)..where((t) => t.id.equals(referenciaId))).write(
      ReferenciasCompanion(completado: Value(true)),
    );
  }

  /// 📊 Contar referencias de una sesión
  Future<int> contarReferenciasEnSesion(String sesionId) async {
    final query = selectOnly(referencias)
      ..addColumns([referencias.id.count()])
      ..where(referencias.sesionId.equals(sesionId));

    final resultado = await query.getSingle();
    return resultado.read(referencias.id.count()) ?? 0;
  }

  /// 📊 Contar referencias ya completadas en una sesión
  Future<int> contarReferenciasCompletadas(String sesionId) async {
    final query = selectOnly(referencias)
      ..addColumns([referencias.id.count()])
      ..where(
        referencias.sesionId.equals(sesionId) &
            referencias.completado.equals(true),
      );

    final resultado = await query.getSingle();
    return resultado.read(referencias.id.count()) ?? 0;
  }

  /// 🔍 Obtener referencias pendientes de una sesión
  Future<List<Referencia>> obtenerReferenciasPendientes(String sesionId) {
    return (select(referencias)
          ..where(
            (t) => t.sesionId.equals(sesionId) & t.completado.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.codRef)]))
        .get();
  }

  /// 🗑️ Eliminar todas las referencias de una sesión
  Future<int> eliminarReferenciasDeSesion(String sesionId) {
    return (delete(
      referencias,
    )..where((t) => t.sesionId.equals(sesionId))).go();
  }

  /// 👀 Stream de referencias de una sesión (tiempo real)
  Stream<List<Referencia>> watchReferenciasDeSesion(String sesionId) {
    return (select(referencias)
          ..where((t) => t.sesionId.equals(sesionId))
          ..orderBy([(t) => OrderingTerm(expression: t.codRef)]))
        .watch();
  }

  /// ✏️ Actualizar tallas escaneadas de una referencia
  Future<int> actualizarTallasEscaneadas(
    String referenciaId,
    String tallasJson,
  ) {
    return (update(referencias)..where((t) => t.id.equals(referenciaId))).write(
      ReferenciasCompanion(tallasEscaneadas: Value(tallasJson)),
    );
  }

  /// ✏️ Registrar excedente (cuando se escanea más de salRef)
  Future<int> registrarExcedente(String referenciaId, int excedente) {
    return (update(referencias)..where((t) => t.id.equals(referenciaId))).write(
      ReferenciasCompanion(excedente: Value(excedente)),
    );
  }

  // ==================== REFERENCIAS NO ENCONTRADAS ====================

  /// 📝 Crear referencia no encontrada
  Future<int> crearReferenciaNoEncontrada(
    ReferenciasNoEncontradasCompanion referencia,
  ) async {
    return await into(referenciasNoEncontradas).insert(referencia);
  }

  /// 📖 Obtener referencias no encontradas de una sesión
  Future<List<ReferenciasNoEncontrada>>
  obtenerReferenciasNoEncontradasPorSesion(String sesionId) {
    return (select(referenciasNoEncontradas)
          ..where((t) => t.sesionId.equals(sesionId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.fechaPrimerEscaneo,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// 🔍 Buscar referencia no encontrada por código
  Future<ReferenciasNoEncontrada?> buscarReferenciaNoEncontrada(
    String sesionId,
    String codigo,
  ) {
    return (select(referenciasNoEncontradas)
          ..where((t) => t.sesionId.equals(sesionId) & t.codRef.equals(codigo)))
        .getSingleOrNull();
  }

  /// ✏️ Actualizar cantidad de referencia no encontrada (cuando se re-escanea)
  Future<int> actualizarCantidadNoEncontrada(String id, int nuevaCantidad) {
    return (update(
      referenciasNoEncontradas,
    )..where((t) => t.id.equals(id))).write(
      ReferenciasNoEncontradasCompanion(
        cantidadEscaneada: Value(nuevaCantidad),
        fechaUltimoEscaneo: Value(DateTime.now()),
      ),
    );
  }

  /// ✏️ Marcar como agregada al inventario local
  Future<int> marcarAgregadaAInventario(String id) {
    return (update(
      referenciasNoEncontradas,
    )..where((t) => t.id.equals(id))).write(
      ReferenciasNoEncontradasCompanion(agregadoAInventario: Value(true)),
    );
  }

  /// 📊 Contar referencias no encontradas en una sesión
  Future<int> contarReferenciasNoEncontradas(String sesionId) async {
    final query = selectOnly(referenciasNoEncontradas)
      ..addColumns([referenciasNoEncontradas.id.count()])
      ..where(referenciasNoEncontradas.sesionId.equals(sesionId));

    final resultado = await query.getSingle();
    return resultado.read(referenciasNoEncontradas.id.count()) ?? 0;
  }

  /// 💰 Calcular valor total de referencias no encontradas
  Future<double> calcularValorNoEncontrado(String sesionId) async {
    final referencias = await obtenerReferenciasNoEncontradasPorSesion(
      sesionId,
    );
    return referencias.fold<double>(
      0.0,
      (sum, ref) => sum + (ref.valTotal ?? 0.0),
    );
  }

  /// 🗑️ Eliminar referencias no encontradas de una sesión
  Future<int> eliminarReferenciasNoEncontradasDeSesion(String sesionId) {
    return (delete(
      referenciasNoEncontradas,
    )..where((t) => t.sesionId.equals(sesionId))).go();
  }

  /// 👀 Stream de referencias no encontradas
  Stream<List<ReferenciasNoEncontrada>> watchReferenciasNoEncontradas(
    String sesionId,
  ) {
    return (select(referenciasNoEncontradas)
          ..where((t) => t.sesionId.equals(sesionId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.fechaPrimerEscaneo,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // ==================== REFERENCIAS MAESTRAS ====================

  /// 📝 Crear referencia maestra
  Future<int> crearReferenciaMaestra(
    ReferenciasMaestrasCompanion referencia,
  ) async {
    return await into(referenciasMaestras).insert(referencia);
  }

  /// 📝 Insertar múltiples referencias maestras (carga inicial)
  Future<void> insertarReferenciasMaestrasLote(
    List<ReferenciasMaestrasCompanion> lista,
  ) async {
    await batch((batch) {
      batch.insertAll(referenciasMaestras, lista);
    });
  }

  /// 📖 Obtener todas las referencias maestras activas
  Future<List<ReferenciasMaestra>> obtenerReferenciasMaestras() {
    return (select(referenciasMaestras)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nomRef)]))
        .get();
  }

  /// 🔍 Buscar referencia maestra por código de barras
  Future<ReferenciasMaestra?> buscarReferenciaMaestraPorCodigo(String codigo) {
    return (select(
      referenciasMaestras,
    )..where((t) => t.codRef.equals(codigo))).getSingleOrNull();
  }

  /// 🔍 Buscar referencias maestras por nombre (búsqueda parcial)
  Future<List<ReferenciasMaestra>> buscarReferenciasMaestrasPorNombre(
    String nombre,
  ) {
    final nombreBusqueda = '%$nombre%';
    return (select(referenciasMaestras)
          ..where((t) => t.nomRef.like(nombreBusqueda) & t.activo.equals(true)))
        .get();
  }

  /// 🔍 Obtener referencias maestras por categoría
  Future<List<ReferenciasMaestra>> obtenerReferenciasMaestrasPorCategoria(
    String categoria,
  ) {
    return (select(referenciasMaestras)
          ..where((t) => t.categoria.equals(categoria) & t.activo.equals(true)))
        .get();
  }

  /// ✏️ Actualizar referencia maestra
  Future<bool> actualizarReferenciaMaestra(ReferenciasMaestra referencia) {
    return update(referenciasMaestras).replace(referencia);
  }

  /// 🗑️ Eliminar referencia maestra (soft delete)
  Future<int> desactivarReferenciaMaestra(String codRef) {
    return (update(referenciasMaestras)..where((t) => t.codRef.equals(codRef)))
        .write(ReferenciasMaestrasCompanion(activo: Value(false)));
  }

  /// 📊 Contar referencias maestras activas
  Future<int> contarReferenciasMaestras() async {
    final query = selectOnly(referenciasMaestras)
      ..addColumns([referenciasMaestras.codRef.count()])
      ..where(referenciasMaestras.activo.equals(true));

    final resultado = await query.getSingle();
    return resultado.read(referenciasMaestras.codRef.count()) ?? 0;
  }

  /// 👀 Stream de referencias maestras
  Stream<List<ReferenciasMaestra>> watchReferenciasMaestras() {
    return (select(referenciasMaestras)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.nomRef)]))
        .watch();
  }

  // ==================== INDICADORES DE INVENTARIO ====================

  /// 📊 Calcular indicadores completos de una sesión
  Future<Map<String, dynamic>> calcularIndicadoresInventario(
    String sesionId,
  ) async {
    final referencias = await obtenerReferenciasPorSesion(sesionId);
    final noEncontradas = await obtenerReferenciasNoEncontradasPorSesion(
      sesionId,
    );

    // Valores iniciales (del Excel)
    double valorTotalInicial = 0;
    int cantidadReferencias = referencias.length;
    int cantidadUnidadesInicial = 0;

    // Valores dinámicos (escaneados)
    double valorEscaneado = 0;
    int unidadesEscaneadas = 0;
    int unidadesPendientes = 0;
    int referenciasCompletadas = 0;

    // Faltantes y sobrantes
    int faltantesUnidades = 0;
    double faltantesValor = 0;
    int sobrantesUnidades = 0;
    double sobrantesValor = 0;

    for (final ref in referencias) {
      valorTotalInicial += ref.valTotal;
      cantidadUnidadesInicial += ref.salRef;

      if (ref.cantidadEscaneada > 0) {
        final cantidadValida = ref.cantidadEscaneada > ref.salRef
            ? ref.salRef
            : ref.cantidadEscaneada;
        valorEscaneado += ref.valRef * cantidadValida;
        unidadesEscaneadas += ref.cantidadEscaneada;
      }

      if (ref.completado) {
        referenciasCompletadas++;
      }

      // Calcular faltantes
      if (ref.cantidadEscaneada < ref.salRef) {
        final faltante = ref.salRef - ref.cantidadEscaneada;
        faltantesUnidades += faltante;
        faltantesValor += ref.valRef * faltante;
      }

      // Calcular sobrantes (excedentes)
      if (ref.excedente > 0) {
        sobrantesUnidades += ref.excedente;
        sobrantesValor += ref.valRef * ref.excedente;
      }
    }

    unidadesPendientes = cantidadUnidadesInicial - unidadesEscaneadas;

    // Productos no encontrados
    double valorNoEncontrado = 0;
    int unidadesNoEncontradas = 0;

    for (final nf in noEncontradas) {
      valorNoEncontrado += nf.valTotal ?? 0.0;
      unidadesNoEncontradas += nf.cantidadEscaneada;
      sobrantesUnidades += nf.cantidadEscaneada;
      sobrantesValor += nf.valTotal ?? 0.0;
    }

    return {
      // Indicadores fijos
      'valorTotalInicial': valorTotalInicial,
      'cantidadReferencias': cantidadReferencias,
      'cantidadUnidadesInicial': cantidadUnidadesInicial,

      // Indicadores dinámicos
      'valorInventarioActual': valorTotalInicial - valorEscaneado,
      'valorEscaneado': valorEscaneado,
      'valorNoEncontrado': valorNoEncontrado,
      'unidadesPendientes': unidadesPendientes,
      'unidadesEscaneadas': unidadesEscaneadas,
      'unidadesNoEncontradas': unidadesNoEncontradas,
      'referenciasCompletadas': referenciasCompletadas,

      // Indicadores de auditoría
      'faltantesUnidades': faltantesUnidades,
      'faltantesValor': faltantesValor,
      'sobrantesUnidades': sobrantesUnidades,
      'sobrantesValor': sobrantesValor,

      // Porcentajes
      'porcentajeCompletado': cantidadReferencias > 0
          ? (referenciasCompletadas / cantidadReferencias) * 100
          : 0,
      'porcentajeUnidadesEscaneadas': cantidadUnidadesInicial > 0
          ? (unidadesEscaneadas / cantidadUnidadesInicial) * 100
          : 0,
    };
  }
}

/// 🔌 Conexión a la base de datos
///
/// Usa sqflite en Android/iOS y NativeDatabase en Windows/Linux
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'kontaro_drift.db');

    print('📂 Base de datos ubicada en: $dbPath');

    // Usar sqflite en móviles (Android/iOS) para mejor compatibilidad
    if (Platform.isAndroid || Platform.isIOS) {
      return SqfliteQueryExecutor.inDatabaseFolder(
        path: 'kontaro_drift.db',
        logStatements: true,
      );
    }

    // Usar NativeDatabase en escritorio (Windows/Linux/macOS)
    final file = File(dbPath);
    return NativeDatabase.createInBackground(file);
  });
}
