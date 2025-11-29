import 'package:flutter/material.dart';

/// 🎨 COLORES DEL SISTEMA KONTARO
///
/// Esta clase contiene todos los colores usados en la aplicación.
/// Cada módulo tiene su propio color para identificación visual rápida.
///
/// LECCIÓN: En Flutter, usamos clases para organizar constantes.
/// Los colores se definen con Color(0xFFRRGGBB) donde:
/// - FF es la opacidad (transparencia)
/// - RR es el rojo en hexadecimal
/// - GG es el verde en hexadecimal
/// - BB es el azul en hexadecimal

class AppColors {
  // 🚫 Constructor privado - nadie puede crear instancias de esta clase
  AppColors._();

  // ==================== COLORES POR MÓDULO ====================

  /// 🔵 Panel Administrativo - Azul profesional
  static const Color adminBlue = Color(0xFF2B7FFF);

  /// 🟢 Toma de Inventario - Verde confiable
  static const Color inventoryGreen = Color(0xFF00BC7D);

  /// 🟣 Punto de Venta (POS) - Morado distintivo
  static const Color posPurple = Color(0xFF8200DB);

  /// 🔵 Inventarios Cíclicos - Cyan moderno
  static const Color cyclicalCyan = Color(0xFF06B6D4);

  /// 🟡 Consultas de Referencias - Ámbar cálido
  static const Color referencesAmber = Color(0xFFF59E0B);

  /// 🔷 Reportes - Índigo corporativo
  static const Color reportsIndigo = Color(0xFF4F46E5);

  /// ⚙️ Configuración - Gris neutro
  static const Color settingsGray = Color(0xFF6B7280);

  // ==================== COLORES BASE ====================

  /// Colores principales de la app
  static const Color primary = Color(0xFF2B7FFF);
  static const Color secondary = Color(0xFF00BC7D);

  /// Fondos
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  /// Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ==================== ESTADOS ====================

  /// ✅ Estado exitoso / confirmación
  static const Color success = Color(0xFF10B981);

  /// ⚠️ Advertencias
  static const Color warning = Color(0xFFF59E0B);

  /// ❌ Errores / peligro
  static const Color error = Color(0xFFEF4444);

  /// ℹ️ Información
  static const Color info = Color(0xFF3B82F6);

  // ==================== INVENTARIO ====================

  /// Stock normal (suficiente)
  static const Color stockOk = Color(0xFF10B981);

  /// Stock bajo (alerta)
  static const Color stockLow = Color(0xFFF59E0B);

  /// Sin stock (crítico)
  static const Color stockOut = Color(0xFFEF4444);

  /// Sobrante en inventario
  static const Color surplus = Color(0xFF06B6D4);

  /// Faltante en inventario
  static const Color shortage = Color(0xFFEF4444);

  // ==================== UI ELEMENTS ====================

  /// Bordes
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF2B7FFF);

  /// Dividers (líneas separadoras)
  static const Color divider = Color(0xFFE5E7EB);

  /// Sombras
  static const Color shadow = Color(0x1A000000); // Negro con 10% opacidad

  /// Overlay (capa encima)
  static const Color overlay = Color(0x80000000); // Negro con 50% opacidad

  // ==================== TIENDAS ====================

  /// Tienda Principal - Bogotá
  static const Color storeBogota = Color(0xFF2B7FFF);

  /// Sucursal Norte - Medellín
  static const Color storeMedellin = Color(0xFF10B981);

  /// Sucursal Centro - Cali
  static const Color storeCali = Color(0xFFF59E0B);

  /// Sucursal Sur - Barranquilla
  static const Color storeBarranquilla = Color(0xFFEF4444);

  // ==================== GLASSMORPHISM ====================

  /// Efecto de vidrio para móvil (fondo semi-transparente)
  static const Color glassBg = Color(0x80FFFFFF); // Blanco con 50% opacidad
  static const Color glassBorder = Color(0x40FFFFFF); // Blanco con 25% opacidad

  // ==================== COLORES FIGMA (AUDITOR) ====================

  /// 🌙 Fondo oscuro principal (pantalla de módulos Auditor)
  static const Color darkBackground = Color(0xFF1A202C);

  /// 🌑 Fondo oscuro secundario (header, footer)
  static const Color darkBackgroundSecondary = Color(0xFF0D1117);

  /// ⚪ Cards blancos sobre fondo oscuro
  static const Color whiteCard = Color(0xFFFFFFFF);

  /// 📘 Azul info/estado (círculo de avatar, estado del sistema)
  static const Color infoBlue = Color(0xFF3B82F6);

  /// 🟢 Verde para íconos de Toma de Inventario (más saturado)
  static const Color iconGreen = Color(0xFF00BC7D);

  /// 🔵 Cyan para íconos de Inventarios Cíclicos (más vibrante)
  static const Color iconCyan = Color(0xFF00B4D8);

  /// 🟠 Naranja para íconos de Consultas de Referencias (más intenso)
  static const Color iconOrange = Color(0xFFF59E0B);

  /// 🔗 Link/acción (texto de "Abrir módulo >")
  static const Color linkText = Color(0xFF3B82F6);

  /// 📝 Texto en fondo oscuro (blanco/gris claro)
  static const Color textOnDark = Color(0xFFE2E8F0);

  /// 📝 Texto secundario en fondo oscuro (gris más oscuro)
  static const Color textSecondaryOnDark = Color(0xFF94A3B8);
}
