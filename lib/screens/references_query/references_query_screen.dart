import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 🔍 PANTALLA DE CONSULTAS DE REFERENCIAS
///
/// Módulo para consultar información de productos:
/// - Búsqueda por código de barras
/// - Ver cantidades disponibles
/// - Consultar valores y metas
/// - Información en tiempo real
///
/// Para Auditor: Acceso completo a consultas

class ReferencesQueryScreen extends StatefulWidget {
  const ReferencesQueryScreen({super.key});

  @override
  State<ReferencesQueryScreen> createState() => _ReferencesQueryScreenState();
}

class _ReferencesQueryScreenState extends State<ReferencesQueryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 AppBar con color naranja de consultas
      appBar: AppBar(
        title: const Text('Consultas de Referencias'),
        backgroundColor: AppColors.referencesAmber,
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
              // 🔍 Ícono grande
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.referencesAmber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  size: 80,
                  color: AppColors.referencesAmber,
                ),
              ),
              const SizedBox(height: 32),

              // 📝 Título
              Text(
                'Módulo de Consultas de Referencias',
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
                'Consulta códigos de barras, cantidades disponibles, valores y metas de productos en tiempo real.',
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
