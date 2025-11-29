/// 👤 MODELO DE USUARIO
///
/// Esta clase representa a un usuario del sistema.
/// Es como una "plantilla" que dice qué información tiene cada usuario.
///
/// LECCIÓN: En programación, un "modelo" es una estructura que define
/// qué datos vamos a guardar. Por ejemplo, un usuario tiene:
/// - ID (identificador único)
/// - Nombre de usuario
/// - Email
/// - Rol (su puesto/perfil)
/// - Tienda asignada
library;

class Usuario {
  /// ID único del usuario (como una cédula)
  final String id;

  /// Nombre de usuario para iniciar sesión
  final String nombreUsuario;

  /// Correo electrónico
  final String email;

  /// Nombre completo de la persona
  final String nombreCompleto;

  /// Teléfono (opcional)
  final String? telefono;

  /// Rol o puesto (Administrador, Gestor, etc.)
  final String rol;

  /// ID del rol
  final String rolId;

  /// ID de la tienda donde trabaja
  final String tiendaId;

  /// Nombre de la tienda
  final String tiendaNombre;

  /// Si el usuario está activo o no
  final bool activo;

  /// Constructor - La "fórmula" para crear un usuario
  ///
  /// LECCIÓN: Un constructor es como una receta. Le dices los ingredientes
  /// (parámetros) y te devuelve un usuario completo.
  Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    required this.nombreCompleto,
    this.telefono,
    required this.rol,
    required this.rolId,
    required this.tiendaId,
    required this.tiendaNombre,
    this.activo = true,
  });

  /// Crear usuario desde JSON (datos del servidor)
  ///
  /// LECCIÓN: JSON es el formato que usan los servidores para enviar datos.
  /// Se ve así: {"id": "123", "nombre": "Juan"}
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombreUsuario: json['nombreUsuario'] ?? '',
      email: json['email'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      telefono: json['telefono'],
      rol: json['rol'] ?? '',
      rolId: json['rolId'] ?? '',
      tiendaId: json['tiendaId'] ?? '',
      tiendaNombre: json['tiendaNombre'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  /// Convertir usuario a JSON (para enviar al servidor)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'email': email,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'rol': rol,
      'rolId': rolId,
      'tiendaId': tiendaId,
      'tiendaNombre': tiendaNombre,
      'activo': activo,
    };
  }
}
