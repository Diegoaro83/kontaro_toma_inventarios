import 'package:flutter/material.dart';

/// 💻 VERSIÓN ESCRITORIO DEL SELECTOR DE MÓDULOS
///
/// Diseño optimizado para pantallas grandes (PC, laptop):
/// - Grid de módulos (2-3 columnas)
/// - Barra lateral con información de usuario
/// - Más espacio y contenido visible sin scroll

class ModuleSelectorDesktop extends StatelessWidget {
  final String nombreUsuario;
  final String rolNombre;
  final List<Map<String, dynamic>> modulos;
  final Function(BuildContext, String) onModuloTap;

  const ModuleSelectorDesktop({
    super.key,
    required this.nombreUsuario,
    required this.rolNombre,
    required this.modulos,
    required this.onModuloTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🚦 Solo Dirección General ve el módulo Maestra de Referencias
    final esDireccionGeneral = rolNombre.toLowerCase().contains(
      'dirección general',
    );
    final modulosConMaestra = List<Map<String, dynamic>>.from(modulos);
    if (esDireccionGeneral) {
      modulosConMaestra.insert(0, {
        'nombre': 'Maestra de Referencias',
        'icono': Icons.menu_book_rounded,
        'color': const Color(0xFFFFD700), // Dorado
        'descripcion': 'Carga y consulta el catálogo global de productos',
      });
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1A2E),
            border: Border(
              bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.store, color: Color(0xFF3B82F6), size: 22),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oxígeno Zero Grados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Sistema de Gestión',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombreUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        rolNombre,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C950), Color(0xFF008236)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nombreUsuario[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          // 📍 Barra lateral izquierda (simplificada)
          Container(
            width: 280,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header con logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kontaro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sistema de Gestión',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Espacio expandido
                  const SizedBox(
                    height: 200,
                  ), // Puedes ajustar la altura según el contenido
                  // Footer oscuro
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B1A2E),
                      border: Border(
                        top: BorderSide(color: Color(0xFF1E293B), width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Estado del sistema',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Última sincronización: No sincronizado',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📍 Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Gestión de inventario',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Instrucción
                    const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'Selecciona un módulo para comenzar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Grid de módulos
                    SizedBox(
                      height: 600,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                        itemCount: modulosConMaestra.length,
                        itemBuilder: (context, index) {
                          return _buildModuloCard(
                            context,
                            modulosConMaestra[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuloCard(BuildContext context, Map<String, dynamic> modulo) {
    // 🎨 Card especial para Maestra de Referencias
    final esInventarios = modulo['nombre'] == 'Toma de Inventario';
    final esMaestra = modulo['nombre'] == 'Maestra de Referencias';

    return Material(
      color: esMaestra ? const Color(0xFFFFF8E1) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: esMaestra ? 6 : 2,
      shadowColor: Colors.black.withOpacity(esMaestra ? 0.12 : 0.05),
      child: InkWell(
        onTap: () => onModuloTap(context, modulo['nombre']),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: esMaestra
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono grande con degradado dorado si es Maestra
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: esInventarios
                      ? const LinearGradient(
                          colors: [Color(0xFF00C950), Color(0xFF008236)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : esMaestra
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: esInventarios
                      ? null
                      : esMaestra
                      ? null
                      : modulo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  modulo['icono'],
                  color: esInventarios
                      ? Colors.white
                      : esMaestra
                      ? const Color(0xFFB8860B)
                      : modulo['color'],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre del módulo
              Text(
                modulo['nombre'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: esMaestra
                      ? const Color(0xFFB8860B)
                      : const Color(0xFF1A202C),
                  letterSpacing: esMaestra ? 1.2 : 0.0,
                ),
              ),
              if (esMaestra) ...[
                const SizedBox(height: 8),
                Text(
                  modulo['descripcion'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8860B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '✨ Solo Dirección General',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB8860B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
