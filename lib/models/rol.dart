/// 👔 MODELO DE ROL
///
/// Esta clase representa los roles/perfiles de usuario en el sistema.
/// Define qué puede hacer cada tipo de usuario.

class Rol {
  final String id;
  final String nombre;
  final List<String> permisos;

  Rol({required this.id, required this.nombre, required this.permisos});

  /// Crear rol desde JSON
  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      permisos: List<String>.from(json['permisos'] ?? []),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'permisos': permisos};
  }

  /// Verificar si el rol tiene un permiso específico
  bool tienePermiso(String permiso) {
    return permisos.contains(permiso);
  }

  /// Lista de roles predeterminados del sistema
  static List<Rol> rolesDefault() {
    return [
      Rol(
        id: '1',
        nombre: 'Dirección General',
        permisos: [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
        ],
      ),
      Rol(
        id: '2',
        nombre: 'Administrador',
        permisos: [
          'admin',
          'pos',
          'inventory',
          'cyclical',
          'references',
          'reports',
          'settings',
        ],
      ),
      Rol(
        id: '3',
        nombre: 'Gestor de Punto',
        permisos: ['admin', 'pos', 'inventory', 'cyclical', 'references'],
      ),
      Rol(id: '4', nombre: 'Asesor Comercial', permisos: ['pos']),
      Rol(
        id: '5',
        nombre: 'Auditor',
        permisos: ['inventory', 'cyclical', 'references'],
      ),
    ];
  }
}
