import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/adaptive_layout.dart';
import '../users/creacion_usuario_screen.dart';
import '../users/lista_usuarios_screen.dart';
import 'module_selector_mobile.dart';
import 'module_selector_desktop.dart';

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
    // Obtener los módulos disponibles según el rol
    final modulos = _obtenerModulosPorRol(rolId);

    // 🎯 Usar diseño adaptativo: LayoutBuilder detecta el tamaño
    // y muestra la versión móvil o escritorio automáticamente
    return AdaptiveLayout(
      // Versión para móviles y tablets (< 900px)
      mobileBody: ModuleSelectorMobile(
        nombreUsuario: nombreUsuario,
        rolNombre: rolNombre,
        modulos: modulos,
        onModuloTap: _abrirModulo,
      ),

      // Versión para escritorio (>= 900px)
      desktopBody: ModuleSelectorDesktop(
        nombreUsuario: nombreUsuario,
        rolNombre: rolNombre,
        modulos: modulos,
        onModuloTap: _abrirModulo,
      ),
    );
  }

  /// Obtiene los módulos disponibles según el rol del usuario
  List<Map<String, dynamic>> _obtenerModulosPorRol(String rolId) {
    // Definir todos los módulos disponibles
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
        'color': const Color(0xFFEA4747), // Rojo Figma
      },
      'lista_usuarios': {
        'nombre': 'Lista de Usuarios',
        'icono': Icons.people,
        'color': const Color(0xFFEA4747), // Rojo Figma
      },
      'gestion_roles': {
        'nombre': 'Gestión de Roles',
        'icono': Icons.work,
        'color': const Color(0xFF7C3AED), // Púrpura oscuro
      },
    };

    // Según el rol, devolver los módulos permitidos
    List<String> modulosPermitidos = [];

    switch (rolId) {
      case '1': // Dirección General
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
          'panel_admin',
          'punto_venta',
          'creacion_usuarios', // Solo Dirección General
          'lista_usuarios', // Solo Dirección General
          'gestion_roles', // Solo Dirección General
        ];
        break;
      case '2': // Administrador
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
          'panel_admin',
          'punto_venta',
        ];
        break;
      case '3': // Gestor de Punto
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'punto_venta',
          'panel_admin',
        ];
        break;
      case '4': // Asesor Comercial
        modulosPermitidos = ['punto_venta'];
        break;
      case '5': // Auditor
        modulosPermitidos = [
          'inventarios',
          'inventarios_ciclicos',
          'consultas',
        ];
        break;
      default:
        modulosPermitidos = [];
    }

    // Retornar la lista de módulos filtrados
    return modulosPermitidos.map((key) => todosLosModulos[key]!).toList();
  }

  /// Navega al módulo seleccionado
  void _abrirModulo(BuildContext context, String nombreModulo) {
    // Navegación específica según el módulo
    if (nombreModulo == 'Creación de Usuarios') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreacionUsuarioScreen()),
      );
      return;
    }

    if (nombreModulo == 'Lista de Usuarios') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ListaUsuariosScreen()),
      );
      return;
    }

    if (nombreModulo == 'Gestión de Roles') {
      Navigator.pushNamed(context, '/lista-roles');
      return;
    }

    // Para otros módulos, mostrar SnackBar (TODO)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo: $nombreModulo'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.inventoryGreen,
      ),
    );

    // TODO: Aquí navegarás a las otras pantallas
    // Por ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioScreen()));
  }
}
