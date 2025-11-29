import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';

/// 💾 SERVICIO DE BASE DE DATOS SQLITE
///
/// Este servicio maneja toda la interacción con la base de datos local.
/// Usa SQLite para guardar datos offline (sin internet).
///
/// LECCIÓN: SQLite es como un Excel dentro de tu aplicación.
/// Puedes guardar, buscar, actualizar y borrar datos incluso sin conexión.

class DatabaseService {
  // 🔒 Singleton pattern - solo una instancia de la base de datos
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  /// Obtiene la base de datos (la crea si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    // Obtener la ruta donde se guardará la base de datos
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'kontaro.db');

    // Abrir/crear la base de datos
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas cuando se crea la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    // 👤 Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nombreUsuario TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        nombreCompleto TEXT NOT NULL,
        telefono TEXT,
        rol TEXT NOT NULL,
        rolId TEXT NOT NULL,
        tiendaId TEXT NOT NULL,
        tiendaNombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        contrasenaHash TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        fechaModificacion TEXT
      )
    ''');

    // 📦 Índices para búsquedas rápidas
    await db.execute(
      'CREATE INDEX idx_usuarios_nombreUsuario ON usuarios(nombreUsuario)',
    );
    await db.execute('CREATE INDEX idx_usuarios_email ON usuarios(email)');
    await db.execute('CREATE INDEX idx_usuarios_rolId ON usuarios(rolId)');
    await db.execute(
      'CREATE INDEX idx_usuarios_tiendaId ON usuarios(tiendaId)',
    );

    print('✅ Base de datos creada exitosamente');
  }

  /// Actualiza la estructura de la base de datos cuando cambia la versión
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí agregarás cambios futuros a la estructura
    if (oldVersion < 2) {
      // Ejemplo: await db.execute('ALTER TABLE usuarios ADD COLUMN nuevoCampo TEXT');
    }
  }

  // ==================== OPERACIONES CRUD DE USUARIOS ====================

  /// 📝 Crear un nuevo usuario
  Future<int> crearUsuario(Usuario usuario, String contrasena) async {
    final db = await database;

    try {
      // Hashear contraseña (en producción usar bcrypt o similar)
      final contrasenaHash = _hashPassword(contrasena);

      final resultado = await db.insert('usuarios', {
        'id': usuario.id,
        'nombreUsuario': usuario.nombreUsuario,
        'email': usuario.email,
        'nombreCompleto': usuario.nombreCompleto,
        'telefono': usuario.telefono,
        'rol': usuario.rol,
        'rolId': usuario.rolId,
        'tiendaId': usuario.tiendaId,
        'tiendaNombre': usuario.tiendaNombre,
        'activo': usuario.activo ? 1 : 0,
        'contrasenaHash': contrasenaHash,
        'fechaCreacion': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      print('✅ Usuario creado: ${usuario.nombreUsuario} (ID: $resultado)');
      return resultado;
    } catch (e) {
      print('❌ Error al crear usuario: $e');
      rethrow;
    }
  }

  /// 📖 Obtener todos los usuarios
  Future<List<Usuario>> obtenerUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      orderBy: 'nombreCompleto ASC',
    );

    return maps.map((map) => _usuarioFromMap(map)).toList();
  }

  /// 🔍 Buscar usuario por ID
  Future<Usuario?> obtenerUsuarioPorId(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _usuarioFromMap(maps.first);
  }

  /// 🔍 Buscar usuario por nombre de usuario
  Future<Usuario?> obtenerUsuarioPorNombreUsuario(String nombreUsuario) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nombreUsuario = ?',
      whereArgs: [nombreUsuario],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _usuarioFromMap(maps.first);
  }

  /// 🔍 Obtener usuarios por rol
  Future<List<Usuario>> obtenerUsuariosPorRol(String rolId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'rolId = ?',
      whereArgs: [rolId],
      orderBy: 'nombreCompleto ASC',
    );

    return maps.map((map) => _usuarioFromMap(map)).toList();
  }

  /// 🔍 Obtener usuarios por tienda
  Future<List<Usuario>> obtenerUsuariosPorTienda(String tiendaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'tiendaId = ?',
      whereArgs: [tiendaId],
      orderBy: 'nombreCompleto ASC',
    );

    return maps.map((map) => _usuarioFromMap(map)).toList();
  }

  /// ✏️ Actualizar usuario
  Future<int> actualizarUsuario(Usuario usuario) async {
    final db = await database;

    try {
      final resultado = await db.update(
        'usuarios',
        {
          'nombreUsuario': usuario.nombreUsuario,
          'email': usuario.email,
          'nombreCompleto': usuario.nombreCompleto,
          'telefono': usuario.telefono,
          'rol': usuario.rol,
          'rolId': usuario.rolId,
          'tiendaId': usuario.tiendaId,
          'tiendaNombre': usuario.tiendaNombre,
          'activo': usuario.activo ? 1 : 0,
          'fechaModificacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [usuario.id],
      );

      print('✅ Usuario actualizado: ${usuario.nombreUsuario}');
      return resultado;
    } catch (e) {
      print('❌ Error al actualizar usuario: $e');
      rethrow;
    }
  }

  /// 🗑️ Eliminar usuario
  Future<int> eliminarUsuario(String id) async {
    final db = await database;

    try {
      final resultado = await db.delete(
        'usuarios',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Usuario eliminado (ID: $id)');
      return resultado;
    } catch (e) {
      print('❌ Error al eliminar usuario: $e');
      rethrow;
    }
  }

  /// 🔐 Validar credenciales de login
  Future<Usuario?> validarLogin(String nombreUsuario, String contrasena) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nombreUsuario = ? AND activo = 1',
      whereArgs: [nombreUsuario],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final contrasenaHash = _hashPassword(contrasena);
    final usuario = maps.first;

    if (usuario['contrasenaHash'] == contrasenaHash) {
      return _usuarioFromMap(usuario);
    }

    return null;
  }

  /// 📊 Contar usuarios activos
  Future<int> contarUsuariosActivos() async {
    final db = await database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) as count FROM usuarios WHERE activo = 1',
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// 🔍 Buscar usuarios por texto
  Future<List<Usuario>> buscarUsuarios(String texto) async {
    final db = await database;
    final textoBusqueda = '%$texto%';

    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nombreCompleto LIKE ? OR nombreUsuario LIKE ? OR email LIKE ?',
      whereArgs: [textoBusqueda, textoBusqueda, textoBusqueda],
      orderBy: 'nombreCompleto ASC',
    );

    return maps.map((map) => _usuarioFromMap(map)).toList();
  }

  // ==================== MÉTODOS AUXILIARES ====================

  /// Convierte un Map de SQLite a objeto Usuario
  Usuario _usuarioFromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      nombreUsuario: map['nombreUsuario'] as String,
      email: map['email'] as String,
      nombreCompleto: map['nombreCompleto'] as String,
      telefono: map['telefono'] as String?,
      rol: map['rol'] as String,
      rolId: map['rolId'] as String,
      tiendaId: map['tiendaId'] as String,
      tiendaNombre: map['tiendaNombre'] as String,
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Hashea una contraseña (simplificado, en producción usar bcrypt)
  String _hashPassword(String password) {
    // ⚠️ NOTA: Esto es una simplificación para desarrollo
    // En producción debes usar crypto o bcrypt
    return password.hashCode.toString();
  }

  /// Cierra la conexión a la base de datos
  Future<void> cerrarDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    print('✅ Conexión a base de datos cerrada');
  }

  /// Elimina completamente la base de datos (solo para desarrollo)
  Future<void> eliminarDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'kontaro.db');
    await deleteDatabase(path);
    _database = null;
    print('✅ Base de datos eliminada completamente');
  }
}
