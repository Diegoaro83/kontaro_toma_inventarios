import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🎨 TEMA DE LA APLICACIÓN
///
/// Este archivo define cómo se verá TODA la aplicación:
/// - Colores de botones
/// - Tamaños de texto
/// - Formas de tarjetas
/// - Y mucho más!
///
/// LECCIÓN: Un tema hace que toda la app se vea consistente (igual en todas partes)

class AppTheme {
  // 🚫 Constructor privado
  AppTheme._();

  /// ☀️ TEMA CLARO (Light Theme) con Material 3
  /// Este es el tema principal que usaremos
  static ThemeData lightTheme = ThemeData(
    // 🎨 Activar Material Design 3
    useMaterial3: true,

    // 🎨 Esquema de colores Material 3 completo
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withOpacity(0.1),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.withOpacity(0.1),
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.inventoryGreen,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.background,
      outline: AppColors.border,
      outlineVariant: AppColors.border.withOpacity(0.5),
    ),

    // 📱 Fondo de toda la app
    scaffoldBackgroundColor: AppColors.background,

    // 📝 ESTILOS DE TEXTO
    // Estos son los tamaños y pesos de texto que usaremos
    textTheme: const TextTheme(
      // Títulos grandes (pantallas principales)
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      // Títulos medianos (secciones)
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      // Títulos pequeños (tarjetas)
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      // Texto de cuerpo normal
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),

      // Texto de cuerpo pequeño
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),

      // Etiquetas y textos secundarios
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),

    // 🔘 ESTILO DE BOTONES PRINCIPALES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Color de fondo
        foregroundColor: Colors.white, // Color del texto
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
        ),
        elevation: 2, // Sombra
      ),
    ),

    // 🔘 ESTILO DE BOTONES SECUNDARIOS (outline)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // 🔘 ESTILO DE BOTONES DE TEXTO
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // 📝 ESTILO DE CAMPOS DE TEXTO (inputs)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // 🎴 ESTILO DE TARJETAS (cards)
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // 📱 ESTILO DE LA BARRA SUPERIOR (AppBar)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    // ✅ ESTILO DE CHECKBOXES
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // 🔘 ESTILO DE RADIO BUTTONS
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.border;
      }),
    ),

    // 📊 ESTILO DE SWITCHES (interruptores)
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.grey.shade300;
      }),
    ),
  );
}
