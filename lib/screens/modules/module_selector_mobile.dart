import 'package:flutter/material.dart';

/// 📱 VERSIÓN MÓVIL DEL SELECTOR DE MÓDULOS
///
/// Diseño optimizado para pantallas pequeñas (teléfonos):
/// - Lista vertical con módulos uno debajo del otro
/// - Hora visible arriba
/// - Tarjeta de información de perfil compacta

class ModuleSelectorMobile extends StatelessWidget {
  final String nombreUsuario;
  final String rolNombre;
  final List<Map<String, dynamic>> modulos;
  final Function(BuildContext, String) onModuloTap;

  const ModuleSelectorMobile({
    super.key,
    required this.nombreUsuario,
    required this.rolNombre,
    required this.modulos,
    required this.onModuloTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isVerySmall ? 40 : 44),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1A2E),
            border: Border(
              bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmall ? 12 : 20,
            vertical: isVerySmall ? 8 : 10,
          ),
          child: Row(
            children: [
              Icon(
                Icons.store,
                color: const Color(0xFF3B82F6),
                size: isVerySmall ? 16 : 20,
              ),
              SizedBox(width: isVerySmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isVerySmall ? 'Oxígeno' : 'Oxígeno Zero Grados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isVerySmall ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isVerySmall)
                      const Text(
                        'Sistema de Gestión',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isVerySmall ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        rolNombre,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isVerySmall ? 9 : 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(width: isVerySmall ? 6 : 8),
                  Container(
                    width: isVerySmall ? 28 : 32,
                    height: isVerySmall ? 28 : 32,
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isVerySmall ? 12 : 14,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📜 Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth < 400 ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título responsive
                  Text(
                    'Selecciona un módulo',
                    style: TextStyle(
                      fontSize: screenWidth < 400 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A202C),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: screenWidth < 400 ? 12 : 16),

                  // Lista de módulos
                  ...modulos.map((modulo) => _buildModuloItem(context, modulo)),
                ],
              ),
            ),
          ),

          // 📍 Footer inferior compacto
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0B1A2E),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Color(0xFF3B82F6), size: 8),
                SizedBox(width: 8),
                Text(
                  'Modo sin conexión',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Construir botón de módulo con diseño responsive
  // Los tamaños se ajustan según el ancho de la pantalla
  Widget _buildModuloItem(BuildContext context, Map<String, dynamic> modulo) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Ajustar tamaños según ancho de pantalla
    final iconSize = screenWidth < 400 ? 32.0 : 40.0;
    final iconInnerSize = screenWidth < 400 ? 18.0 : 22.0;
    final textSize = screenWidth < 400 ? 14.0 : 16.0;
    final chevronSize = screenWidth < 400 ? 20.0 : 24.0;
    final horizontalPadding = screenWidth < 400 ? 12.0 : 16.0;
    final verticalPadding = screenWidth < 400 ? 14.0 : 18.0;

    // 🎨 Verificar si es el módulo de inventarios para usar degradado verde
    final esInventarios = modulo['nombre'] == 'Toma de Inventario';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: esInventarios
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C950), Color(0xFF008236)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ElevatedButton(
        onPressed: () => onModuloTap(context, modulo['nombre']),
        style: ElevatedButton.styleFrom(
          backgroundColor: esInventarios ? Colors.transparent : modulo['color'],
          shadowColor: esInventarios
              ? Colors.transparent
              : Colors.black.withOpacity(0.1),
          foregroundColor: Colors.white,
          elevation: esInventarios ? 0 : 2,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // Ícono a la izquierda (responsive)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                modulo['icono'],
                color: Colors.white,
                size: iconInnerSize,
              ),
            ),
            SizedBox(width: horizontalPadding),
            // Texto expandido al centro (responsive)
            Expanded(
              child: Text(
                modulo['nombre'],
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            // Flecha a la derecha (responsive)
            Icon(Icons.chevron_right, color: Colors.white, size: chevronSize),
          ],
        ),
      ),
    );
  }
}
