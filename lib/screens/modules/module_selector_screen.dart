import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/modulo_card_general.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import '../../widgets/common/barra_superior_modulo.dart';
import 'modulo_direccion_general.dart';
import 'modulo_administrador.dart';
import 'modulo_gestor_punto.dart';
import 'modulo_asesor_comercial.dart';
import 'modulo_auditor.dart';

/// 📱💻 PANTALLA ADAPTATIVA DE SELECCIÓN DE MÓDULOS
///
/// Esta pantalla se adapta automáticamente según el dispositivo:
/// - MÓVIL/TABLET: Lista vertical compacta
/// - ESCRITORIO: Grid con barra lateral
///
/// Muestra después del login con:
/// - Hora en la parte superior
/// - Información del perfil activo y usuario
/// - Lista/Grid de módulos disponibles según el rol
/// 📱💻 SELECTOR DE MÓDULOS RESPONSIVE UNIFICADO
///
/// Se adapta automáticamente a móvil, tablet y escritorio usando MediaQuery.
class ModuleSelectorScreen extends StatelessWidget {
  final String nombreUsuario;
  final String rolId;
  final String rolNombre;

  const ModuleSelectorScreen({
    super.key,
    required this.nombreUsuario,
    required this.rolId,
    required this.rolNombre,
  });

  @override
  Widget build(BuildContext context) {
    final modulos = _obtenerModulosPorRol(rolId);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (screenWidth >= 900) {
      crossAxisCount = 3; // Desktop
    } else if (screenWidth >= 600) {
      crossAxisCount = 2; // Tablet
    }
    final aspectRatio = 1.8;
    final esDireccionGeneral = rolNombre.toLowerCase().contains(
      'dirección general',
    );
    final modulosConMaestra = List<Map<String, dynamic>>.from(modulos);
    if (esDireccionGeneral) {
      modulosConMaestra.insert(0, {
        'nombre': 'Maestra de Referencias',
        'icono': Icons.menu_book_rounded,
        'color': const Color(0xFFFFD700),
        'descripcion': 'Carga y consulta el catálogo global de productos',
      });
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102040), Color(0xFF1A202C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            BarraSuperiorModulo(
              nombreEmpresa: "Oxígeno Zero Grados",
              subtitulo: "Sistema de Gestión",
              nombreUsuario: nombreUsuario,
              nombrePerfil: rolNombre,
              estadoSistema: "Activo",
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth < 600 ? 16 : 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_objects_rounded,
                    color: Color(0xFFFFD700),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selecciona un módulo para comenzar',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 🖼️ El GridView ahora está directamente en el Expanded del Column principal
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 600 ? 16 : 40,
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: modulosConMaestra.length,
                  itemBuilder: (context, index) {
                    final modulo = modulosConMaestra[index];
                    return ModuloCardGeneral(
                      icono: modulo['icono'] as IconData,
                      colorIcono: modulo['color'] as Color,
                      titulo: modulo['nombre'] as String,
                      descripcion: modulo['descripcion'] ?? '',
                      onTap: () => _abrirModulo(context, modulo['nombre']),
                    );
                  },
                ),
              ),
            ),
            BarraInferiorModulo(
              estadoSistema: "Activo",
              ultimaSincronizacion: "Hace 2 min",
              onVolver: () {
                Navigator.of(context).pop();
              },
              onSalir: () {
                GoRouter.of(context).go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene los módulos disponibles según el rol del usuario
  List<Map<String, dynamic>> _obtenerModulosPorRol(String rolId) {
    final Map<String, Map<String, dynamic>> todosLosModulos = {
      'inventarios': {
        'nombre': 'Toma de Inventario',
        'icono': Icons.inventory_2,
        'color': AppColors.inventoryGreen,
      },
      'inventarios_ciclicos': {
        'nombre': 'Inventarios Cíclicos',
        'icono': Icons.loop,
        'color': AppColors.cyclicalCyan,
      },
      'consultas': {
        'nombre': 'Consultas de Referencias',
        'icono': Icons.search,
        'color': AppColors.referencesAmber,
      },
      'panel_admin': {
        'nombre': 'Panel Administrativo',
        'icono': Icons.dashboard,
        'color': AppColors.adminBlue,
      },
      'punto_venta': {
        'nombre': 'Punto de Venta',
        'icono': Icons.point_of_sale,
        'color': AppColors.posPurple,
      },
      'creacion_usuarios': {
        'nombre': 'Creación de Usuarios',
        'icono': Icons.person_add,
        'color': const Color(0xFFEA4747),
      },
      'lista_usuarios': {
        'nombre': 'Lista de Usuarios',
        'icono': Icons.people,
        'color': const Color(0xFFEA4747),
      },
      'gestion_roles': {
        'nombre': 'Gestión de Roles',
        'icono': Icons.work,
        'color': const Color(0xFF7C3AED),
      },
    };
    List<String> modulosPermitidos = [];
    switch (rolId) {
      case '1':
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
          'panel_admin',
          'punto_venta',
          'creacion_usuarios',
          'lista_usuarios',
          'gestion_roles',
        ];
        break;
      case '2':
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
          'panel_admin',
          'punto_venta',
        ];
        break;
      case '3':
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'punto_venta',
          'panel_admin',
        ];
        break;
      case '4':
        modulosPermitidos = ['punto_venta'];
        break;
      case '5':
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
        ];
        break;
      default:
        modulosPermitidos = [];
    }
    return modulosPermitidos.map((key) => todosLosModulos[key]!).toList();
  }

  /// Navega al módulo seleccionado
  void _abrirModulo(BuildContext context, String nombreModulo) {
    /// 🔀 Navegación por rol: cada usuario accede a su módulo personalizado
    switch (rolId) {
      case '1': // Dirección General
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuloDireccionGeneral()),
        );
        break;
      case '2': // Administrador
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuloAdministrador()),
        );
        break;
      case '3': // Gestor de Punto
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuloGestorPunto()),
        );
        break;
      case '4': // Asesor Comercial
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuloAsesorComercial()),
        );
        break;
      case '5': // Auditor
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuloAuditor()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol no reconocido: $rolId'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
    }
  }
}
