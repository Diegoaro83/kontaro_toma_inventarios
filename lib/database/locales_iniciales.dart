import '../services/drift_service.dart';

/// 🏪 INICIALIZACIÓN DE LOCALES DEL SISTEMA
///
/// Este archivo contiene la lógica para crear los locales (tiendas y bodegas)
/// por defecto del sistema Oxígeno Zero Grados.
///
/// Se ejecuta al iniciar la app (main.dart) para garantizar que los locales
/// estén disponibles desde el primer uso.

class LocalesIniciales {
  static final _db = DriftService();

  /// 🎬 Inicializar todos los locales del sistema
  ///
  /// Este método:
  /// 1. Verifica si ya existen locales en la BD
  /// 2. Si NO existen, crea todos los locales por defecto
  /// 3. Muestra mensajes en consola para debugging
  static Future<void> inicializarLocales() async {
    try {
      print('🏪 Verificando locales del sistema...');

      // Verificar si ya existen locales
      final localesExistentes = await _db.obtenerLocales();

      if (localesExistentes.isNotEmpty) {
        print(
          '✅ Locales ya están creados (${localesExistentes.length} locales)',
        );
        return;
      }

      // Si no existen, crear todos los locales
      print('📝 Creando locales del sistema...');

      // 🏪 TIENDAS (LC_)
      await _crearLocal(id: 'LC_01', nombre: '361 SAN JOSE', tipo: 'tienda');

      await _crearLocal(id: 'LC_02', nombre: 'HIDROGENO', tipo: 'tienda');

      await _crearLocal(id: 'LC_03', nombre: 'CARBONO', tipo: 'tienda');

      await _crearLocal(id: 'LC_04', nombre: 'VISTO', tipo: 'tienda');

      await _crearLocal(id: 'LC_05', nombre: 'OXIGENO1', tipo: 'tienda');

      await _crearLocal(id: 'LC_06', nombre: 'OXIGENO2', tipo: 'tienda');

      await _crearLocal(id: 'LC_07', nombre: '361 RESTREPO', tipo: 'tienda');

      await _crearLocal(id: 'LC_08', nombre: 'LIBRE', tipo: 'tienda');

      // 📦 BODEGAS (BD_)
      await _crearLocal(id: 'BD_01', nombre: 'BUNKER', tipo: 'bodega');

      await _crearLocal(id: 'BD_02', nombre: 'BODEGA2', tipo: 'bodega');

      await _crearLocal(id: 'BD_03', nombre: 'BODEGA3', tipo: 'bodega');

      await _crearLocal(id: 'BD_04', nombre: 'LIBRE', tipo: 'bodega');

      print('🎉 Todos los locales fueron creados exitosamente');
    } catch (e) {
      print('❌ Error al inicializar locales: $e');
      rethrow;
    }
  }

  /// 🏗️ Método privado para crear un local
  static Future<void> _crearLocal({
    required String id,
    required String nombre,
    required String tipo,
  }) async {
    await _db.crearLocal(id: id, nombre: nombre, tipo: tipo, activo: true);

    final tipoEmoji = tipo == 'tienda' ? '🏪' : '📦';
    print('  $tipoEmoji $nombre creado');
  }
}
