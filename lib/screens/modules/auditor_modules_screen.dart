import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../inventory_taking/inventory_taking_screen.dart';
import '../cyclical_inventory/cyclical_inventory_screen.dart';
import '../references_query/references_query_screen.dart';

/// 🎯 PANTALLA DE MÓDULOS DEL AUDITOR (DISEÑO FIGMA)
///
/// Pantalla específica para el rol Auditor con diseño de Figma:
/// - Fondo azul oscuro (#1E293B)
/// - Header con logo, empresa, usuario y avatar
/// - 3 cards blancos con módulos permitidos
/// - Footer con estado de sincronización
///
/// Módulos del Auditor:
/// 1. Toma de Inventario (verde)
/// 2. Inventarios Cíclicos (cyan)
/// 3. Consultas de Referencias (naranja)

class AuditorModulesScreen extends StatelessWidget {
  final String nombreUsuario;
  final String rolNombre;

  const AuditorModulesScreen({
    super.key,
    required this.nombreUsuario,
    required this.rolNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌙 Degradado diagonal de esquina superior izquierda a inferior derecha (tonos más oscuros)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020B1F), // Azul muy oscuro casi negro (inicio)
              Color(0xFF051E47), // Azul oscuro medio
              Color(0xFF010812), // Negro azulado (fin)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 📱 Header con logo, empresa y usuario
              _buildHeader(context),

              // 📜 Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 Título principal
                      Text(
                        'Selecciona un módulo',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 📝 Subtítulo
                      Text(
                        'Elige la herramienta que necesitas usar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 📦 Cards de módulos - RESPONSIVE (se adapta automáticamente)
                      // Desktop (≥900px): 3 cards horizontales
                      // Móvil (<900px): 3 cards verticales apilados
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 🔍 Detectar si es desktop o móvil
                          final isDesktop = constraints.maxWidth >= 900;

                          if (isDesktop) {
                            // 💻 DESKTOP: Cards lado a lado en Row
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildModuleCard(
                                    context: context,
                                    icon: Icons.inventory_2,
                                    iconColor: const Color.fromARGB(
                                      171,
                                      2,
                                      124,
                                      84,
                                    ),
                                    title: 'Toma de Inventario',
                                    description:
                                        'Escaneo de códigos, registro manual y sincronización en tiempo real',
                                    onTap: () => _navegarAModulo(
                                      context,
                                      InventoryTakingScreen(
                                        nombreUsuario: nombreUsuario,
                                        rolNombre: rolNombre,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildModuleCard(
                                    context: context,
                                    icon: Icons.loop,
                                    iconColor: AppColors.iconCyan,
                                    title: 'Inventarios Cíclicos',
                                    description:
                                        'Carga de Excel, selección manual o aleatoria de referencias a contar',
                                    onTap: () => _navegarAModulo(
                                      context,
                                      const CyclicalInventoryScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildModuleCard(
                                    context: context,
                                    icon: Icons.search,
                                    iconColor: AppColors.iconOrange,
                                    title: 'Consultas de Referencias',
                                    description:
                                        'Consulta de códigos de barras, cantidades, valores y metas en tiempo real',
                                    onTap: () => _navegarAModulo(
                                      context,
                                      const ReferencesQueryScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // 📱 MÓVIL/TABLET: Cards apilados en Column
                            return Column(
                              children: [
                                _buildModuleCard(
                                  context: context,
                                  icon: Icons.inventory_2,
                                  iconColor: AppColors.iconGreen,
                                  title: 'Toma de Inventario',
                                  description:
                                      'Escaneo de códigos, registro manual y sincronización en tiempo real',
                                  onTap: () => _navegarAModulo(
                                    context,
                                    InventoryTakingScreen(
                                      nombreUsuario: nombreUsuario,
                                      rolNombre: rolNombre,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildModuleCard(
                                  context: context,
                                  icon: Icons.loop,
                                  iconColor: AppColors.iconCyan,
                                  title: 'Inventarios Cíclicos',
                                  description:
                                      'Carga de Excel, selección manual o aleatoria de referencias a contar',
                                  onTap: () => _navegarAModulo(
                                    context,
                                    const CyclicalInventoryScreen(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildModuleCard(
                                  context: context,
                                  icon: Icons.search,
                                  iconColor: AppColors.iconOrange,
                                  title: 'Consultas de Referencias',
                                  description:
                                      'Consulta de códigos de barras, cantidades, valores y metas en tiempo real',
                                  onTap: () => _navegarAModulo(
                                    context,
                                    const ReferencesQueryScreen(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 📊 Footer con estado del sistema
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 Construir header con logo, empresa y usuario
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBackgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 📝 Nombre de empresa y sistema
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oxígeno Zero Grados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnDark,
                  ),
                ),
                Text(
                  'Sistema de Gestión',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOnDark,
                  ),
                ),
              ],
            ),
          ),

          // 👤 Info del usuario con avatar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nombreUsuario,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                ),
              ),
              Text(
                rolNombre,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // 🟢 Avatar circular con degradado verde (Figma)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00C950), // 0%
                  Color(0xFF00B94A), // 39%
                  Color(0xFF008236), // 100%
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📦 Construir card de módulo estilo Figma
  Widget _buildModuleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎨 Ícono circular con color
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: icon == Icons.inventory_2
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF00C950), // 0%
                          Color(0xFF00B94A), // 39%
                          Color(0xFF008236), // 100%
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: icon == Icons.inventory_2 ? null : iconColor,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),

            // 📝 Título del módulo
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // 📄 Descripción
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // 🔗 Link "Abrir módulo >"
            Row(
              children: [
                Text(
                  'Abrir módulo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.linkText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: AppColors.linkText, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Construir footer con estado del sistema
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748).withOpacity(0.8),
        border: Border(
          top: BorderSide(color: AppColors.infoBlue.withOpacity(0.5), width: 2),
        ),
      ),
      child: Row(
        children: [
          // ℹ️ Ícono de info
          Icon(Icons.info_outline, color: AppColors.infoBlue, size: 20),
          const SizedBox(width: 12),

          // 📝 Texto de estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del sistema',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnDark,
                  ),
                ),
                Text(
                  'Última sincronización: No sincronizado',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryOnDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🧭 Navegar a un módulo específico
  void _navegarAModulo(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }
}
