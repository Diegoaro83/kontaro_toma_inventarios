import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 🔄 PANTALLA DE INVENTARIOS CÍCLICOS
///
/// Módulo para gestionar conteos cíclicos:
/// - Carga de Excel con referencias
/// - Selección manual o aleatoria
/// - Programación de ciclos de conteo
///
/// Para Auditor: Solo lectura y consulta

class CyclicalInventoryScreen extends StatefulWidget {
  const CyclicalInventoryScreen({super.key});

  @override
  State<CyclicalInventoryScreen> createState() =>
      _CyclicalInventoryScreenState();
}

class _CyclicalInventoryScreenState extends State<CyclicalInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 AppBar con color cyan de cíclicos
      appBar: AppBar(
        title: const Text('Inventarios Cíclicos'),
        backgroundColor: AppColors.cyclicalCyan,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // 📱 Cuerpo de la pantalla
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔄 Ícono grande
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cyclicalCyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.loop,
                  size: 80,
                  color: AppColors.cyclicalCyan,
                ),
              ),
              const SizedBox(height: 32),

              // 📝 Título
              Text(
                'Módulo de Inventarios Cíclicos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 📄 Descripción
              Text(
                'Carga archivos Excel, selecciona referencias manualmente o de forma aleatoria para programar conteos cíclicos.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 🚧 Badge de "En construcción"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Módulo en construcción',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
