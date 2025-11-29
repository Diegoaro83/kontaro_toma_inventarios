/// 🛠️ CONFIGURACIÓN DE LA APLICACIÓN
///
/// Este archivo guarda toda la configuración importante de la app.
/// Por ejemplo: nombre de la app, versión, URLs del servidor, etc.
///
/// LECCIÓN: Es bueno tener toda la configuración en un solo lugar
/// para cambiarla fácilmente sin buscar en muchos archivos.

class AppConfig {
  // 🚫 Constructor privado
  AppConfig._();

  // ==================== INFORMACIÓN DE LA APP ====================

  /// Nombre de la aplicación
  static const String appName = 'Kontaro';

  /// Nombre completo de la empresa
  static const String companyName = 'Oxígeno Zero Grados';

  /// Versión actual
  static const String appVersion = '1.0.0';

  // ==================== CONFIGURACIÓN DE RED ====================

  /// URL base del servidor (API)
  /// Por ahora está vacía, la configuraremos cuando hagamos el backend
  static const String baseUrl = ''; // TODO: Agregar cuando tengamos servidor

  /// Tiempo máximo de espera para peticiones (en segundos)
  static const int timeoutSeconds = 30;

  // ==================== TIENDAS ====================

  /// Lista de tiendas disponibles
  static const List<Map<String, String>> tiendas = [
    {'id': '1', 'nombre': 'Tienda Principal', 'ciudad': 'Bogotá'},
    {'id': '2', 'nombre': 'Sucursal Norte', 'ciudad': 'Medellín'},
    {'id': '3', 'nombre': 'Sucursal Centro', 'ciudad': 'Cali'},
    {'id': '4', 'nombre': 'Sucursal Sur', 'ciudad': 'Barranquilla'},
  ];

  // ==================== ROLES DE USUARIO ====================

  /// Lista de roles disponibles en el sistema
  static const List<Map<String, dynamic>> roles = [
    {
      'id': '1',
      'nombre': 'Dirección General',
      'permisos': [
        'admin',
        'pos',
        'inventory',
        'cyclical',
        'references',
        'reports',
        'settings',
      ],
    },
    {
      'id': '2',
      'nombre': 'Administrador',
      'permisos': [
        'admin',
        'pos',
        'inventory',
        'cyclical',
        'references',
        'reports',
        'settings',
      ],
    },
    {
      'id': '3',
      'nombre': 'Gestor de Punto',
      'permisos': ['admin', 'pos', 'inventory', 'cyclical', 'references'],
    },
    {
      'id': '4',
      'nombre': 'Asesor Comercial',
      'permisos': ['pos'],
    },
    {
      'id': '5',
      'nombre': 'Auditor',
      'permisos': ['inventory', 'cyclical', 'references'],
    },
  ];

  // ==================== CATEGORÍAS DE PRODUCTOS ====================

  static const List<String> categorias = [
    'Camisetas',
    'Pantalones',
    'Vestidos',
    'Accesorios',
    'Zapatos',
  ];

  // ==================== CONFIGURACIÓN DE INVENTARIO ====================

  /// Cantidad mínima de stock para activar alerta de "stock bajo"
  static const int stockMinimo = 10;

  /// Límite de productos a mostrar por página
  static const int productosPorPagina = 20;

  // ==================== CONFIGURACIÓN LOCAL ====================

  /// Nombre de la base de datos local
  static const String localDbName = 'kontaro_local.db';

  /// Versión de la base de datos (incrementar cuando cambiemos estructura)
  static const int localDbVersion = 1;

  // ==================== CONFIGURACIÓN DE CACHÉ ====================

  /// Tiempo de vida del caché (en horas)
  static const int cacheDurationHours = 24;
}
