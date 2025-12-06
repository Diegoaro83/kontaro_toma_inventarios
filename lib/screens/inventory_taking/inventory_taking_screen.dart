import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'sesiones_inventario_screen.dart' hide SizedBox;

/// 📦 PANTALLA DE TOMA DE INVENTARIO (NAVEGACIÓN AUTOMÁTICA)
///
/// Esta pantalla redirige inmediatamente a la pantalla de Sesiones de Inventario.
/// El flujo es:
/// 1. Usuario selecciona "Toma de Inventario" en módulos
/// 2. Esta pantalla se carga y automáticamente navega a Sesiones
/// 3. Usuario ve lista de sesiones activas y finalizadas

class InventoryTakingScreen extends StatefulWidget {
  final String nombreUsuario;
  final String rolNombre;

  const InventoryTakingScreen({
    super.key,
    this.nombreUsuario = 'Usuario',
    this.rolNombre = 'Auditor',
  });

  @override
  State<InventoryTakingScreen> createState() => _InventoryTakingScreenState();
}

class _InventoryTakingScreenState extends State<InventoryTakingScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 Navegar automáticamente a Sesiones después de que se construya el frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navegarASesiones();
    });
  }

  /// 🔀 Navegar a pantalla de Sesiones de Inventario
  void _navegarASesiones() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SesionesInventarioScreen(
          nombreUsuario: widget.nombreUsuario,
          rolNombre: widget.rolNombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 Pantalla temporal con loading mientras navega
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.inventoryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando sesiones...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryOnDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
