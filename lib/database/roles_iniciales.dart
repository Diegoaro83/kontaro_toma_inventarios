import '../services/drift_service.dart';

/// 🎭 DATOS INICIALES DE ROLES
///
/// Script para poblar la base de datos con los 5 roles del sistema
/// según la tabla de permisos proporcionada.

class RolesIniciales {
  static final _db = DriftService();

  /// Inicializa los 5 roles del sistema
  static Future<void> inicializarRoles() async {
    try {
      // Verificar si ya existen roles
      final rolesExistentes = await _db.obtenerRoles();
      if (rolesExistentes.isNotEmpty) {
        print('✅ Los roles ya están inicializados');
        return;
      }

      print('📝 Creando roles del sistema...');

      // 1️⃣ DIRECCIÓN GENERAL
      await _db.crearRol(
        id: '1',
        nombre: 'Dirección General',
        descripcion:
            'Acceso completo a todos los módulos creados. Información en tiempo real de todos los dispositivos conectados, informes y demás. Acceso completo a todos los módulos, gestión cambios a los inventarios, cantidades, precios, etc.',
        permisos: [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
          'users',
        ].join(','),
        accesoTodosModulos: true,
        informacionTiempoReal: true,
        accesoInventarios: true,
        accesoPuntoVenta: true,
        accesoConsultas: true,
        accesoReportes: true,
        gestionCantidades: true,
        gestionPrecios: true,
        activo: true,
      );
      print('  ✅ Dirección General creado');

      // 2️⃣ ADMINISTRADOR
      await _db.crearRol(
        id: '2',
        nombre: 'Administrador',
        descripcion:
            'Acceso completo a todos los módulos, gestión de inventarios, POS y reportes.',
        permisos: [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
        ].join(','),
        accesoTodosModulos: true,
        informacionTiempoReal: false,
        accesoInventarios: true,
        accesoPuntoVenta: true,
        accesoConsultas: true,
        accesoReportes: true,
        gestionCantidades: true,
        gestionPrecios: true,
        activo: true,
      );
      print('  ✅ Administrador creado');

      // 3️⃣ GESTOR DE PUNTO
      await _db.crearRol(
        id: '3',
        nombre: 'Gestor de Punto',
        descripcion:
            'Punto de Venta + Inventarios, consultas. Gestión operativa de tienda.',
        permisos: [
          'pos',
          'inventory',
          'cyclical',
          'references',
          'admin',
        ].join(','),
        accesoTodosModulos: false,
        informacionTiempoReal: false,
        accesoInventarios: true,
        accesoPuntoVenta: true,
        accesoConsultas: true,
        accesoReportes: false,
        gestionCantidades: true,
        gestionPrecios: false,
        activo: true,
      );
      print('  ✅ Gestor de Punto creado');

      // 4️⃣ ASESOR COMERCIAL
      await _db.crearRol(
        id: '4',
        nombre: 'Asesor Comercial',
        descripcion: 'Solo Punto de Venta, consultas. Atención al cliente.',
        permisos: ['pos', 'references'].join(','),
        accesoTodosModulos: false,
        informacionTiempoReal: false,
        accesoInventarios: false,
        accesoPuntoVenta: true,
        accesoConsultas: true,
        accesoReportes: false,
        gestionCantidades: false,
        gestionPrecios: false,
        activo: true,
      );
      print('  ✅ Asesor Comercial creado');

      // 5️⃣ AUDITOR
      await _db.crearRol(
        id: '5',
        nombre: 'Auditor',
        descripcion:
            'Solo módulos de Inventario. Revisión y auditoría de stock.',
        permisos: ['inventory', 'cyclical', 'references'].join(','),
        accesoTodosModulos: false,
        informacionTiempoReal: false,
        accesoInventarios: true,
        accesoPuntoVenta: false,
        accesoConsultas: true,
        accesoReportes: false,
        gestionCantidades: false,
        gestionPrecios: false,
        activo: true,
      );
      print('  ✅ Auditor creado');

      print('🎉 Todos los roles fueron creados exitosamente');
    } catch (e) {
      print('❌ Error al inicializar roles: $e');
      rethrow;
    }
  }

  /// Obtiene los permisos de un rol como lista
  static List<String> obtenerPermisosRol(String rolId) {
    switch (rolId) {
      case '1': // Dirección General
        return [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
          'users',
        ];
      case '2': // Administrador
        return [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
        ];
      case '3': // Gestor de Punto
        return ['pos', 'inventory', 'cyclical', 'references', 'admin'];
      case '4': // Asesor Comercial
        return ['pos', 'references'];
      case '5': // Auditor
        return ['inventory', 'cyclical', 'references'];
      default:
        return [];
    }
  }

  /// Verifica si un rol tiene un permiso específico
  static Future<bool> tienePermiso(String rolId, String permiso) async {
    final rol = await _db.obtenerRolPorId(rolId);
    if (rol == null) return false;

    final permisos = rol.permisos.split(',');
    return permisos.contains(permiso);
  }
}
