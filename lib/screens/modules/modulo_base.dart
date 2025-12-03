import 'package:flutter/material.dart';

/// 🎨 MODULO BASE REUTILIZABLE
///
/// Widget base para pantallas de módulos y roles.
/// - Fondo degradado corporativo
/// - AppBar con avatar, nombre de usuario, perfil y estado
/// - Cards centrales y barra inferior de estado
/// - Espacio para contenido personalizado (cards, formularios, etc.)
class ModuloBaseScreen extends StatelessWidget {
  final String tituloModulo; // Título principal del módulo
  final Widget child; // Contenido personalizado (cards, formularios, etc.)
  final Widget barraSuperior; // Widget para la barra superior
  final Widget? barraInferior; // Widget para la barra inferior (opcional)

  const ModuloBaseScreen({
    Key? key,
    required this.tituloModulo,
    required this.child,
    required this.barraSuperior,
    this.barraInferior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(width: double.infinity, child: barraSuperior),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102040), Color(0xFF1A202C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Espacio superior opcional
            const SizedBox(height: 24),
            // Contenido principal ocupa todo el espacio disponible
            Expanded(child: child),
            // Barra inferior opcional
            if (barraInferior != null) barraInferior!,
          ],
        ),
      ),
    );
  }
}
