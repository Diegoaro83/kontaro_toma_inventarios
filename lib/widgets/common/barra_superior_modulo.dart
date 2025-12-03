import 'package:flutter/material.dart';
import 'dart:ui';

/// 🎨 BARRA SUPERIOR DE MÓDULO REUTILIZABLE
///
/// Widget para la barra superior (AppBar) de los módulos.
/// - Muestra empresa, subtítulo, avatar, nombre de usuario, perfil y estado del sistema
/// - Fondo degradado corporativo
/// - Se usa en todos los roles y pantallas principales
class BarraSuperiorModulo extends StatelessWidget {
  final String nombreEmpresa; // Nombre de la empresa
  final String subtitulo; // Subtítulo debajo del nombre de empresa
  final String nombreUsuario; // Nombre del usuario activo
  final String nombrePerfil; // Nombre del perfil/rol
  final String
  estadoSistema; // Estado del sistema (ej: "Activo", "Sin conexión")
  final String? avatarUrl; // URL del avatar (opcional)

  const BarraSuperiorModulo({
    Key? key,
    required this.nombreEmpresa,
    required this.subtitulo,
    required this.nombreUsuario,
    required this.nombrePerfil,
    required this.estadoSistema,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2010,
      height: 77.23,
      child: Stack(
        children: [
          // Fondo gradiente y desenfoque
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xE61A1F3A), // #1A1F3A 90%
                      Color(0xE62D1B4E), // #2D1B4E 90%
                    ],
                    stops: [0.0, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0x3300D9FF), // Cyan 20% opacidad
                      width: 2, // Grosor del borde inferior
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Lado izquierdo: Empresa y subtítulo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Oxígeno Zero Grados',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal, // Arial regular
                            fontFamily: 'Arial', // Tipografía Arial
                          ),
                        ),
                        Text(
                          'Sistema de Gestión',
                          style: const TextStyle(
                            color: Color(0xFF00D9FF),
                            fontSize: 14,
                            fontWeight: FontWeight.normal, // Arial regular
                            fontFamily: 'Arial', // Tipografía Arial
                          ),
                        ),
                      ],
                    ),
                    // Lado derecho: Avatar, usuario y rol
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
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              nombrePerfil,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Avatar con gradiente y sombra glow
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF00D9FF),
                                Color(0xFF7B2FFF),
                                Color(0xFFFF006E),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B2FFF).withOpacity(0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              nombreUsuario.isNotEmpty
                                  ? nombreUsuario[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
          ),
        ],
      ),
    );
  }
}
