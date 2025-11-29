/// 🏪 MODELO DE TIENDA
///
/// Esta clase representa cada tienda/sucursal del sistema.

class Tienda {
  final String id;
  final String nombre;
  final String ciudad;
  final String? direccion;
  final String? telefono;
  final bool activa;

  Tienda({
    required this.id,
    required this.nombre,
    required this.ciudad,
    this.direccion,
    this.telefono,
    this.activa = true,
  });

  /// Crear tienda desde JSON
  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      ciudad: json['ciudad'] ?? '',
      direccion: json['direccion'],
      telefono: json['telefono'],
      activa: json['activa'] ?? true,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'ciudad': ciudad,
      'direccion': direccion,
      'telefono': telefono,
      'activa': activa,
    };
  }

  /// Obtener nombre completo con ciudad
  /// Por ejemplo: "Tienda Principal - Bogotá"
  String get nombreCompleto => '$nombre - $ciudad';
}
