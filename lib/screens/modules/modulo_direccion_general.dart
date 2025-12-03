import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import 'package:flutter/material.dart';
import 'modulo_base.dart';
import '../../widgets/common/modulo_card_general.dart';
import 'package:go_router/go_router.dart';

/// 🏢 MÓDULO DIRECCIÓN GENERAL
///
/// Pantalla personalizada para el rol Dirección General.
/// - Muestra los módulos exclusivos de este perfil
/// - Permite navegar y gestionar usuarios, reportes, inventarios, etc.
/// - Incluye botón de regreso al selector de módulos
class ModuloDireccionGeneral extends StatelessWidget {
  /// 🚀 Lista de módulos para Dirección General
  /// Cada módulo tiene icono, color, texto y acción
  final List<_ModuloDG> modulosDG = [
    _ModuloDG(
      icono: Icons.person_add,
      color: Color(0xFFEA4747),
      titulo: 'Creación de Usuarios',
      descripcion: 'Agregar nuevos usuarios al sistema',
      onTap: (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir módulo: Creación de Usuarios')),
      ),
    ),
    _ModuloDG(
      icono: Icons.people,
      color: Color(0xFFEA4747),
      titulo: 'Lista de Usuarios',
      descripcion: 'Ver y editar usuarios existentes',
      onTap: (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir módulo: Lista de Usuarios')),
      ),
    ),
    _ModuloDG(
      icono: Icons.inventory_2,
      color: Color(0xFF00BC7D),
      titulo: 'Toma de Inventario',
      descripcion: 'Gestionar inventarios físicos',
      onTap: (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir módulo: Toma de Inventario')),
      ),
    ),
    _ModuloDG(
      icono: Icons.sync_alt,
      color: Color(0xFF06B6D4),
      titulo: 'Inventarios Cíclicos',
      descripcion: 'Conteos periódicos de stock',
      onTap: (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir módulo: Inventarios Cíclicos')),
      ),
    ),
    _ModuloDG(
      icono: Icons.search,
      color: Color(0xFFF59E0B),
      titulo: 'Consultas de Referencias',
      descripcion: 'Buscar productos y referencias',
      onTap: (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir módulo: Consultas de Referencias')),
      ),
    ),
    _ModuloDG(
      icono: Icons.point_of_sale,
      color: Color(0xFF8200DB),
      titulo: 'Punto de Venta',
      descripcion: 'Gestión de ventas y facturación',
      onTap: (context) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Abrir módulo: Punto de Venta'))),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    return ModuloBaseScreen(
      tituloModulo: 'Panel Dirección General',
      barraSuperior: BarraSuperiorModulo(
        nombreEmpresa: 'Oxígeno Zero Grados',
        subtitulo: 'Panel de Módulo',
        nombreUsuario: 'Diego',
        nombrePerfil: 'Dirección General',
        estadoSistema: 'No sincronizado',
        avatarUrl: null,
      ),
      barraInferior: BarraInferiorModulo(
        estadoSistema: 'No sincronizado',
        ultimaSincronizacion: 'Hace 2 min',
        onVolver: () {
          // ⚠️ Volver al módulo anterior
          context.pop();
        },
        onSalir: () async {
          // ⚠️ Diálogo de confirmación antes de salir
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('¿Desea salir del programa?'),
              content: const Text(
                'Se cerrará la sesión y podrá iniciar con otro usuario.',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                ElevatedButton(
                  child: const Text('Salir'),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          );
          if (confirm == true) {
            // Limpiar datos de usuario, contraseña y rol aquí si usas controladores o Provider
            // Ejemplo: usuarioController.clear(); contrasenaController.clear(); rolSeleccionado = null;
            context.go('/login');
          }
        },
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 900,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : 32,
            vertical: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accede a todos los módulos administrativos, gestión de usuarios y reportes.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: isMobile ? 600 : 420,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    childAspectRatio: 1.7, // Más rectangular, como la imagen 2
                    crossAxisSpacing: 32, // Más aire entre cards
                    mainAxisSpacing: 32, // Más aire entre cards
                  ),
                  itemCount: modulosDG.length,
                  itemBuilder: (context, index) {
                    final modulo = modulosDG[index];
                    return ModuloCardGeneral(
                      icono: modulo.icono,
                      colorIcono: modulo.color,
                      titulo: modulo.titulo,
                      descripcion: modulo.descripcion,
                      onTap: () => modulo.onTap(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 Modelo de módulo para Dirección General
class _ModuloDG {
  final IconData icono;
  final Color color;
  final String titulo;
  final String descripcion;
  final void Function(BuildContext) onTap;
  _ModuloDG({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });
}
